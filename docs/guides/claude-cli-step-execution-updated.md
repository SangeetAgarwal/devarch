# Claude CLI Step Execution for DevArch

This guide covers execution of an existing implementation plan.

Plan construction belongs in `claude-cli-implementation-plan-construction.md`. This guide assumes the plan already exists and that it was derived from the spec.

## Core idea

Keep the durable rules in the artifact stack. Keep the live Claude CLI prompt minimal.

Use this order of authority:

1. `CLAUDE.md`
2. `docs/architecture/stack-context.md`
3. `docs/work/<phase>/specification.md`
4. `docs/work/<phase>/implementation-plan.md`

## Preconditions

Before step execution begins, you should have:

- a repo agent contract such as `CLAUDE.md`
- a current stack context document
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

### 1) The spec is the source of truth

Claude must not introduce new scope, naming, routes, schema, behavior, security policy, config, or comment intent beyond what the spec states.

### 2) Stop on gaps

If Claude encounters ambiguity, missing decisions, contradictions, missing baseline dependencies, or unstated constraints, it must stop and report the exact gap that must be added to the spec.

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

Implementation-time gaps are constraints, contradictions, missing decisions, missing baseline artifacts, or runtime behaviors that surface only when real code meets real conditions.

### What Claude must do when a gap is found

1. **Stop.** Do not guess, work around, or make the decision independently.
2. **Report the gap** in the step completion report under `Spec Gaps Encountered`.
3. **Mark the step as `Blocked` or `Partially Complete`.**

### What the human must do after a gap is reported

1. **Update the specification** with the decision. Tag implementation-time additions `_(implementation gap)_` when appropriate.
2. **Assess plan impact:**
   - If the gap changes behavior, scope, constraints, routes, schema, env vars, sequencing, or baseline dependencies → regenerate the implementation plan.
   - If the gap is informational only → update the spec, keep the existing plan.
3. **Re-execute the blocked step** from scratch in a new CLI session.

### What must not happen

- A gap must not be resolved only in the step completion report.
- A gap must not be resolved only in the plan.
- Claude must not resolve the gap by guessing.
- The human must not ask Claude to continue past the gap without updating the spec.

## Artifact write-back during execution

Step completion reports are evidence, not the sole long-term source of truth.

If execution confirms a durable, load-bearing fact that later steps or later phases depend on, write it back into the authoritative artifacts.

Examples:

- an existing helper such as `app/lib/ulid.ts` from an earlier phase
- a provider quirk that changes callback behavior
- a local-vs-production behavior that changes verification sequencing

Promotion rule:

- write durable dependencies, prerequisites, contracts, and invariants back into the **specification**
- write sequencing or step-level dependency effects back into the **implementation plan**
- keep the **step completion report** as the evidence trail

## Default prompt pattern

Use one generic command shape for most numbered steps.

### Preferred prompt

```bash
claude "Read CLAUDE.md and execute Step <N> for phase PHASE_DIR. After step execution, write step-completion-<N> to docs/context/<phase>/step-completions/step-completion-<N>.md. Create the directory docs/context/<phase>/step-completions if it does not already exist. The completion report must state what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

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
- None, or the exact gap that must be resolved in the spec

## Artifact Write-Back Required
- None, or the durable dependency / invariant / prerequisite that must be promoted into the spec or plan

## Evidence
- Commands run:
- Key outputs or observations:
```

Rule:

- If any required verification could not be completed, or any external prerequisite still blocks part of the step outcome, the report must mark the step as `Partially Complete` or `Blocked` and explain why.

## Summary

Execute one numbered step at a time. Stop on gaps. Keep the prompt minimal. Persist evidence. Promote durable facts out of step reports and back into the authoritative artifacts when future work depends on them.
