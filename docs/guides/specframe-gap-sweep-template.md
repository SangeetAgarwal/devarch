# SpecFrame Gap Sweep — Inventory Template

The inventory is the distinguishing artifact of a Gap Sweep. It is the spec for the sweep, framed as findings and decisions rather than feature requirements. Without an inventory, a sweep is ad-hoc fixing and loses the methodology benefit.

Suggested path:

```
docs/work/v<version>-<trigger>-gap-sweep/inventory.md
```

The inventory is then promoted into `specification.md` in the same folder. Some teams keep them as separate documents (inventory captures findings, specification captures the resolved decisions); others merge them. Both are valid. This template treats them as one document.

For the structural and workflow context, see `specframe-gap-sweep.md`.

---

# Gap Sweep — `<trigger>-gap-sweep`

## Trigger

State explicitly which trigger fired this sweep. If multiple triggers stacked up, list them in order.

- _e.g., Verification of Phase 2c (Live Track) revealed a Self-Paced CTA inconsistency that no single phase spec owns. Pre-launch is also approaching._

## Sweep Scope

One paragraph describing the scope of this sweep. The scope answers: which surfaces (UI, integration, domain object) does this sweep address, and which are explicitly excluded?

- _Surfaces in scope:_
- _Surfaces explicitly out of scope (deferred to a future sweep or new feature phase):_

## Inventory of Findings

Every finding from every source, before triage. Numbered for stable reference in decisions and the implementation plan.

| # | Finding | Source | Affected Phase(s) | Severity |
|---|---|---|---|---|
| 1 | _Brief description_ | _ux-observations.md / verification report / monitoring / chat / intuition_ | _e.g., 2a, 2b_ | _high / medium / low_ |
| 2 | | | | |

**Severity guide:**

- **High** — visible to users, blocks a flow, or creates data integrity risk.
- **Medium** — visible to users but does not block, or creates ambiguity in the artifact stack.
- **Low** — internal inconsistency only, or polish.

## Decisions

For each numbered finding, record the resolution. Resolutions are one of three kinds:

- **Resolve in this sweep** — record the corrected behavior and which artifacts will be edited.
- **Defer to a future sweep** — record why deferred (out of scope, requires further investigation, depends on unmade decision, etc.).
- **Reject as not-a-gap** — record why the current behavior is intentional and the spec is correct as-is.

```markdown
### Finding 1: <short title>

**Resolution:** Resolve in this sweep.

**Corrected behavior:** _Describe what the system should do, framed as a spec extract._

**Artifacts to edit:**
- `docs/work/<phase>/specification.md` — _what changes_
- `docs/architecture/domain.md` — _what changes (if applicable)_

**Sweep tag:** `_(<phase-letter>-gap-sweep: <one-line reason>)_`
```

```markdown
### Finding 2: <short title>

**Resolution:** Defer to a future sweep.

**Reason for deferral:** _e.g., requires a domain decision the practitioner has not made yet; not blocking; revisit at pre-launch sweep._

**Tracking:** _e.g., remains in `ux-observations.md` for now._
```

```markdown
### Finding 3: <short title>

**Resolution:** Reject as not-a-gap.

**Reason:** _e.g., the current behavior is intentional per ADR-007; spec is correct; flagged finding was a misunderstanding of the design._
```

## Map of Touched Artifacts

A flat list of every spec, plan, or architectural artifact that this sweep will modify. Derived from the resolved decisions above. The implementation plan will be ordered against this list.

| Artifact | Phase | Reason for edit (links to finding #) |
|---|---|---|
| `docs/work/<phase>/specification.md` | | _Finding #1_ |
| `docs/work/<phase>/specification.md` | | _Finding #2_ |
| `docs/architecture/domain.md` | — | _Finding #3_ |
| `docs/architecture/project-architecture.md` | — | _Finding #4_ |
| `CLAUDE.md` | — | _Finding #5 (durable rule)_ |

## Out of Scope (Explicit)

List items that are deliberately not in this sweep. Includes deferred findings (from the Decisions section) and any items that were considered and rejected as belonging to a future feature phase rather than a sweep.

- _Finding 2 — deferred to pre-launch sweep_
- _Polish item: confirmation page auto-poll — not gap, queued for Phase 3a_
- _Dashboard expansion — feature work, scoped to Phase 3a_

## Cross-Cutting Patterns Observed

After completing the inventory, note any patterns that suggest weaknesses in the methodology itself. These feed the project's lessons-learnt folder and may suggest updates to specification templates, CLAUDE.md construction guidance, or domain conventions.

- _e.g., Three out of seven findings related to the program page CTAs not having a defined state machine. The specification template's "User-Facing Behavior" section should require a CTA state table for any page with multiple authenticated states._
- _e.g., Two out of seven findings related to error UX being undefined. Add an "Error UX Contract" section to the specification template for any phase that introduces a route action._

## Trigger for Next Sweep

If this sweep is closing under one trigger but other triggers are also visible, note them so the next sweep is anticipated.

- _e.g., This sweep closes under verification-trigger. Pre-launch sweep is anticipated within the next two phases — track the polish backlog explicitly._

## Done Criteria

- All findings classified as "Resolve in this sweep" have corresponding spec edits in the implementation plan.
- All deferred findings have a recorded reason and a tracking location.
- All rejected findings have a recorded reason.
- The implementation plan sequences spec edits before code changes.
- The implementation plan includes a final verification step that walks the inventory.
- Cross-cutting pattern observations are recorded for lessons-learnt promotion.
