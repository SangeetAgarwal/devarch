# SpecFrame Gap Note Template

Use for larger human-discovered or execution-discovered gaps within a single phase. The gap belongs to the current phase's spec; one spec gets updated; one plan gets regenerated; execution resumes from one impacted step.

For gaps that span multiple prior phases (drift discovered between phases, during verification, or in post-deploy use, where two or more prior specs need edits and there is no current step to resume from), use the inventory template in `specframe-gap-sweep-template.md` instead. Both are gap analysis; the difference is whether one spec or several need to be touched.

Suggested path:

`docs/context/<phase>/gaps/gap-<short-name>.md`

---

# Gap — <short title>

## Discovered During

- Phase:
- Numbered Step:
- Related Human Step(s):

## What Happened

- Clear description of the observed issue

## Why It Matters

- Contract impact:
- Runtime impact:
- Verification impact:
- Sequencing impact:

## Durable Finding

- The new rule or constraint that should be promoted into the authoritative artifacts

## Impacted Artifacts

- `docs/work/<phase>/specification.md`
- `docs/work/<phase>/implementation-plan.md`
- `docs/architecture/stack-context.md`
- `docs/architecture/domain.md`
- `docs/architecture/project-architecture.md`
- `CLAUDE.md`
- other:

## Evidence

- Commands run:
- Exact error or observed behavior:
- Environment values involved:
- Notes/screenshots:
