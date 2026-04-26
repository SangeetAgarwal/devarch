# SpecFrame Gap Sweep: The Inter-Phase Variant of Gap Analysis

## The shift in scope

SpecFrame's existing gap analysis (`specframe-gap-refresh-flow.md`, the **Gap resolution** section of `specification.md`, and the **Implementation-time gaps** section of `specframe-philosophy.md`) all assume a single phase. A gap is discovered while planning or executing one phase; one specification gets updated; one plan gets regenerated; execution resumes from one impacted step. That intra-phase loop is the heart of the methodology and is where most gaps will be caught.

Some gaps are not caught there. They surface only **between phases**, or **after multiple phases ship together**, or during **manual verification or live use** when no step is currently executing. These gaps are structurally different:

- The "affected step" is plural across multiple phases — sometimes phases that shipped weeks or months apart.
- The "specification to update" is plural — two or three prior specs each need edits, and sometimes a cross-cutting artifact (`domain.md`, `project-architecture.md`) too.
- There is no current step to "resume from." A new phase folder has to be created to hold the work.
- The trigger is not the LLM saying "I cannot proceed." The trigger is a human (or the LLM, during verification) noticing that two phases that each shipped coherent-internally have produced an incoherent union.

The intra-phase gap loop cannot absorb this without distorting. If you try to fold inter-phase gaps into "the next feature phase," that feature phase ends up dragging unrelated cross-cutting work, the spec balloons, the plan loses focus, and the methodology's spec-as-source-of-truth discipline degrades into "fix-it-as-you-go."

A **Gap Sweep** is the deliberate phase that addresses this class of gap. Same sentiment as intra-phase gap resolution, but the scope is the whole artifact stack rather than one spec.

## When to run a Gap Sweep

Triggered, not scheduled. Time-based cadences ("every quarter") either get skipped under deadline pressure or run hollow when there is nothing to sweep. Triggers map to actual signals that drift has crossed phase boundaries:

| Trigger | Why it fires |
|---|---|
| **Cross-phase inconsistency surfaces during verification or use.** | Two phases each behave correctly per their own specs but contradict each other on a shared surface (UI page, domain model, error contract). No single phase spec owns the corrected behavior. |
| **Two or more phases ship that touch the same UI surface, integration, or domain object.** | Shared surfaces accumulate the most drift. Sweeping after the second or third phase that touches the same area is cheaper than sweeping after the fifth. |
| **Pre-launch, pre-public-release, or pre-new-audience.** | Drift visible only to the builder is acceptable; drift visible to a stranger costs reputation. Run a sweep at every "first contact with new users" boundary. |
| **The UX observation backlog or known-issues list exceeds a small threshold (typically 5 items).** | Past a certain count, individual items stop getting individually addressed. A sweep batches them with a single discipline pass. |
| **A planning-time gap reveals that prior specs are also incomplete on the same point.** | If you start a new phase and discover the new spec needs a decision the previous phase silently made differently, that previous phase has a latent gap too. Sweep before continuing the new phase. |

Any single trigger is sufficient. Multiple triggers stacking up is a signal the sweep is overdue.

## Naming convention

A Gap Sweep is structurally a phase, but its kind differs from a feature phase. The phase letter must communicate the kind.

```
<version>-<trigger-phase>-gap-sweep
```

The trigger phase is the most recent feature phase whose completion (or whose discovered gaps) fired the sweep. For milestone-triggered sweeps, use the milestone name instead of a phase letter.

| Phase letter (in CLAUDE.md table) | Folder | Meaning |
|---|---|---|
| `2c-gap-sweep` | `v1-2c-gap-sweep` | Sweep at end of phase 2c |
| `3a-gap-sweep` | `v1-3a-gap-sweep` | Sweep at end of phase 3a |
| `pre-launch-gap-sweep` | `v1-pre-launch-gap-sweep` | Sweep before public launch |
| `pre-v2-gap-sweep` | `v1-pre-v2-gap-sweep` | Sweep before starting v2 |

The phase letter identifies **when the sweep happened**, not what it covers. The inventory document inside the folder enumerates the spans. Naming after coverage (`v1-program-page-gap-sweep`) is tempting but misleads readers, because most sweeps touch more than one surface and the spans are best discovered by reading the inventory.

The mirror between phase letter and folder name (`2c-gap-sweep` ↔ `v1-2c-gap-sweep`) makes the CLAUDE.md phase table self-explanatory:

