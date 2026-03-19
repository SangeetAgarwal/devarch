# Claude CLI Step Execution for DevArch

This guide covers execution of an existing implementation plan.

Plan construction belongs in `claude-cli-implementation-plan-construction.md`. This guide assumes the plan already exists and that it was derived from the authoritative artifact set.

This guide now covers **both**:
- numbered implementation steps
- numbered verification steps

It also defines how a model should generate Claude CLI prompts from this guide, including full prompt bundles for all steps in a phase.

## Core idea

Keep the durable rules in the artifact stack. Keep the live Claude CLI prompt minimal.

Use this order of authority during step execution:

1. `CLAUDE.md`
2. `docs/architecture/stack-context.md`
3. `docs/architecture/domain.md`
4. `docs/work/<phase>/specification.md`
5. `docs/work/<phase>/implementation-plan.md`
6. `docs/architecture/project-architecture.md` when the step touches integrations, external systems, phasing, or architecture-level ownership boundaries

## Deciding whether to include `project-architecture.md`

Read the **smallest authoritative set that truthfully governs the step**.

Include `docs/architecture/project-architecture.md` only when the numbered step materially touches one or more of:

- external providers or APIs
- webhook or callback flows
- embeds or client/provider integration boundaries
- cross-phase sequencing or phase dependencies
- ownership boundaries between the internal system and an external system
- architecture-level responsibilities that are not already fully governed by the phase specification and implementation plan

Omit `docs/architecture/project-architecture.md` when the step is primarily:

- local domain logic
- repository logic or query shaping
- schema or migration work
- local route or UI work that does not change provider or system-boundary behavior
- unit tests or local integration tests without external-system boundary decisions

When uncertain, prefer omission unless the numbered step text, implementation plan, or verification criteria make architecture-level context load-bearing for that step.

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
- After the step reaches its truthful status, manually type `/exit` in Claude CLI.
- Start the next numbered step in a new session.
- Do not continue into the next numbered step in the same session.

This rule applies to:
- implementation steps
- verification steps
- remediation or report-sync sessions tied to one completed step

Audit sessions are separate and are governed by `claude-cli-step-audit.md`.

## Step types

### 1) Implementation step

An implementation step changes code, configuration, schema, tests, or authoritative artifacts in order to implement a planned slice of behavior.

Its completion report answers:
- what changed
- why it changed
- what verification was run
- whether the step is `Complete`, `Partially Complete`, or `Blocked`

### 2) Verification step

A verification step is a numbered step whose main job is to evaluate an already-implemented slice or sub-phase against explicit done criteria from the implementation plan.

A verification step may:
- run build and test commands
- perform code review against the specification and plan
- perform or describe manual verification required by the plan
- update the step completion report for the verification step itself

A verification step must **not** silently claim completion from automated evidence when the plan explicitly requires manual verification.

If required manual verification cannot be completed in that session, the verification step must:
- mark the step `Partially Complete` or `Blocked`, whichever is truthful
- state exactly which criteria remain manually unverified
- output the exact remaining human checklist
- state pass criteria for that checklist
- state what must be updated in the step-completion report after the human finishes

### 3) What a verification step is not

A verification step is **not**:
- an audit session
- a new implementation step in disguise
- a place to "just fix a few things" without recording that the verification surfaced real drift

If verification reveals real code drift, choose one of these truth-preserving outcomes:
- `Partially Complete` — evidence is incomplete or some criteria remain unverified
- `Blocked` — an unmet prerequisite or real defect prevents truthful completion
- separate remediation session — when the problem is proven and should be fixed before re-running verification

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

### 6) Manual verification cannot be implied

If the implementation plan says a criterion requires manual verification, browser verification, provider dashboard verification, real HTTP inspection, or human-driven external setup, Claude must not treat automated evidence as equivalent unless the authoritative artifacts explicitly allow that substitution.

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
- a runtime/framework constraint discovered during manual verification

Promotion rules:

- write durable dependencies, prerequisites, contracts, and invariants back into the **specification**
- write sequencing or step-level dependency effects back into the **implementation plan**
- write runtime/framework truth back into **stack-context.md**
- write domain truth back into **domain.md**
- write integration/phasing/external-system truth back into **project-architecture.md**
- keep the **step completion report** as the evidence trail

## Verification-step rules

Use these rules whenever the numbered step is primarily a verification step.

### Required inputs

