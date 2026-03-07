# Claude CLI Step Execution for DevArch

This guide explains how to execute a DevArch specification and implementation plan using Claude CLI while keeping:

- accuracy high: no invented scope, no guessed decisions
- token cost low: short prompts that reference authoritative repo docs

It standardizes a **step completion report** as a durable checkpoint:

- Claude prints it in session output, and
- Claude writes the same report to a per-step markdown file in the repo.

## Prerequisites

Before you start Claude CLI execution, you should have:

- A phase specification  
  Defines scope, constraints, acceptance criteria, and done criteria.
- A phase implementation plan  
  Breaks work into ordered steps with verification gates.
- A stack context document  
  Captures runtime constraints, forbidden APIs, required commands, and stack-specific patterns.
- A repo agent contract  
  For example, `CLAUDE.md`. This contains stable rules such as: spec is source of truth, stop on gaps, do not build ahead.

## Execution protocol

### One step per session

- Run exactly one implementation-plan step per Claude session.
- After verification passes, manually type `/exit` in Claude CLI.
- Start the next step in a **new Claude CLI session**.
- Do not continue multiple implementation-plan steps in the same session, even if the previous step completed successfully.

This keeps each step atomic, reduces context drift, and prevents the agent from carrying unverified assumptions into the next step.

### Persist a step completion report

For every step, Claude must:

1. print a structured completion report in the session output, and
2. write the same report to a per-step file.

This gives you an audit trail even if terminal history is lost.

## Non-negotiable rules

### 1) The spec is the source of truth

Claude must not introduce new scope, naming, routes, schema, behavior, security policies, or config beyond what the spec states.

### 2) Stop on gaps

If Claude encounters ambiguity, missing decisions, unstated constraints, or contradictions across docs, it must:

- stop
- report the exact gap
- say what must be added to the spec before implementation continues

Do not let the agent guess.

### 3) Do not build ahead

Claude implements only the requested step and then stops.

### 4) Verify before claiming completion

A step is complete only when the required verification has been run and reported with evidence.

## Step completion report file

Store step reports under a predictable path. Recommended:

- `docs/context/step-completions/step-completion-<NN>.md`

Rules:

- Keep it concise: no full diffs, no raw build logs, no screenshots.
- Avoid machine-specific absolute paths.
- The step report file is allowed to change as part of the step and should be committed alongside the code changes for that step.

## Default pattern: generic step command

Use one generic command shape for most steps.

```bash
claude "Read STACK_CONTEXT, then PHASE_SPEC, then PHASE_PLAN. Execute Step <N> only. Previous steps are complete. Do not build ahead. If any ambiguity, missing decision, or unstated constraint appears, stop and report the exact gap that must be added to PHASE_SPEC before coding. Do not guess. Run the verification required by the implementation plan. At the end: (1) print a completion report titled step-completion-<NN> in session output and (2) write the same report to STEP_REPORT_FILE (create directories if missing). The report must include: Files changed, Commands run, Verification results, Stack-context compliance checks, Runtime readiness, Human/manual setup, Scope drift, Work introduced early from later steps, Spec gaps encountered. In Runtime readiness, state any trust assumptions relevant to this step explicitly. In Human/manual setup, use: 'No new human/manual setup introduced by this step' and list only previously known setup tasks that still materially affect this step, the immediate next step, or runtime readiness. I will run /exit after verification passes."
```

## Exceptions: when to add a step-specific line

The generic command should be the default. Add step-specific wording only as an exception.

Use an extra line only when one of these is true:

- the step has a known drift risk
- the step has a human prerequisite that Claude should check before coding
- the step needs a high-value reminder not yet enforced well enough by `CLAUDE.md`, `STACK_CONTEXT`, the spec, or the plan

Examples:

- `Before coding, check whether required human setup for Turnstile or local env values is still missing.`
- `Do not add placeholder SEO or page copy unless the implementation plan explicitly requires it.`