```markdown
| Phase           | Directory          |
| --------------- | ------------------ |
| 1               | v1-foundation      |
| 2a              | v1-auth            |
| 2b              | v1-checkout        |
| 2c              | v1-fulfillment     |
| 2c-gap-sweep    | v1-2c-gap-sweep    |
| 3a              | v1-dashboard       |
```

A reader scanning that table sees three things at a glance: the order of work, the kind of each phase, and the trigger for each sweep. The convention generalizes — feature phases use positional letters, gap sweeps append the type marker after the trigger.

## Artifact set

A Gap Sweep produces the same artifacts as a feature phase — the inputs differ, but the discipline is the same:

| Artifact | Path | Role in a Gap Sweep |
|---|---|---|
| Inventory | `docs/work/v<version>-<phase-letter>/inventory.md` | New artifact unique to sweeps. Enumerates findings from all sources, classifies, decides scope. |
| Specification | `docs/work/v<version>-<phase-letter>/specification.md` | The inventory IS the spec, framed as "gaps to resolve, decisions needed, and out-of-scope items." |
| Implementation plan | `docs/work/v<version>-<phase-letter>/implementation-plan.md` | Orders the spec edits to prior phases, and any code or test changes. |
| Step completion reports | `docs/context/v<version>-<phase-letter>/step-completions/` | Same as a feature phase — one per step. |
| Step audits | `docs/context/v<version>-<phase-letter>/step-completions/step-audit-<N>.md` | Same as a feature phase. |

The distinguishing artifact is the **inventory**. See `specframe-gap-sweep-template.md` for its structure. Briefly: it records the trigger, lists every finding with classification and severity, decides each one (resolve, defer, out-of-scope), and lists the prior-phase specs that will be touched.

## The inventory step

Before any spec is edited or any plan is written, the sweep produces an inventory. This is the single most important step of the sweep — skipping or rushing it loses the methodology benefit.

The inventory step has four parts, in order:

1. **Collect.** Pull every relevant finding into one document. Sources include: existing `ux-observations.md` (or equivalent backlog), prior phase gap notes that were partially addressed, recent verification reports, manual testing notes, conversations where issues were flagged, monitoring or error reports.

2. **Classify.** For each finding, identify which prior phase(s) the finding belongs to (i.e., whose spec is silent or wrong on this point). A finding that genuinely belongs to no prior phase is a feature, not a gap — it goes in a new feature phase, not in the sweep.

3. **Decide.** For each finding, decide one of three things:
   - **Resolve in this sweep** — the finding is in scope. Record the decision (what the corrected behavior is) and which specs will be edited.
   - **Defer to a future sweep** — the finding is real but out of scope for this sweep. Record why deferred.
   - **Reject as not-a-gap** — the finding is not actually drift. The current behavior is intentional and the spec is correct as-is. Record why.

4. **Map.** List every prior-phase spec, plan, and architectural artifact that will be touched. This list becomes the basis for the implementation plan.

Without the decision step, sweeps drift into "fix everything we noticed." Without the map step, plan generation cannot scope the work.

## How a Gap Sweep differs from intra-phase gap resolution

| Dimension | Intra-phase gap resolution | Inter-phase Gap Sweep |
|---|---|---|
| Trigger | Plan generation cannot proceed, or step execution discovers a contradiction | Verification, post-deploy use, or the start of a new phase reveals drift across prior phases |
| Scope | One phase, usually one spec | Multiple prior phases, usually multiple specs |
| Discovery moment | LLM stops mid-task and surfaces the gap | Human (or LLM during verification) notices the cross-phase drift after the fact |
| Workflow entry | The blocked step in the current phase | A new phase folder with an inventory document |
| Spec changes | Edit the current phase spec | Edit prior phase specs in place |
| Plan changes | Regenerate the current plan | Generate a fresh plan that sequences the cross-phase spec edits and code fixes |
| Resume point | The first impacted step in the same phase | The first step of the new sweep phase |
| Reporting | Step completion report records the gap | Inventory + step completion reports record the sweep |

Both are gap analysis. Both keep the spec as source of truth. The only structural difference is whether the methodology is operating inside a single phase or across phases.

## Editing prior specs in place

The hardest discipline in a sweep is editing prior phase specs. The spec for a phase that shipped weeks or months ago feels frozen — touching it can feel like rewriting history. Two principles keep this clean:

