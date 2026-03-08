# DevArch Philosophy

## Core Principle

Generating code is cheap. Trusting it is where the work is. The specification is how you get there.

DevArch treats the artifact set as the primary deliverable. Code is downstream of the artifacts.

---

## Artifact Stack

1. `CLAUDE.md` — repo operating contract
2. `docs/architecture/stack-context.md` — runtime and stack truth
3. `docs/work/<phase>/specification.md` — phase scope, contracts, sequencing, done criteria
4. `docs/work/<phase>/implementation-plan.md` — ordered execution derived from the spec
5. `docs/context/<phase>/step-completions/` — execution evidence
6. `docs/context/<phase>/gaps/` — durable gap evidence when needed

Promote durable truth upward. Evidence does not replace authoritative artifacts.

---

## Planning Principle

The specification is the source of truth.

If plan generation would require guessing:
1. tighten the spec first
2. then generate the plan from the revised spec

The plan does not invent scope, contracts, routes, environment values, or verification.

---

## Execution Principle

Run one numbered step per session.

A step is not complete until:
- required code/doc changes are made
- required verification is run
- the step-completion artifact is written
- any discovered durable facts are written back into the authoritative artifact set when needed

---

## Human Steps Principle

Human steps are listed once at the beginning of the implementation plan.

They are not numbered implementation steps.
They are not repeated as embedded pause sections throughout the plan.

Later runtime steps reference the human steps they depend on.

---

## Gap Resolution Principle

Gaps surface in two places:
- during plan generation
- during execution, including during human/manual work

The rule is the same:

1. stop the affected step
2. record the finding as evidence
3. update the specification first
4. update the plan if execution changed
5. update stack context or `CLAUDE.md` if the finding is broader than the phase
6. resume from the first impacted step

---

## Human-Discovered Runtime Constraints

Human/manual work is a discovery surface.

If a human step reveals a durable runtime constraint — for example:
- HTTPS is required locally
- a provider requires an exact callback pattern
- a certificate trust issue changes runtime prerequisites
- an environment or secret contract is incomplete
- a baseline dependency was assumed but not captured

that finding must be promoted into the authoritative artifacts.

This is not a side note. It is a first-class DevArch gap.

---

## Artifact Write-Back Rule

Step-completion files and gap notes are evidence, not the final home of durable truth.

If execution reveals a durable fact that later work depends on, promote it into:
- the spec
- the implementation plan if execution changes
- the stack context if runtime truth changes
- `CLAUDE.md` or DevArch guides if the process rule is reusable

---

## Comment Policy Principle

Comments are part of implementation trust.

Required comments explain:
- contracts
- invariants
- trust boundaries
- provider quirks
- non-obvious implementation choices

Comments do not narrate obvious code.

---

## Completion Principle

A step or phase is not complete merely because code exists.

Completion requires:
- verified behavior
- surfaced human tasks
- honest gap reporting
- artifact consistency
- evidence written to the repo
