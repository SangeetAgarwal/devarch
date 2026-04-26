# SpecFrame Gap Refresh Flow

> **Scope of this guide:** the **intra-phase** gap refresh — when a gap is discovered during planning or execution of a single phase. For gaps that span multiple prior phases (drift discovered during verification or post-deploy use), see `specframe-gap-sweep.md`. Both are gap analysis; the difference is whether the resolution edits one phase spec or several.

## Standard Flow

When a human or Claude discovers a durable gap during planning or execution of a single phase:

1. stop the affected step
2. record the finding in the step-completion artifact
3. create a gap note if the issue is larger than a brief note
4. update the spec first
5. update stack context if runtime truth changed
6. update domain.md if Ubiquitous Language, domain model, or bounded-context truth changed
7. update project-architecture.md if integration ownership, external-system responsibilities, or phasing truth changed
8. regenerate the implementation plan if execution order, dependencies, or verification changed
9. resume from the first impacted step

---

## Minimal Claude CLI Prompt for Gap Refresh

```bash
claude "Read CLAUDE.md, docs/architecture/stack-context.md, docs/architecture/domain.md, docs/work/<phase>/specification.md, docs/work/<phase>/implementation-plan.md, and docs/context/<phase>/gaps/gap-<short-name>.md. A durable gap was discovered during execution. Update the specification first. If execution order, prerequisites, environment contracts, local runtime contracts, or verification change, regenerate the implementation plan from the revised spec. Update stack context if runtime truth changed, domain.md if domain or Ubiquitous Language truth changed, and project-architecture.md if integration ownership or phasing truth changed. Keep the artifact set in sync."
```

---

## When to Resume

Resume from the first impacted numbered step.

Do not restart the entire phase unless the revised spec invalidates nearly all later work.

---

## When This Flow Doesn't Apply

If the gap belongs to no current step — for example, it surfaces during manual verification, post-deploy use, or while reading code from a phase that shipped weeks ago, and the corrected behavior would require edits to two or more prior phase specs — this intra-phase flow is the wrong tool. There is no current step to resume from, and editing prior specs ad hoc bypasses the spec-as-source-of-truth discipline.

For that case, run a **Gap Sweep** — a deliberate inter-phase phase that inventories cross-phase findings, decides each one, edits affected prior specs in place (tagged with the sweep's phase letter), and sequences the work into a fresh implementation plan. See `specframe-gap-sweep.md`.