The rule is: **put step detail in the implementation plan, not in the live prompt, unless a specific exception justifies it.**

## Prompt layering guidance

Use the shortest prompt that still preserves correctness. In DevArch, the instruction layers should work like this:

1. `CLAUDE.md` or equivalent repo contract
2. `STACK_CONTEXT`
3. Specification and implementation plan
4. Live Claude CLI command

The live prompt should stay minimal.

## Completion reporting standard

A sentence like this is not enough:

> Step N is complete. Ready for Step N+1.

Claude must provide a structured completion summary with these sections, and persist it to the step report file:

1. Files generated/modified/deleted
2. Commands run
3. Verification results
4. Stack-context compliance checks
5. Runtime readiness
6. Human/manual setup
7. Scope drift
8. Work introduced early from later steps
9. Spec gaps encountered

### Runtime readiness

A successful build is not the same as runtime readiness.

If the step depends on external resources such as databases, namespaces, secrets, CAPTCHA keys, storage bindings, dashboards, or environment files, the completion report must explicitly state:

- what verified successfully in build or local code terms
- what remains blocked pending human setup
- whether the step is complete for code generation but not yet complete for runtime integration

If the step renders HTML from markdown or content, state any trust assumptions explicitly, for example:

- content is repo-authored and trusted
- user-supplied markdown is not rendered

### Human/manual setup

Use this wording:

- **No new human/manual setup introduced by this step**
- followed by **Previously known remaining setup tasks that still apply**, if any

Only list previously known tasks that still materially affect this step, the immediate next step, or runtime readiness.

## Focus guidance on harmful failure modes

Do not bloat prompts or guidance with cosmetic nits.

Promote an issue into repo guidance only when it repeatedly threatens one of these:

- correctness
- trust
- debuggability
- delivery speed

Examples worth systematizing:

- drift from the spec or step boundary
- incomplete implementation
- missing verification
- hidden runtime blockers
- misleading completion reports
- recurring local/remote environment mismatch

Examples to mostly ignore in-flight:

- mildly clunky wording
- slightly thin report detail
- formatting imperfections
- minor section categorization issues

Use this rule:

> Focus process guidance on defects that threaten correctness, trust, or debuggability. Ignore cosmetic nits until they become operationally expensive.

## Local vs remote environment note

Local and remote Cloudflare resources are not the same thing.

This matters especially for D1:

- `--local` commands affect the local development database
- `--remote` commands affect the deployed Cloudflare database

A successful remote migration/seed does not populate the local database used by `npm run dev`.

For D1-backed apps, verify both:

- local runtime readiness
- remote/deployed runtime readiness

If local dev throws errors like `no such table`, check whether local migrations and seed steps were run.

## Deployment note for framework-generated Cloudflare configs

For framework builds that generate deployment config, the safe deploy command may be the project script rather than raw `wrangler deploy`.

If deployment depends on generated build output or generated Wrangler config, prefer the repo's deploy script, for example:

```bash
npm run deploy
```

Use raw `npx wrangler deploy` only when you are sure the generated output is current.

## Bugfix slices

Treat targeted bug fixes as bounded slices, not as new numbered implementation-plan steps.

Recommended pattern:

- start a fresh Claude session
- point Claude at the most relevant artifacts
- ask for root cause plus smallest correct fix
- require verification
- write a bugfix completion report to `docs/context/step-completions/`

Example report file:

- `docs/context/step-completions/bugfix-mobile-nav-layering.md`

## If completion is under-reported

Before `/exit`, run:

```text
Restate Step <N> completion as step-completion-<NN> and write it to STEP_REPORT_FILE.
List:
1) files generated/modified/deleted
2) commands run
3) verification results
4) stack-context compliance checks
5) runtime readiness
6) human/manual setup (new vs previously known)
7) scope drift
8) work introduced early from later steps
9) spec gaps encountered
Do not add new work. Only summarize what was actually done.
```
