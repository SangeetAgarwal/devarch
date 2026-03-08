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

The live prompt should be the thinnest layer.

## Preconditions

Before step execution begins, you should have:

- a repo agent contract such as `CLAUDE.md`
- a current stack context document
- a current phase specification
- a current implementation plan
- a plan that starts with one `## Human Steps` section and then uses numbered steps only

## Human Steps and numbered steps

The implementation plan should have this shape:

```markdown
## Human Steps

### 1. ...
### 2. ...

## Step 1 — ...
## Step 2 — ...
...
## Final Done Criteria Verification
```

Rules during execution:

- `## Human Steps` is not a numbered implementation step.
- `## Human Steps` is the single consolidated operator checklist for the phase.
- Later numbered steps must state which Human Steps items are prerequisites for runtime verification.
- If those prerequisites are not complete, stop and report blocked. Do not guess and do not build around missing setup.
- Do not create new manual pause concepts during execution.

## One numbered step per Claude session

- Run exactly one numbered implementation-plan step per Claude session.
- After verification passes, manually type `/exit` in Claude CLI.
- Start the next numbered step in a new session.
- Do not continue into the next numbered step in the same session.

This keeps execution atomic and reduces drift.

## Non-negotiable rules

### 1) The spec is the source of truth

Claude must not introduce new scope, naming, routes, schema, behavior, security policy, config, or comment intent beyond what the spec states.

### 2) Stop on gaps

If Claude encounters ambiguity, missing decisions, contradictions, or unstated constraints, it must stop and report the exact gap that must be added to the spec.

### 3) Do not build ahead

Claude executes only the requested numbered step and then stops.

### 4) Verify before claiming completion

A step is complete only when the verification required by the implementation plan has been run and reported with evidence.

### 5) Comments are part of the step

If the step touches code and the spec or plan requires comments, Claude must add, update, or remove comments in that same step.

Do not defer comment cleanup to a later pass.

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

Comments are not required for obvious line-by-line narration.

When a step changes a file, Claude must also check whether comments already in that file became stale or misleading because of the change.

## Gap resolution during execution

Implementation-time gaps are constraints, contradictions, or missing decisions that surface only when real code meets real conditions. They differ from planning-time gaps (which surface during plan generation) because they emerge from execution-level reality — a library behaving differently than documented, a provider returning unexpected payloads, an ambiguity that only becomes visible when writing the implementation.

### What Claude must do when a gap is found

1. **Stop.** Do not guess, work around, or make the decision independently.
2. **Report the gap** in the step completion report under "Spec Gaps Encountered." State:
   - what the gap is
   - what spec section is affected
   - what decision the human needs to make
   - whether the gap blocks this step, affects later steps, or both
3. **Mark the step as Blocked or Partially Complete** in the Status field.

### What the human must do after a gap is reported

1. **Update the specification** with the decision. Tag the new content _(implementation gap)_ to distinguish it from upfront decisions and planning-time gaps.
2. **Assess plan impact:**
   - If the gap changes behavior, scope, constraints, routes, schema, or env vars → regenerate the implementation plan from the updated spec.
   - If the gap is informational only (e.g., confirming a library works as expected, documenting observed provider behavior) → update the spec, keep the existing plan.
3. **Re-execute the blocked step** from scratch in a new CLI session. Do not resume a stopped session.

### What must not happen

- A gap must not be resolved only in the step completion report. The spec must be updated.
- A gap must not be resolved only in the plan. The spec is the source of truth.
- Claude must not resolve the gap by guessing. Even a reasonable guess is a decision that bypassed the spec.
- The human must not ask Claude to "just continue past the gap." The gap exists because the spec is incomplete. Completing it is the human's job.

### Gap resolution and step numbering

When a gap causes plan regeneration, the step numbers may change. This is expected. The step completion reports from before the gap remain valid — they record what was actually built under the pre-gap plan. The new plan picks up from wherever the regenerated sequencing requires.

If previously completed steps are unaffected by the gap, they do not need to be re-executed. The human reviews the regenerated plan and resumes from the first step that changed.

## Default prompt pattern

Use one generic command shape for most numbered steps.

### Preferred prompt

Use this when `CLAUDE.md` already tells Claude how to resolve the stack context, phase spec, phase plan, and step-report location:

```bash
claude "Read CLAUDE.md and execute Step <N> for phase PHASE_DIR. After step execution, write step-completion-<N> to docs/context/<phase>/step-completions/step-completion-<N>.md. Create the directory docs/context/<phase>/step-completions if it does not already exist. The completion report must state what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

Example:

```bash
claude "Read CLAUDE.md and execute Step 6 for phase docs/work/v1-auth. After step execution, write step-completion-6 to docs/context/v1-auth/step-completions/step-completion-6.md. Create the directory docs/context/v1-auth/step-completions if it does not already exist. The completion report must state what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

### Fallback prompt

Use this when the repo contract is not yet strong enough to support the shorter form:

```bash
claude "Read CLAUDE.md, then STACK_CONTEXT, then PHASE_SPEC, then PHASE_PLAN. Execute Step <N> only. Previous numbered steps are complete. Do not build ahead. If any ambiguity, missing decision, or unstated constraint appears, stop and report the exact gap that must be added to PHASE_SPEC before coding. Do not guess. Run the verification required by the implementation plan. At the end: (1) print a completion report titled step-completion-<N> in session output, (2) write the same report to docs/context/<phase>/step-completions/step-completion-<N>.md, and (3) create docs/context/<phase>/step-completions first if it does not already exist. The completion report must state what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

The fallback prompt stays generic. It does not restate plan detail that should already be in the artifacts.

## When to add one extra line

The generic command should be the default.

Add one extra line only when one of these is true:

- the step has a known drift risk
- the step depends on Human Steps items that are easy to forget
- the step needs a high-value reminder not yet enforced by `CLAUDE.md`, the stack context, the spec, or the plan
- the step has unusual comment obligations that are easy to miss

Example:

```text
Before coding, confirm that the prerequisites listed under this step's 'Prerequisites from Human Steps' section are reflected in the environment and local setup.
```

That is enough. Do not turn the live prompt into a second plan.

## Step completion report file

Store step reports under a predictable phase-specific path:

- `docs/context/<phase>/step-completions/step-completion-<N>.md`

Example:

- `docs/context/v1-auth/step-completions/step-completion-6.md`

Rules:

- create `docs/context/<phase>/step-completions` on the first run if it does not exist
- keep it concise
- no raw diffs
- no raw build logs
- no screenshots
- avoid machine-specific absolute paths
- commit the report alongside the step’s code changes

## Completion report standard

Claude must both print and persist a structured completion report.

Required sections:

1. Status
2. What changed
3. Why
4. Commands run
5. Verification results
6. Stack-context compliance checks
7. Runtime readiness
8. Human/manual setup
9. Comment updates
10. Comment verification
11. Gaps / blockers / unresolved items
12. Scope drift
13. Work introduced early from later steps
14. Spec gaps encountered

### Recommended structure

Use this shape:

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

## Commands Run
- ...

## Verification Results
- Build check:
- Runtime check:
- Manual verification:
- Integration check:
- Comment verification:
- Result:

## Stack-Context Compliance Checks
- ...

## Runtime Readiness
- What verified successfully:
- What remains blocked pending Human Steps or external setup:
- Whether the step is code-complete, runtime-complete, or only partially complete:

## Human/Manual Setup
- No new human/manual setup introduced by this step
- Previously known remaining setup that still applies:

## Comment Updates
- ...

## Comment Verification
- ...

## Gaps / Blockers / Unresolved Items
- Anything not completed in this step:
- External prerequisites still missing:
- Known risks or uncertainties:
- Anything the next step must account for:

## Scope Drift
- ...

## Work Introduced Early from Later Steps
- ...

## Spec Gaps Encountered
- ...
```

### Status

Use these values only:

- **Complete**
- **Partially Complete**
- **Blocked**

If any required verification could not be completed, or any external prerequisite still blocks part of the step outcome, the report must mark the step as **Partially Complete** or **Blocked** and explain why.

Do not imply full completion when meaningful gaps remain.

### What changed

This section is required.

State clearly:

- which files were created, modified, or removed
- what concrete implementation changes were made
- what was intentionally not changed

Do not paste raw diffs. Summarize the actual implementation delta.

### Why

This section is required.

State clearly:

- which requirement, constraint, invariant, or plan goal the changes implement
- why the chosen changes were necessary in this step
- why the step stopped where it did if only partial completion was possible

This is the traceability bridge back to the spec and plan.

### Verification results

A successful build is not the same as runtime readiness.

If the step depends on external resources such as databases, secrets, provider consoles, namespaces, storage bindings, or environment files, the report must explicitly state:

- what verified successfully
- what remains blocked pending Human Steps
- whether the step is complete for code generation but not yet complete for runtime integration

### Human/manual setup

Use this wording:

- **No new human/manual setup introduced by this step**
- followed by **Previously known remaining setup that still applies**, if any

Only list previously known setup items that still materially affect:

- this numbered step
- the immediate next numbered step
- runtime readiness

Do not invent new operator tasks unless the spec or plan explicitly requires them.

### Comment updates

List the comments that were added, updated, or removed in this step.

Examples:

- module comment added in `session.server.ts` to explain signed-cookie session strategy
- inline comment updated in callback loader to explain `Response` re-throw contract
- stale comment removed from auth helper because it no longer matches the implementation

If the step required no comment changes, say so explicitly only after checking the touched files.

### Comment verification

State whether the step satisfied the plan’s `Required Comment Updates` subsection.

Confirm explicitly:

- which required comments were added or updated
- whether touched files were checked for stale comments
- whether any comment remains inaccurate or unresolved

A step that changes trust-sensitive code is not fully complete if the required comments are still missing or stale.

### Gaps / blockers / unresolved items

This section is required.

State clearly:

- anything not completed in this step
- anything blocked by external setup or unmet prerequisites
- any uncertainty that should be carried forward explicitly
- any follow-up the next step must account for

If there are no gaps, say so plainly.

## Local vs remote environment note

Local and remote Cloudflare resources are not the same thing.

This matters especially for D1:

- `--local` commands affect the local development database
- `--remote` commands affect the deployed Cloudflare database

A successful remote migration or seed does not populate the local database used by local development.

For D1-backed apps, verify both:

- local runtime readiness
- remote or deployed runtime readiness

## Deployment note for framework-generated Cloudflare configs

For framework builds that generate deployment config, the safe deploy command may be the repo script rather than raw `wrangler deploy`.

Prefer the repo’s deployment script when deployment depends on generated build output or generated Wrangler config.