A verification step must read:
1. `CLAUDE.md`
2. `docs/architecture/stack-context.md`
3. `docs/architecture/domain.md`
4. the active phase specification
5. the active implementation plan
6. the most recent relevant step-completion report(s) that established the implementation being verified
7. `docs/architecture/project-architecture.md` when the verification touches integrations, external systems, phasing, or ownership boundaries

### Verification-step outputs

A verification step must produce:
- a truthful status
- criterion-by-criterion results
- build/test/manual verification evidence
- accepted limitations or blockers
- explicit remaining human checklist, when any required manual verification remains
- the updated `step-completion-<N>.md`

### Manual verification handoff is mandatory

If any required manual verification remains, Claude must not stop at:
- "manual verification pending"
- "looks good overall"
- "partially complete"

Instead, it must also output:

1. **Remaining human checklist**
   - exact ordered steps the human must run
   - any prerequisites needed first

2. **Pass criteria**
   - what the human must observe for each pending criterion

3. **Completion-report update instructions**
   - which criteria should change after the manual verification succeeds
   - whether the overall step status should change

This rule exists to prevent ambiguous handoffs. A truthful partial verification step must still tell the human exactly how to close it.

### Verification-step truth table

Use this as the status rule:

- **Complete**
  - all required automated and manual verification for the step has been performed
  - all criteria are supported by evidence
  - any remaining limitation is explicitly classified as non-blocking and still compatible with the step being complete

- **Partially Complete**
  - implementation is largely in place
  - some verification is done
  - but one or more required criteria remain unverified or only partially verified

- **Blocked**
  - an unmet human prerequisite, missing secret, missing environment setup, real bug, or other proven issue prevents truthful completion

## Prompt design

### Default implementation-step prompt

Use the explicit form. Name every document Claude CLI must read, the step number, and the completion report output path.

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then <phase-spec-path>, then <phase-plan-path><optional-project-architecture-clause>. Execute Step <N> only. Do not execute any other numbered step. If you encounter an implementation-time gap, stop, record it in <step-completions-dir>/step-completion-<N>.md, update the specification first before continuing, update the implementation plan if execution changes, update stack-context.md if runtime truth changes, update domain.md if domain truth changes, update project-architecture.md if integration or phasing truth changes, and then stop. After required verification, write <step-completions-dir>/step-completion-<N>.md. Create the directory if it does not already exist. The completion report must state status, what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

When the step does **not** touch integrations, external systems, or phasing, omit the project-architecture clause.

### Default verification-step prompt

