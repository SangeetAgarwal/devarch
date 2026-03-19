# Claude CLI Implementation Plan Construction for DevArch

This guide covers one job only: generating a trustworthy implementation plan from a phase specification.

## Core idea

Generated code is cheap. Trusting it is where the work is. The specification is how you get there.

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
3. `docs/architecture/domain.md`
4. `docs/work/<phase>/specification.md`
5. the generated `docs/work/<phase>/implementation-plan.md`
6. `docs/architecture/project-architecture.md` when the phase touches integrations, external systems, phasing, or architecture-level ownership boundaries

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
| Work                    | Depends On (Code)            | Depends On (Human Steps)                       |
| ----------------------- | ---------------------------- | ---------------------------------------------- |
| Session module          | None                         | Human Steps §1 and §4 for runtime verification |
| Provider callback route | Auth service, session module | Human Steps §1, §2, §4, and §5                 |
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

## Verification steps as planned steps

A verification step is a legitimate numbered step when the phase requires a dedicated closure pass against done criteria.

Use a numbered verification step when the spec requires:
- explicit done-criteria verification
- browser or provider-level manual verification
- combined build/test/manual proof across several earlier steps
- a phase or sub-phase closure checkpoint

Rules:

- Verification steps are numbered steps in the implementation plan.
- They are not ad hoc follow-up notes.
- They should appear where the spec's sequencing requires them.
- They should identify the criteria to verify and any manual verification prerequisites from Human Steps.
- If manual verification may remain after the CLI session ends, the plan should expect the verification step to produce an explicit human handoff checklist in its completion report.

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
8. End with `## Final Done Criteria Verification` or another explicit numbered verification step when the spec calls for it.
9. If the spec is not sufficient, stop and tighten the spec first.
10. Treat comment work as part of the implementation, not as a cosmetic afterthought.
11. Surface existing baseline dependencies explicitly in the affected steps.
12. If a durable cross-phase dependency is proven by step-completion evidence, promote it into the spec before finalizing the plan.
13. When a numbered verification step requires manual verification that Claude CLI may not be able to complete itself, make that expectation explicit in the step's verification criteria and completion evidence.

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
7. Does the plan include numbered verification steps where the spec requires them?
8. If a verification step has manual requirements, does it make them explicit?
9. Do the steps follow the sequencing constraints in the spec?
10. Does the plan avoid invented scope?
11. Does the final section map the done criteria to concrete checks?
12. Do the comment obligations in the plan match the phase-specific comment requirements in the spec?
13. Are existing baseline dependencies surfaced where the phase relies on them?
14. If the operator asked for “just the prompt,” did the response return the default explicit command without extra policy text?

## Prompt design

### Prompt fidelity rule

When the user asks for the Claude CLI prompt, return the guide's default prompt form unless the user explicitly asks for a customized variant.

Do not optimize, elaborate, or “improve” the prompt just because additional instructions seem helpful.

The default prompt is the safe answer because this guide already defines:
- where phase decisions belong
- how insufficiency is handled
- how regeneration works
- what the prompt must never contain

If those rules are already in the guide, do not restate them in the live prompt.

### Default prompt

Use the explicit form. Name every document CLI must read and the output path for the plan.

```bash
claude "Read CLAUDE.md, then <stack-context-path>, then <phase-spec-path>. Generate a fresh implementation plan for this phase and write it to <phase-plan-path>."
```

Example:

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/work/v1-auth/specification.md. Generate a fresh implementation plan for this phase and write it to docs/work/v1-auth/implementation-plan.md."
```

This is the default because it requires no inference. CLI reads exactly what you name, in the order you name it, and writes the plan to the path you specify.

#### Default means default

If the user asks for:
- “just the prompt”
- “the Claude command”
- “the default prompt”
- “the repo-native prompt”
- or equivalent phrasing

then return only the explicit default prompt form adapted to the current phase paths.

Do not add:
- commentary
- rationale
- gap language
- regeneration language
- extra instructions
- “helpful” safety text

unless the user explicitly asks for a customized prompt.

### Short prompt

Use this only after you have confirmed that your `CLAUDE.md` is strong enough to resolve the stack context path, the phase spec path, and the plan output path without help.

```bash
claude "Read CLAUDE.md and generate a fresh implementation plan for phase <phase-dir>."
```

Example:

```bash
claude "Read CLAUDE.md and generate a fresh implementation plan for phase docs/work/v1-auth."
```

If CLI generates a plan that misses the stack context, uses the wrong spec, or writes the plan to the wrong location, switch back to the default prompt. The short form is a convenience, not a requirement.

### What the prompt must never do

- Restate the spec's scope, constraints, or decisions — that belongs in the spec.
- Restate plan shape rules — those belong in `CLAUDE.md` and the spec's Implementation Sequencing Constraints section.
- Add step-specific instructions — those belong in the spec or in the step execution prompt, not in the plan generation prompt.
- Do not inline gap-handling or regeneration rules that are already covered by this guide.
- Do not add “derive from the spec only” to the live prompt when this guide already governs plan construction.
- Do not add extra source documents unless the authority stack or current phase clearly requires them.
- Do not substitute an “improved” prompt for the default prompt unless the user explicitly asks for customization.

### Regeneration prompt

When regenerating a plan after a spec update (e.g., an implementation-time gap resolution), use the same default prompt. The spec has already been updated. Claude CLI reads the current spec and produces a plan that reflects the current decisions.

### When customization is allowed

Customize the default prompt only when at least one of these is true:

1. The user explicitly asks for a customized or stricter prompt.
2. The phase clearly touches an authority artifact beyond the default pair, such as:
   - `docs/architecture/domain.md`
   - `docs/architecture/project-architecture.md`
3. `CLAUDE.md` is known to be insufficient for path resolution and the user wants a short prompt alternative.
4. The user is asking for a regeneration prompt after the spec has already changed.

When customizing:
- keep the prompt short
- only add artifacts with clear authority relevance
- do not restate rules already defined in this guide

## Response discipline for prompt requests

When answering a request for a Claude CLI prompt:

1. Prefer the default explicit prompt.
2. If the user asked for only the prompt, return only the command.
3. If there are multiple plausible artifact sets, prefer the minimum set required by the authority stack.
4. Explain deviations from the default prompt only if the user asks why.
5. Never add planning-policy text to compensate for uncertainty. Fix the artifact or ask for clarification instead.

## Summary

The spec carries the decisions. The plan carries the order, dependency visibility, comment work, and verification-step structure. Step-completion reports provide evidence. Durable facts discovered in execution are promoted back into the authoritative artifacts so later planning does not guess.
