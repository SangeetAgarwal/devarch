# Claude CLI Implementation Plan Construction for DevArch

This guide covers one job only: generating a trustworthy implementation plan from a phase specification.

## Core idea

Generating code is cheap. Trusting it is where the work is. The specification is how you get there.

That means:

- durable rules live in `CLAUDE.md`
- stack/runtime truth lives in `docs/architecture/stack-context.md`
- phase truth lives in `docs/work/<phase>/specification.md`
- execution order lives in `docs/work/<phase>/implementation-plan.md`
- the live Claude CLI prompt stays short and generic

## Artifact stack and authority

Use this order of authority:

1. `CLAUDE.md`
2. `docs/architecture/stack-context.md`
3. `docs/work/<phase>/specification.md`
4. the generated `docs/work/<phase>/implementation-plan.md`

Rules:

- The spec is the source of truth for phase scope.
- The plan is derived from the spec.
- If the plan would have to guess, tighten the spec first.
- Do not use the live prompt to compensate for missing detail that should live in the artifacts.

## What the specification must contain

For Claude CLI to build a good plan, the spec must already contain the durable phase decisions.

At minimum, the spec should include:

- goal
- scope and out-of-scope
- contracts and behavior
- environment variables and secrets
- human/operator work
- existing baseline dependencies, when the phase reuses artifacts built earlier
- sequencing constraints
- build-versus-runtime verification boundaries
- done criteria
- code comment requirements for non-obvious or trust-sensitive logic
- artifact write-back rules for durable facts discovered during execution

If any of that is missing, fix the spec before asking Claude to generate a fresh plan.

## Human Steps rule

For phases that require work outside the codebase, the spec must define one consolidated `## Human Steps` section.

Rules:

- the plan must place `## Human Steps` at the beginning
- the plan must not create later manual pause sections
- later numbered steps reference prerequisite Human Steps items by number
- the plan uses numbered steps only
- do not use macro phases, pause blocks, or phase-within-a-phase structure

## Existing baseline dependencies

A phase sometimes depends on artifacts that were created in an earlier phase and confirmed in step-completion reports.

Examples:

- helper modules such as `app/lib/ulid.ts`
- existing migrations
- generated config files
- previously established shared utilities

Rules:

- If the current phase depends on an existing artifact, the spec must say so explicitly.
- The plan must name that dependency in the affected step.
- Do not silently recreate a baseline dependency just because it was missing from an older plan or spec.
- If step-completion evidence proves a durable dependency exists and later work relies on it, write it back into the current spec before generating or regenerating the plan.

## Sequencing constraints the spec must declare

When a phase has external setup, the spec must include an `## Implementation Sequencing Constraints` section that makes dependencies explicit.

That section should include:

### 1. Dependency graph

Use a table like this:

```markdown
| Work | Depends On (Code) | Depends On (Human Steps) |
|------|-------------------|--------------------------|
| Session module | None | Human Steps §1 and §4 for runtime verification |
| Provider callback route | Auth service, session module | Human Steps §1, §2, §4, and §5 |
```

### 2. Sequencing rules

The rules should answer:

- what can be built and build-verified first
- what human setup is required before runtime verification
- what can be verified independently
- what must come last
- how build success differs from runtime readiness
- where required code comments must be added, updated, or checked
- how existing baseline dependencies must be surfaced in plan steps

### 3. Required plan structure

The spec should require a plan shape like this:

```markdown
## Human Steps

### 1. ...
### 2. ...

## Step 1 — ...
## Step 2 — ...
...
## Final Done Criteria Verification
```

The exact number of numbered steps may vary, but the plan must preserve the order required by the spec.

## Code comment policy in DevArch

Comments are not decoration. They are implementation-side traceability.

The plan generator must treat comments as part of the implementation contract, not as optional style.

Comments belong in the plan when they explain:

- contracts
- invariants
- trust boundaries
- provider or framework quirks
- non-obvious security behavior
- failure-sensitive logic
- why a workaround exists
- why a baseline dependency is being reused instead of recreated

Comments do not belong in the plan when they are just:

