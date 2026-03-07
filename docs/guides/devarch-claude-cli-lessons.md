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

## Bugfix slice pattern

A targeted bug fix should usually be handled as a bounded slice, not a new numbered implementation-plan step.

Recommended flow:

- start a fresh Claude session
- point at the relevant spec/plan/completion reports
- ask for root cause plus smallest correct fix
- verify the fix
- persist a bugfix completion report

This keeps post-phase corrections auditable without distorting the original phase plan.