1. **The spec is the current authoritative description, not a historical record.** Git history preserves what was written when. The spec on disk should always describe the current intended behavior. If the current behavior includes corrections from a sweep, the spec must reflect that.

2. **Tag corrections so they are visible.** Each spec edit made by a sweep is tagged inline with the sweep's phase letter, similar to how planning-time gaps are tagged `_(gap)_`:

   ```markdown
   ## Program Page Behavior
   
   The program page renders dynamic CTAs based on the user's
   authentication, booking, and enrollment state. _(2c-gap-sweep:
   originally documented for Live Track only; extended to Self-Paced
   to resolve cross-phase CTA inconsistency)_
   ```

   This is lightweight, doesn't bloat the spec, and gives a future reader a pointer back to the sweep that made the correction.

The original-as-shipped spec is always recoverable via git. It is intentionally not preserved as a separate file alongside the current spec — duplicating the spec history in the working tree confuses which document is authoritative.

## Workflow

A Gap Sweep follows the same per-step CLI rhythm as a feature phase. The high-level flow:

1. **Trigger fires.** Note the trigger explicitly so the sweep's scope and urgency are documented.

2. **Create the sweep phase folder.**

   ```
   docs/work/v<version>-<trigger>-gap-sweep/
   ```

3. **Run the inventory step.** Collect → Classify → Decide → Map. Produce `inventory.md`.

4. **Promote the inventory into a specification.** The inventory's resolved decisions become the spec's decisions section. The map of touched prior-phase specs becomes the spec's scope section. Out-of-scope items become the spec's out-of-scope section.

5. **Generate the implementation plan.** The plan orders:
   - prior-phase spec edits, grouped by spec
   - any cross-cutting artifact edits (`domain.md`, `project-architecture.md`, `CLAUDE.md`)
   - code changes, sequenced after the spec edits they implement
   - tests verifying the corrected behavior
   - a final verification step against the inventory

6. **Execute one step per CLI session.** Same rule as feature phases. Each step writes a step completion report.

7. **Audit each step.** Same audit discipline as a feature phase. The audit must verify both directions — that code matches the corrected spec AND that the corrected spec captures any newly observed behavior.

8. **Final verification.** Walk the inventory item by item, confirming each resolved finding is now reflected in the spec(s), the code, and the verification evidence.

## Cross-cutting artifact updates

Some sweeps touch artifacts beyond per-phase specs:

- **`domain.md`** — when a sweep resolves a domain-level question (e.g., "who owns transitioning a booking from confirmed to completed?"), update the domain model and Ubiquitous Language entry.
- **`project-architecture.md`** — when a sweep resolves an integration ownership or external-system contract issue.
- **`stack-context.md`** — when a sweep resolves a runtime contract issue revealed by the inconsistency.
- **`CLAUDE.md`** — when a sweep produces a new operating rule that should apply across all future phases. This is the "self-improving conventions" feedback loop in action.

The implementation plan should sequence these updates explicitly. They are not optional cleanup — they are the artifact write-back that makes the sweep durable.

## Connection to other SpecFrame practices

### Self-improving conventions

The pattern of findings in a Gap Sweep reveals weaknesses in the methodology itself. If multiple sweeps repeatedly surface the same kind of gap (e.g., "the spec doesn't define error UX"), that is a signal to add a section to the specification template so future phases address it upfront. Track this explicitly in the sweep's final report — note any patterns observed, and propose template or convention updates.

### Lessons learnt

A sweep's final report feeds the project's lessons-learnt folder. The lessons-learnt entry should focus on **what enabled the drift to accumulate**, not on what the corrections were. The corrections are in the specs; the lessons are about prevention.

### Audits

A step audit during a sweep has the same job as a step audit during a feature phase: verify that code matches spec in both directions. The "spec" being audited is the corrected (post-sweep) version — the audit confirms the sweep's spec edits are reflected in the code.

### Architecture decision records

If a sweep resolves a question that warrants standalone documentation (e.g., a non-obvious domain decision, a contract change with downstream implications), produce an ADR alongside the spec edit. The sweep's implementation plan should sequence ADR creation explicitly.

## Anti-patterns

**Treating the sweep as a fix-everything phase.**
A Gap Sweep is for spec drift, not feature work. New behavior that no prior spec was silent or wrong on belongs in a feature phase, not a sweep. Mixing them dilutes the discipline and bloats the scope.