Use the explicit form. Name every document Claude CLI must read, the step number, and the completion report output path.

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then <phase-spec-path>, then <phase-plan-path>, then <most-relevant-prior-step-completion-path><optional-project-architecture-clause>. Execute Step <N> only: verification. Do not execute any other numbered step. Do not add new feature scope. Verify this step or sub-phase against the implementation plan, specification, current codebase, required comments, and available verification evidence. Run the required build and test checks. Perform the manual verification required by the plan if it can be done in this session. If any required manual verification cannot be completed, mark the step truthfully, record exactly which criteria remain manually unverified, and include the exact remaining human checklist, pass criteria, and what must be updated in <step-completions-dir>/step-completion-<N>.md after the manual work succeeds. If you find code/report/spec drift, do not guess. Record it explicitly. After verification, write <step-completions-dir>/step-completion-<N>.md. Create the directory if it does not already exist."
```

### Short prompt

Use this only after you have confirmed that your `CLAUDE.md` is strong enough to resolve the current phase, the authoritative artifact paths, and the step completion report path without help.

For implementation steps:

```bash
claude "Read CLAUDE.md and execute Step <N> for phase <phase-dir>. Write the completion report to <step-completions-dir>/step-completion-<N>.md. Stop on any implementation-time gap and report it."
```

For verification steps:

```bash
claude "Read CLAUDE.md and execute verification Step <N> for phase <phase-dir>. Write the completion report to <step-completions-dir>/step-completion-<N>.md. If required manual verification remains, include the exact remaining human checklist, pass criteria, and report-update instructions."
```

If Claude CLI reads the wrong spec, misses the stack context, misses the domain spec, cannot find the implementation plan, fails to include project architecture when needed, or writes the report to the wrong location, switch back to the default prompt. The short form is a convenience, not a requirement.

### What the prompt must never do

- Restate the spec's scope, constraints, or decisions.
- Restate plan shape rules or step subsection requirements.
- Add extra instructions that belong in the spec or the plan.
- Name more than one step — one step per session, always.
- Treat manual verification as satisfied when only automated evidence exists and the plan required more.

## Prompt generation behavior

This section defines how any model should behave when a human references this guide and asks for a Claude CLI prompt.

### Default behavior when asked for a prompt

When the human asks for a prompt using this guide, the model should:

1. use this guide as authoritative
2. resolve whether the requested step is an implementation step or a verification step
3. infer whether `docs/architecture/project-architecture.md` is required from the numbered step text, the implementation plan, and the verification criteria whenever reasonably possible
4. output the finished Claude CLI prompt directly
5. ask only for information that is truly missing, such as:
   - phase directory
   - step number
   - step-completion path

Ask about `project-architecture.md` only when the step is genuinely ambiguous and that dependency cannot be inferred truthfully from the available artifacts.

The model should **not**:
- paraphrase the guide instead of producing the prompt
- explain the workflow unless asked
- require the human to ask separately for execution and verification if the requested step type is already clear
- include `project-architecture.md` by default in every step prompt "just to be safe"

### Prompt bundle behavior

When the human says something like:

- "I am now generating steps. Here's the guide. Give me all the prompts for each step."
- "Use the step execution guide and give me the full prompt bundle for this phase."
- "Generate all step prompts for this implementation plan."

the model should output a **prompt bundle**.

A prompt bundle means:
- the execution prompt for each implementation step
- the verification prompt for each numbered verification step
- the audit prompt for each step, using the companion `claude-cli-step-audit.md` conventions
- one reusable remediation/report-sync prompt template

When the human asks for a full bundle, output prompts in paired execution/audit order by default:
- Execute Step 1
- Audit Step 1
- Execute Step 2
- Audit Step 2
- ...
- Execute Step N
- Audit Step N

Use `claude-cli-step-audit.md` as authoritative for audit-prompt construction, but use this execution guide as authoritative for bundle ordering unless the human explicitly asks for a different ordering.

If the human asks for execution-only or audit-only prompts, do not include the other type.

If the active implementation plan is available, derive the bundle from that plan. If the plan is not available, ask for it.

### Prompt bundle output rules

When generating a prompt bundle:

1. Keep the response prompt-first.
2. Do not restate the whole guide unless asked.
3. Use exact phase paths and report paths where known.
4. Preserve one-step-per-session discipline in every generated prompt.
5. Include verification prompts only for steps that are actually verification steps.
6. Include audit prompts as companion prompts, not as replacements for step execution.
7. Include one reusable remediation/report-sync prompt template at the end unless the human asked not to.
8. Read the **smallest authoritative set that truthfully governs each step**.
9. Include `project-architecture.md` only for steps whose numbered-step text or verification criteria materially touch integrations, external systems, phasing, or architecture-level ownership boundaries.
10. Do not include `project-architecture.md` by default across the whole bundle.
11. When the human asks for a full bundle, output prompts in paired execution/audit order by default: Execute Step 1, Audit Step 1, Execute Step 2, Audit Step 2, and so on.
12. Use `claude-cli-step-audit.md` as authoritative for audit-prompt construction, but use this guide as authoritative for bundle ordering unless the human explicitly asks for a different order.
13. If the human asks for execution-only or audit-only prompts, do not include the other type.

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

## Artifact Write-Back
- None, or the exact durable fact that was promoted and where it was written
```

### Verification-step addendum

When the numbered step is a verification step, the completion report must also include:

```markdown
## Done Criteria Verification
- Criterion 1:
- Criterion 2:
- ...

## Remaining Human Verification (if any)
- Ordered checklist:
- Pass criteria:
- After-success report updates required:

## Accepted Trade-Offs / Known Limitations
- None, or the exact limitation and why it is non-blocking
```

## Verification vs audit

Use this short distinction:

- **Verification step**: closes a planned numbered step, sub-phase, or phase against explicit done criteria from the implementation plan.
- **Audit step**: independently checks whether an already-implemented step is truly in sync with the specification, implementation plan, code, comments, and verification evidence.

Verification belongs in this guide because it is part of numbered-step execution.

Audit belongs in `claude-cli-step-audit.md` because it is a separate post-implementation sync check, not a numbered implementation-plan step.

## Summary

The spec carries the decisions. The plan carries the order. Implementation and verification steps carry out exactly one numbered step per session. Step-completion reports provide evidence. Durable facts discovered in real execution are promoted back into the authoritative artifacts so later steps and later phases do not guess.

When a verification step cannot finish all required manual proof in the current session, truthfulness is not enough by itself. Claude must also produce the exact human handoff needed to close the step.
