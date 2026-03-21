# SpecArc: Claude CLI Execution Notes and Lessons Learned

This note captures reusable patterns for running SpecArc implementation steps with Claude CLI after the specification and implementation plan are already in place.

## Recommended artifact pattern

Default artifacts:

- `specification.md` — source of truth for scope, constraints, decisions, baseline dependencies, and gaps
- `implementation-plan.md` — ordered execution path with verification gates
- `step completion report` — a first-class execution artifact, stored in two places:
  - printed in Claude session output, and
  - written to a per-step markdown file in the repo

Recommended path:

- `docs/context/<phase>/step-completions/step-completion-<N>.md`

Rule of thumb:

- If it changes scope, behavior, naming, constraints, or decisions, update the spec first.
- If it changes execution order, dependency visibility, or verification sequencing, update the implementation plan.
- If it records what happened during execution, it belongs in the step completion report file.
- If a durable baseline dependency is discovered or confirmed during execution, promote it into the spec and, when relevant, the plan.

## Prompt pattern

Default pattern:

- use one generic step command for most steps
- keep step detail in the implementation plan
- keep meta rules in `CLAUDE.md`
- keep stack rules in `docs/architecture/stack-context.md`

Exception pattern:

- add a step-specific line only when drift risk, human prerequisites, or high-value reminders justify it

## One-step-per-session protocol

- Run exactly one implementation-plan step per Claude session.
- After the step is verified and the completion report is satisfactory, manually run `/exit`.
- Start the next step in a new Claude CLI session.
- Do not continue into the next implementation-plan step in the same session.

## Step completion report is a first-class artifact

At the end of every step, Claude should produce a structured report and persist it to a per-step file.

Required sections:

1. Status
2. What Changed
3. Why
4. Verification
5. Gaps / Blockers / Unresolved Items
6. Spec Gaps Encountered
7. Artifact Write-Back Required
8. Evidence

## Big lessons learned so far

1. Persist step completion reports to a predictable phase-specific file path.
2. Build success and runtime readiness must be separated.
3. Use “No new human/manual setup introduced by this step” when true.
4. Keep the live prompt minimal.
5. Use a generic step prompt by default.
6. Step-specific wording should be the exception, not the norm.
7. Scope drift should be reported explicitly.
8. One step per session is worth keeping.
9. Start a fresh Claude CLI session after every `/exit`.
10. Avoid machine-specific details in step reports.
11. Focus guidance on failure modes that threaten correctness, trust, or debuggability.
12. Check step completion reports before asserting a cross-phase dependency is missing.
13. Implementation-time gaps follow the same invariant as planning-time gaps: update the spec first, then regenerate the plan if behavior changed.
14. A durable fact that lives only in a step-completion report is still too hidden if future phases depend on it.
15. Promote load-bearing cross-phase dependencies into the main artifacts once they become part of the trusted baseline.

## Cross-phase artifact verification

When a later phase references an artifact from an earlier phase — a helper module, a migration, or a configuration file — do not assume the current spec or old implementation plan will always mention it.

Review order:

1. check the relevant earlier step-completion reports for evidence of what was actually created
2. if the artifact exists and is load-bearing for later work, promote it into the current spec as a baseline dependency
3. if it affects step execution, surface it in the current implementation plan as well
4. keep the original step-completion report as the provenance record

This is the rule that prevents a helper like `app/lib/ulid.ts` from being real in the repo but invisible in the main artifact set.
