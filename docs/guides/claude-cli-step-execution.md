# Claude CLI Step Execution for DevArch

This guide covers execution of an existing implementation plan.

Plan construction belongs in `claude-cli-implementation-plan-construction.md`. This guide assumes the plan already exists and that it was derived from the authoritative artifact set.

## Core idea

Keep the durable rules in the artifact stack. Keep the live Claude CLI prompt minimal.

Use this order of authority during step execution:

1. `CLAUDE.md`
2. `docs/architecture/stack-context.md`
3. `docs/architecture/domain.md`
4. `docs/work/<phase>/specification.md`
5. `docs/work/<phase>/implementation-plan.md`
6. `docs/architecture/project-architecture.md` when the step touches integrations, external systems, phasing, or architecture-level ownership boundaries

## Preconditions

Before step execution begins, you should have:

- a repo agent contract such as `CLAUDE.md`
- a current stack context document
- a current domain document
- a current phase specification
- a current implementation plan
- a plan that starts with one `## Human Steps` section and then uses numbered steps only

## Human Steps and numbered steps

Rules during execution:

- `## Human Steps` is not a numbered implementation step.
- `## Human Steps` is the single consolidated operator checklist for the phase.
- Later numbered steps must state which Human Steps items are prerequisites for runtime verification.
- If those prerequisites are not complete, stop and report blocked.
- Do not create new manual pause concepts during execution.

## One numbered step per Claude session

- Run exactly one numbered implementation-plan step per Claude session.
- After verification passes, manually type `/exit` in Claude CLI.
- Start the next numbered step in a new session.
- Do not continue into the next numbered step in the same session.

## Non-negotiable rules

### 1) The authoritative artifact set is the source of truth

Claude must not introduce new scope, naming, routes, schema, behavior, security policy, config, sequencing, integration ownership, runtime assumptions, or comment intent beyond what the authoritative artifacts state.

### 2) Stop on gaps

If Claude encounters ambiguity, missing decisions, contradictions, missing baseline dependencies, unstated constraints, or runtime facts that change implementation truth, it must stop and report the exact gap that must be added to the authoritative artifacts.

### 3) Do not build ahead

Claude executes only the requested numbered step and then stops.

### 4) Verify before claiming completion

A step is complete only when the verification required by the implementation plan has been run and reported with evidence.

### 5) Comments are part of the step

If the step touches code and the spec or plan requires comments, Claude must add, update, or remove comments in that same step.

## Comment policy during execution

Treat comments as implementation-side traceability.

Comments are required when they explain:

- contracts
- invariants
- trust boundaries
- provider or framework quirks
- non-obvious security behavior
- failure-sensitive branches
- why a workaround exists
- why a baseline dependency is being reused instead of recreated

Comments are not required for obvious line-by-line narration.

When a step changes a file, Claude must also check whether comments already in that file became stale or misleading because of the change.

## Gap resolution during execution

Implementation-time gaps are constraints, contradictions, missing decisions, missing baseline artifacts, missing human prerequisites, or runtime behaviors that surface only when real code meets real conditions.

### What Claude must do when a gap is found

1. **Stop.** Do not guess, work around, or make the decision independently.
2. **Report the gap** in the step completion report under `Spec Gaps Encountered`.
3. **Mark the step as `Blocked` or `Partially Complete`.**
4. **State which authoritative artifact must be updated** before the step can be retried.

### What the human must do after a gap is reported

1. **Update the specification first** with the decision when the gap changes scope, behavior, constraints, routes, schema, verification, environment contracts, prerequisites, or sequencing. Tag implementation-time additions `_(implementation gap)_` when appropriate.
2. **Update the other authoritative artifacts as needed:**
   - update the **implementation plan** if execution order, dependencies, or verification changes
   - update **stack-context.md** if runtime/framework truth changes
   - update **domain.md** if the gap affects Ubiquitous Language, domain model, or bounded-context truth
   - update **project-architecture.md** if the gap affects integration ownership, external-system responsibilities, or phasing truth
3. **Re-execute the blocked step** from scratch in a new CLI session.

### What must not happen

- A gap must not be resolved only in the step completion report.
- A gap must not be resolved only in the implementation plan.
- Claude must not resolve the gap by guessing.
- The human must not ask Claude to continue past the gap without updating the authoritative artifacts.

## Artifact write-back during execution

Step completion reports are evidence, not the sole long-term source of truth.

If execution confirms a durable, load-bearing fact that later steps or later phases depend on, write it back into the authoritative artifacts.

Examples:

- an existing helper such as `app/lib/ulid.ts` from an earlier phase
- a provider quirk that changes callback behavior
- a local-vs-production behavior that changes verification sequencing
- a cross-phase dependency that later work must honor

Promotion rules:

- write durable dependencies, prerequisites, contracts, and invariants back into the **specification**
- write sequencing or step-level dependency effects back into the **implementation plan**
- write runtime/framework truth back into **stack-context.md**
- write domain truth back into **domain.md**
- write integration/phasing/external-system truth back into **project-architecture.md**
- keep the **step completion report** as the evidence trail

## Prompt design

### Default prompt

Use the explicit form. Name every document CLI must read, the step number, and the completion report output path.

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then <phase-spec-path>, then <phase-plan-path><optional-project-architecture-clause>. Execute Step <N> only. Do not execute any other numbered step. If you encounter an implementation-time gap, stop, record it in <step-completions-dir>/step-completion-<N>.md, update the specification first before continuing, update the implementation plan if execution changes, update stack-context.md if runtime truth changes, update domain.md if domain truth changes, update project-architecture.md if integration or phasing truth changes, and then stop. After required verification, write <step-completions-dir>/step-completion-<N>.md. Create the directory if it does not already exist. The completion report must state status, what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

When the step does **not** touch integrations, external systems, or phasing, omit the project-architecture clause.

Example without project architecture:

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then docs/work/v1-auth/specification.md, then docs/work/v1-auth/implementation-plan.md. Execute Step 1 only. Do not execute any other numbered step. If you encounter an implementation-time gap, stop, record it in docs/context/v1-auth/step-completions/step-completion-1.md, update the specification first before continuing, update the implementation plan if execution changes, update stack-context.md if runtime truth changes, update domain.md if domain truth changes, and then stop. After required verification, write docs/context/v1-auth/step-completions/step-completion-1.md. Create the directory if it does not already exist. The completion report must state status, what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

Example with project architecture:

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then docs/architecture/project-architecture.md, then docs/work/v1-enrollment/specification.md, then docs/work/v1-enrollment/implementation-plan.md. Execute Step 3 only. Do not execute any other numbered step. If you encounter an implementation-time gap, stop, record it in docs/context/v1-enrollment/step-completions/step-completion-3.md, update the specification first before continuing, update the implementation plan if execution changes, update stack-context.md if runtime truth changes, update domain.md if domain truth changes, update project-architecture.md if integration or phasing truth changes, and then stop. After required verification, write docs/context/v1-enrollment/step-completions/step-completion-3.md. Create the directory if it does not already exist. The completion report must state status, what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

This is the default because it requires no inference. CLI reads exactly what you name, in the order you name it, executes the step you specify, and writes the report to the path you specify.

### Short prompt

Use this only after you have confirmed that your `CLAUDE.md` is strong enough to resolve the current phase, the authoritative artifact paths, and the step completion report path without help.

```bash
claude "Read CLAUDE.md and execute Step <N> for phase <phase-dir>. Write the completion report to <step-completions-dir>/step-completion-<N>.md. Stop on any implementation-time gap and report it."
```

If CLI reads the wrong spec, misses the stack context, misses the domain spec, cannot find the implementation plan, fails to include project architecture when needed, or writes the report to the wrong location, switch back to the default prompt. The short form is a convenience, not a requirement.

### What the prompt must never do

- Restate the spec's scope, constraints, or decisions.
- Restate plan shape rules or step subsection requirements.
- Add extra instructions that belong in the spec or the plan.
- Name more than one step — one step per session, always.

## Step completion report is required

After every step, Claude must write a completion report to:

`docs/context/<phase>/step-completions/step-completion-<N>.md`

If the directory does not exist, Claude must create it.

### Required completion-report structure

```markdown
# Step Completion — Step <N> — <Step Title>

## Status
- Complete | Partially Complete | Blocked

## What Changed
- Files created:
- Files modified:
- Files removed:
- Summary of concrete changes:

## Why
- Requirement(s), constraint(s), or plan objective this step implements:
- Reason these changes were necessary:

## Verification
- Build check:
- Runtime check:
- Manual verification:
- Integration check:
- Comment verification:
- Result:

## Gaps / Blockers / Unresolved Items
- Anything not completed in this step:
- External prerequisites still missing:
- Known risks or uncertainties:
- Anything the next step must account for:

## Spec Gaps Encountered
- None, or the exact gap that must be resolved in the authoritative artifacts

## Artifact Write-Back Required
- None, or the durable dependency / invariant / prerequisite that must be promoted into the authoritative artifacts

## Evidence
- Commands run:
- Key outputs or observations:
```

Rule:

- If any required verification could not be completed, or any external prerequisite still blocks part of the step outcome, the report must mark the step as `Partially Complete` or `Blocked` and explain why.

## Summary

Execute one numbered step at a time. Stop on gaps. Keep the prompt minimal. Persist evidence. Promote durable facts out of step reports and back into the authoritative artifacts when future work depends on them.
