# DevArch Gap Refresh Flow

## Standard Flow

When a human or Claude discovers a durable gap:

1. stop the affected step
2. record the finding in the step-completion artifact
3. create a gap note if the issue is larger than a brief note
4. update the spec first
5. update stack context if runtime truth changed
6. regenerate the implementation plan if execution changed
7. resume from the first impacted step

---

## Minimal Claude CLI Prompt for Gap Refresh

```bash
claude "Read CLAUDE.md, docs/architecture/stack-context.md, docs/work/<phase>/specification.md, docs/work/<phase>/implementation-plan.md, and docs/context/<phase>/gaps/gap-<short-name>.md. A durable gap was discovered during execution. Update the specification first. If execution order, prerequisites, environment contracts, local runtime contracts, or verification change, regenerate the implementation plan from the revised spec. Update stack context or repo guidance too if the finding changes broader runtime or DevArch rules. Keep the artifact set in sync."
```

---

## When to Resume

Resume from the first impacted numbered step.

Do not restart the entire phase unless the revised spec invalidates nearly all later work.