- line-by-line narration
- restating a function name in prose
- filler like “set variable” or “call helper”
- speculative future work not required by the spec

## What a trustworthy implementation plan must include

Each numbered step must include:

- step number and title
- goal
- files to create or modify
- exact changes to make
- why the step exists
- dependencies or sequencing constraints
- prerequisites from Human Steps, when runtime verification depends on them
- required comment updates
- verification criteria
- completion evidence

Use these verification labels:

- Build check
- Runtime check
- Manual verification
- Integration check
- Blocked pending external setup

## Required Comment Updates subsection

Every numbered step that changes code must include a `Required Comment Updates` subsection.

That subsection should say exactly which comments must be added, updated, or checked for staleness in the files touched by the step.

## Artifact write-back rule during plan construction

If the spec or available step-completion evidence reveals a durable fact that later work depends on, do not leave that fact stranded in a historical report.

Write it into the authoritative artifacts before finishing the plan.

Promote it to the right place:

- **specification** for durable dependencies, contracts, invariants, prerequisites, or baseline capabilities
- **implementation plan** for step-level dependency checks, sequencing effects, and execution blockers
- **step completion report** remains the evidence artifact, not the only place the fact lives

## Plan construction rules

When Claude CLI generates the plan, it must follow these rules:

1. Start from scratch when asked for a fresh plan.
2. Derive the plan from the spec only.
3. Do not preserve the shape of an older plan just because it already exists.
4. Do not invent scope, files, routes, env vars, secrets, behavior, or comment obligations not present in the spec.
5. Keep build-verifiable work ahead of runtime-dependent verification.
6. Put `## Human Steps` once at the beginning.
7. Keep independently verifiable provider flows as separate numbered steps when the spec says they are independently verifiable.
8. End with `## Final Done Criteria Verification`.
9. If the spec is not sufficient, stop and tighten the spec first.
10. Treat comment work as part of the implementation, not as a cosmetic afterthought.
11. Surface existing baseline dependencies explicitly in the affected steps.
12. If a durable cross-phase dependency is proven by step-completion evidence, promote it into the spec before finalizing the plan.

## Plan regeneration after implementation-time gaps

When an implementation-time gap causes the spec to change in ways that affect behavior, scope, constraints, sequencing, or baseline dependencies, the plan must be regenerated from the updated spec.

Rules for regeneration:

- Use the same plan construction rules as for a fresh plan.
- The regenerated plan replaces the previous plan entirely.
- Step numbers may change. This is expected.
- Previously completed steps that are unaffected by the gap do not need re-execution.
- Step completion reports from before the gap remain valid as evidence of what actually happened.
- If the gap is informational only, the spec is updated but the plan does not need regeneration.

## Review checklist before execution

After Claude generates the plan, review it before running any step.

Check:

1. Does the plan begin with one `## Human Steps` section?
2. Does the plan use numbered steps only?
3. Does every runtime-dependent step declare `Prerequisites from Human Steps`?
4. Does every code-changing step declare `Required Comment Updates`?
5. Does every step include a `Goal` subsection?
6. Do verification criteria use the explicit labels from this guide?
7. Do the steps follow the sequencing constraints in the spec?
8. Does the plan avoid invented scope?
9. Does the final section map the done criteria to concrete checks?
10. Do the comment obligations in the plan match the phase-specific comment requirements in the spec?
11. Are existing baseline dependencies surfaced where the phase relies on them?

## Prompt design

The live prompt should be minimal and generic. It should rely on the artifact stack, not restate the repo's operating rules.

### Preferred prompt

```bash
claude "Read CLAUDE.md and generate a fresh implementation plan for phase PHASE_DIR."
```

### Fallback prompt

```bash
claude "Read CLAUDE.md, then STACK_CONTEXT, then PHASE_SPEC. Generate a fresh implementation plan for this phase and write it to PHASE_PLAN_PATH."
```

## Summary

The spec carries the decisions. The plan carries the order, dependency visibility, and comment work. Step-completion reports provide evidence. Durable facts discovered in execution are promoted back into the authoritative artifacts so later planning does not guess.
