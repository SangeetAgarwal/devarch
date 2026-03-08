# DevArch: Claude CLI Execution Notes and Lessons Learned

This note captures a reusable pattern for running DevArch implementation steps with Claude CLI after the
specification and implementation plan are already in place.

The goal is simple:

- keep the live prompt minimal
- keep the specification authoritative
- keep step boundaries meaningful
- keep completion evidence durable

## Recommended artifact pattern

Default artifacts:

- `specification.md` - source of truth for scope, constraints, decisions, and gaps
- `implementation-plan.md` - ordered execution path with verification gates
- `step completion report` - a first-class execution artifact, stored in two places:
  - printed in Claude session output, and
  - written to a per-step markdown file in the repo

Recommended path:

- `docs/context/step-completions/step-completion-<NN>.md`

Rule of thumb:

- If it changes scope, behavior, naming, constraints, or decisions, update the spec first.
- If it changes execution order or verification sequencing, update the implementation plan.
- If it records what happened during execution, it belongs in the step completion report file.

## Prompt pattern

Default pattern:

- use one generic step command for most steps
- keep step detail in the implementation plan
- keep meta rules in `CLAUDE.md`
- keep stack rules in `docs/architecture/stack-context.md`

Exception pattern:

- add a step-specific line only when drift risk, human prerequisites, or high-value reminders justify it

This keeps prompts reusable, cheaper, and less directive-heavy.

## Prompt layering

Prefer this order of authority:

1. `CLAUDE.md`
2. `docs/architecture/stack-context.md`
3. active phase `specification.md`
4. active phase `implementation-plan.md`
5. live Claude CLI prompt

The live prompt should be minimal.

## One-step-per-session protocol

- Run exactly one implementation-plan step per Claude session.
- After the step is verified and the completion report is satisfactory, manually run `/exit`.
- Start the next step in a new Claude CLI session.
- Do not continue into the next implementation-plan step in the same session, even if the previous step completed successfully.

This hygiene rule reduces context drift and keeps each step boundary real.

## Step completion report is a first-class artifact

At the end of every step, Claude should produce a structured report and persist it to a per-step file.

Required sections:

1. Files generated, modified, and deleted
2. Commands run
3. Verification results
4. Stack-context compliance checks
5. Runtime readiness
6. Human/manual setup (new vs previously known)
7. Scope drift
8. Work introduced early from later steps
9. Spec gaps encountered

## Big lessons learned so far

1. Persist step completion reports to a predictable file path.
2. Build success and runtime readiness must be separated.
3. Use “No new human/manual setup introduced by this step”.
4. Keep the live prompt minimal.
5. Use a generic step prompt by default.
6. Step-specific wording should be the exception, not the norm.
7. Scope drift should be reported explicitly.
8. One step per session is worth keeping.
9. Start a fresh Claude CLI session after every `/exit`.
10. Avoid machine-specific details in step reports.
11. State trust assumptions when HTML is rendered from markdown or content.
12. Focus guidance on failure modes that threaten correctness, trust, or debuggability.
13. Ignore cosmetic nits until they become operationally expensive.
14. Check step completion reports before asserting a cross-phase dependency is missing.
15. Implementation-time gaps follow the same invariant as planning-time gaps: update the spec first, then regen the plan if behavior changed.

## Platform lessons from Cloudflare setup

1. Local and remote D1 are separate.
   - `--remote` setup does not fix local `npm run dev`.
   - local dev may still need:
     - `wrangler d1 migrations apply ... --local`
     - `wrangler d1 execute ... --local`

2. `wrangler types` should be rerun only after `wrangler.jsonc` changes.
   - not after `.dev.vars`
   - not after `wrangler secret put`

3. Framework-generated deploy config matters.
   - in projects that generate deploy config during build, raw `wrangler deploy` can use stale output
   - prefer the repo deploy script when that script rebuilds first

4. Manual platform setup should be staged.
   - get one successful manual deploy first
   - then add GitHub auto-deploy

5. Keep infrastructure setup aligned with actual project needs.
   - extra services are fine if they are intentional
   - but treat them as platform dependencies, not accidental blockers

## Cross-phase artifact verification

When a later phase references an artifact from an earlier phase — a helper module, a migration, a configuration file — the reviewer's instinct is to check the earlier phase's spec and implementation plan. If the artifact doesn't appear there, the reviewer may conclude it doesn't exist and raise a false alarm.

Step completion reports prevent this.

### The pattern that fails

1. Phase 2 implementation plan references `app/lib/ulid.ts` as "existing."
2. Reviewer checks Phase 1 spec, remediation spec, and mobile nav fix spec. None mention `ulid.ts`.
3. Reviewer asserts the file doesn't exist and recommends adding it to the plan.
4. The file does exist — it was created during Phase 1 execution and documented in the Phase 1 step completion report.

The reviewer had access to the specs but not the step completion reports. The specs describe what to build. The step completion reports describe what was actually built. These are different artifacts with different purposes.

### The pattern that works

Before asserting a cross-phase dependency is missing:

1. Check the relevant phase's step completion reports — these are the durable record of what was actually created.
2. If no step completion report is available, ask whether the artifact exists rather than asserting it doesn't.
3. If the artifact does exist, note where it was created so the reference in the current plan is traceable.

### Why this matters for DevArch training

This is one of the first things to teach someone learning DevArch: the spec says what to build, the plan says in what order, and the step completion reports say what actually happened. All three are needed for a complete picture. Reviewing only the spec and plan gives you intent. Reviewing the step completion reports gives you ground truth.

This also demonstrates why step completion reports are first-class artifacts, not optional paperwork. Without them, cross-phase reviews require checking the file system directly — which breaks down when the reviewer doesn't have repo access (for example, when reviewing in a chat session with Claude).

## Bugfix slice pattern

A targeted bug fix should usually be handled as a bounded slice, not a new numbered implementation-plan step.

Recommended flow:

- start a fresh Claude session
- point at the relevant spec/plan/completion reports
- ask for root cause plus smallest correct fix
- verify the fix
- persist a bugfix completion report

This keeps post-phase corrections auditable without distorting the original phase plan.