**Skipping the inventory step.**
Going straight from "we noticed problems" to "let me fix them" loses the methodology benefit. The inventory is the artifact that proves the sweep was deliberate, scoped, and complete. Without it, the sweep is just ad-hoc fixing.

**Naming the phase by coverage instead of trigger.**
`v1-program-page-and-error-ux-gap-sweep` is descriptive but misleading. Most sweeps touch more than one surface, and the touched surfaces are best discovered by reading the inventory. Name by **when**, not **what**.

**Running too late.**
Pre-launch is a legitimate trigger, but if it is the only trigger that ever fires, every sweep happens under release pressure, which forces shortcuts. Sweep earlier with smaller scope when other triggers fire — verification inconsistency, two phases on the same surface, observation backlog. The pre-launch sweep then has less to clean up.

**Folding sweep work into the next feature phase.**
"We will address the program-page CTA inconsistency as part of the dashboard phase" sounds reasonable and is wrong. The dashboard spec then carries unrelated cross-cutting work, the dashboard plan is no longer cleanly derived from the dashboard spec, and the spec-as-source-of-truth discipline degrades. Create a sweep phase. Do the work in scope. Then start the dashboard phase clean.

**Editing prior specs without tagging the change.**
A spec edit that is not visibly attributed to a sweep looks (in the future) like the spec was always written that way. That hides the methodology's correction history and makes it harder for future sweeps to learn from prior ones. Always tag the edit with the sweep's phase letter.

**Scheduling sweeps on a calendar.**
"Every six weeks we run a sweep" sounds disciplined and is mostly hollow. Sweeps without a real trigger find nothing or invent findings to justify themselves. Trigger-based cadence keeps each sweep meaningful.

## A worked example (sketch)

A project ships three feature phases that each touch the program page:

- **Phase 2a** ships the Self-Paced enrollment CTA. The spec for 2a defines a static CTA: "Enroll in Self-Paced." The CTA is correct per the 2a spec.
- **Phase 2b** ships the Intro Session booking. The spec for 2b is silent on how the program page should reflect booking state.
- **Phase 2c** ships Live Track and introduces a dynamic CTA pattern that checks auth, booking, and enrollment state. The spec for 2c defines a five-state CTA for the Live Track side. The 2c spec explicitly notes "Self-Paced CTA remains unchanged."

After 2c ships, manual verification reveals: the Self-Paced CTA still shows "Enroll in Self-Paced" even when the user already has an active Self-Paced enrollment. The action backstop (a duplicate-enrollment guard) returns a 409 with a human-readable message, but the error boundary swallows the message and the user sees a generic error.

No single phase spec is wrong:

- The 2a spec did not define a dynamic CTA — that pattern did not exist yet.
- The 2c spec correctly scoped its dynamic CTA work to Live Track.
- Neither spec addressed error UX as a contract.

The drift is real and belongs to no single phase. This is a Gap Sweep trigger.

The team creates `docs/work/v1-2c-gap-sweep/`. The inventory captures three findings:

1. Self-Paced CTA does not check enrollment or auth state. Affected spec: 2a (`v1-enrollment/specification.md`).
2. Action errors are swallowed by the root error boundary. Affected specs: 2a, 2b, 2c (every spec that defines an action).
3. Booking lifecycle transition (`confirmed` → `completed`) is not specified. Affected spec: 2b (`v1-booking/specification.md`), and `domain.md`.

Decisions resolve each. The implementation plan orders the spec edits, then the code changes, then verification. Execution proceeds one step per session. The sweep closes with a final verification pass against the inventory.

After the sweep, the program page is coherent across both tracks, error UX is contracted in every action spec, and the booking lifecycle is owned by the booking spec and the domain model. None of this work belonged in the dashboard phase that follows.

## Summary

- A Gap Sweep is the inter-phase variant of gap analysis. Same sentiment as intra-phase gap resolution, applied across the whole artifact stack.
- Triggered, not scheduled. Triggers map to real signals of cross-phase drift.
- Same artifact set as a feature phase, plus a distinguishing **inventory** document.
- Phase letter mirrors folder name and uses the `<trigger>-gap-sweep` pattern so the kind of phase is visible in the CLAUDE.md table.
- Edits prior-phase specs in place, with inline tags identifying the sweep that made each edit.
- Same per-step CLI rhythm as a feature phase. Same audit discipline.
- Keeps the artifact stack coherent over time, which is what makes "spec is the source of truth" sustainable beyond the first few phases.
