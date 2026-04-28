# SpecFrame Philosophy: Specification-Driven Development in the Agentic Era

## The shift

In agentic development, code generation is cheap. Confidence that the code does what you intended is expensive.

SpecFrame moves the design burden upward into artifacts the model can read, follow, and verify:

- the specification captures intent, constraints, scope, and acceptance criteria
- the implementation plan captures execution order and verification boundaries
- step-completion reports capture what actually happened during execution
- `CLAUDE.md` carries durable operating rules

## The core claim

The specification is the highest-leverage artifact. It is simultaneously:

- input to the LLM
- design documentation
- acceptance criteria
- living documentation

Everything else serves the specification.

## The SpecFrame flow

```text
Domain Discovery → PRD → Specification → Implementation Plan → Build → Verify
                                ↑                    ↓             ↓
                          Gap Resolution        Execution     Step Evidence
```

The PRD remains the upstream artifact — product intent captured for human stakeholders. SpecFrame doesn't replace it; the specification is added downstream as the LLM-readable directive. There's no substitute for a well-written PRD, agentic development or otherwise.

## Artifact roles

Each artifact has a different job:

- **CLAUDE.md** — repo-wide operating contract and durable rules
- **stack-context.md** — runtime truth: framework versions, environment contracts, provider quirks
- **domain.md** — Ubiquitous Language, domain model, and bounded-context boundaries
- **project-architecture.md** — integration ownership, external-system responsibilities, and phasing map
- **Specification** — authoritative scope, contracts, decisions, prerequisites, baseline dependencies, done criteria
- **Implementation plan** — ordered execution, step dependencies, verification sequence, comment obligations
- **Step-completion reports** — evidence of what changed, why, what passed, and what was blocked

A complete SpecFrame review often needs all four.

## Evidence is not authority

A step-completion report is evidence, not the long-term source of truth.

This distinction matters when a later phase depends on an earlier artifact that was created during execution but never promoted into the main artifact set.

Example pattern:

1. a helper such as `app/lib/ulid.ts` is created in an earlier phase
2. the change is documented in a step-completion report
3. a later phase depends on that helper
4. if the helper is not written back into the current spec or plan, later review may falsely treat it as an invention or hidden assumption

The SpecFrame rule is:

**discover in execution → verify in evidence → promote into authoritative artifacts**

## Gap resolution

Gaps surface at two points:

### Planning-time gaps

The specification is incomplete for plan generation.

Workflow:

1. stop plan generation
2. update the specification
3. regenerate the plan

### Implementation-time gaps

Execution reveals a contradiction, missing decision, missing baseline dependency, or runtime behavior the spec did not capture.

Workflow:

1. stop the step
2. record the gap in the step completion report
3. update the specification first
4. regenerate the plan if behavior, sequencing, scope, or baseline dependencies changed
5. re-execute the blocked step in a new session

### Inter-phase gaps (Gap Sweep)

Verification, post-deploy use, or the start of a new phase reveals drift across multiple prior phases — phases that each shipped coherent-internally but together produced an incoherent union. No single prior phase spec is wrong; the drift belongs to no one of them.

This is a structurally different gap. There is no current step to resume from. The "spec to update" is plural — two or three prior specs each need edits, and sometimes a cross-cutting artifact (`domain.md`, `project-architecture.md`, `CLAUDE.md`) too. The trigger is not the LLM saying "I cannot proceed." The trigger is a human or LLM noticing the drift after the fact.

The intra-phase loop above cannot absorb this without distorting. Folding inter-phase gaps into the next feature phase bloats that phase's spec, breaks the spec-as-source-of-truth discipline, and leaves the cross-cutting drift hidden.

Workflow:

1. create a new phase folder named `<trigger>-gap-sweep` (e.g., `2c-gap-sweep`, `pre-launch-gap-sweep`)
2. produce an inventory document — collect every finding, classify, decide each one (resolve, defer, reject), map every prior-phase spec that will be touched
3. promote the inventory into the sweep's specification
4. generate an implementation plan that orders the spec edits, the cross-cutting artifact edits, and the code changes
5. execute one step per CLI session, same rhythm as a feature phase
6. tag each prior-spec edit inline with the sweep's phase letter, e.g., `_(2c-gap-sweep: extended to Self-Paced)_`

See `specframe-gap-sweep.md` for the full mechanics.

## Artifact write-back

If execution reveals a durable, load-bearing fact that later work depends on, SpecFrame requires writing it back into the authoritative artifact set.

Promote it to the right place:

- **specification** for dependencies, contracts, invariants, prerequisites, and baseline capabilities
- **implementation plan** for sequencing changes and step-level dependency visibility
- **step-completion report** remains the provenance record

This keeps future planning from guessing and keeps the main artifact set aligned with what the repo actually depends on.

## Why this matters

Without write-back, the methodology drifts:

- the spec describes only original intent
- the plan describes only one moment in time
- the step report becomes the hidden place where critical truths live

That weakens trust.

With write-back:

- the spec stays authoritative
- the plan stays execution-relevant
- the step reports stay evidentiary
- future phases inherit a trustworthy baseline

## Practical summary

SpecFrame is not just “spec first.” It is:

- spec first
- plan derived from spec
- execution verified step by step
- intra-phase gaps resolved by updating the spec first
- inter-phase drift resolved by deliberate Gap Sweeps that edit prior specs in place
- durable execution discoveries promoted back into the main artifacts

That is how the artifact stack stays aligned with reality instead of freezing at the moment the first spec was written.
