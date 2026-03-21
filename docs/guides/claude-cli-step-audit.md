# Claude CLI Step Audit for DevArch

This guide covers one job only: auditing an already-implemented numbered step to see whether the code, comments, verification evidence, and step-completion report are actually in sync with the authoritative artifacts.

Audit is a **post-implementation sync check**. It is not a numbered implementation-plan step.

## Why this guide exists

Step execution and verification answer:

- did we implement the planned slice?
- did we verify it enough to claim the current status?

Audit answers a different question:

- is the implemented step genuinely in sync with the specification, implementation plan, current codebase, comments, and recorded evidence?

That distinction matters because a step can be:
- functionally implemented
- mostly verified
- but still inaccurately reported, slightly out of scope, or missing artifact write-back

Audit exists to catch that kind of drift without blurring it into implementation work.

## Core idea

Use audit to independently check the truthfulness and alignment of an implemented step.

Keep the audit session bounded:
- one audited step per Claude CLI session
- one audit artifact per audited step
- no silent remediation inside the audit unless the human explicitly asks for a remediation session

## Audit versus verification

Use this short distinction:

- **Verification step**: a numbered plan step that closes a planned slice or phase against done criteria.
- **Audit step**: an independent post-implementation review that checks whether the implemented step is truly in sync with the authoritative artifacts and recorded evidence.

Verification belongs in `claude-cli-step-execution.md`.

Audit belongs here.

## When to use an audit

Use an audit when you want any of the following:

- confidence that a completed step is actually in sync with the spec and plan
- independent review after a code-generating step
- confirmation that the step-completion report is truthful
- identification of proven drift before moving to the next step
- a clean distinction between "implemented" and "accurately documented"

Good audit timing:

- after a complicated implementation step
- after an integration-heavy step
- after a step that surfaced runtime discoveries
- before a final verification step, if you want higher confidence
- when a step-completion report feels too optimistic or too vague

## Authority order during audit

Use this order of authority:

1. `CLAUDE.md`
2. `docs/architecture/stack-context.md`
3. `docs/architecture/domain.md`
4. `docs/work/<phase>/specification.md`
5. `docs/work/<phase>/implementation-plan.md`
6. `docs/context/<phase>/step-completions/step-completion-<N>.md`
7. `docs/architecture/project-architecture.md` when the audited step touches integrations, external systems, phasing, or ownership boundaries
8. the current codebase and test evidence

The completion report is evidence, not the source of truth.

## One audit session per audited step

Rules:

- Run exactly one audited step per Claude CLI session.
- Write exactly one `step-audit-<N>.md` artifact for that session.
- Manually type `/exit` after the audit is complete.
- If the audit reveals drift that should be fixed, do that in a separate remediation session unless the human explicitly asked for combined audit-and-remediation behavior.

This preserves independence and avoids "I know what I meant" contamination from the implementation session.

## Non-negotiable rules

### 1) Audit does not invent new scope

The audit must not invent requirements that are absent from the authoritative artifacts.

### 2) Audit checks code and evidence, not just the report

The audit must compare:
- the spec
- the implementation plan
- the code
- the comments
- the tests or other verification evidence
- the step-completion report

### 3) Unsupported claims must be called out

If the step-completion report claims something that the code or evidence does not support, the audit must say so explicitly.

### 4) Missing manual verification must stay explicit

If the implementation plan required manual verification and the evidence is missing, the audit must not treat automated evidence as equivalent unless the authoritative artifacts explicitly allow that substitution.

### 5) Durable truths must be surfaced

If the code or evidence reveals a durable truth that should live in the authoritative artifacts, the audit must say exactly what should be written back and where.

### 6) Audit must check both directions

The audit must verify not only that the code implements the spec (spec → code), but also that the spec captures what the code does (code → spec). If the code introduces behavioral details the spec is silent on — hardcoded values, query scoping, guard conditions, notification formats, implicit assumptions about data shape — the audit must flag them for artifact write-back. An audit that only confirms "code does what the spec says" is incomplete.

### 7) Spec contradictions must state both sides explicitly

When the audit finds that the spec makes a positive claim and the code does something different, the audit must state what the spec claims and what the code does — not just note that they differ. A spec contradiction is distinct from a spec silence: silence means the spec said nothing and the code added detail (durable truth write-back); contradiction means the spec said X and the code does Y. Contradictions may have downstream dependents — other steps planned against the wrong assumption — so the audit should flag which other steps, if any, depend on the contradicted claim.

## What an audit should classify

Every audit should classify findings into one or more of these categories:

- **Required and present**
- **Required but missing**
- **Present but out of scope**
- **Claimed in report but unsupported by code or evidence**
- **Present in code but missing from the report**
- **Durable truth that should be written back**

## Audit outcomes

The audit should end with one of these dispositions:

- **Accept as Complete**
- **Accept as Partially Complete**
- **Revise report only**
- **Fix code then revise report**
- **Update authoritative artifacts before proceeding**
- **Out of Sync — do not proceed**

These are dispositions, not implementation-plan statuses.

## Prompt design

### Default audit prompt

Use the explicit form. Name every document Claude CLI must read and the output path for the audit artifact.

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then <phase-spec-path>, then <phase-plan-path>, then <step-completion-path><optional-project-architecture-clause>. Audit implemented Step <N> only against the specification, implementation plan, current codebase, comments, and verification evidence. Do not execute any new numbered step. Do not implement new feature scope. Check whether the code, comments, verification, and step-completion report are in sync. Identify: (1) anything required by the spec or plan that is missing in code, (2) anything present in code that exceeds this step's scope, (3) anything claimed in the step-completion report that is not supported by the code or verification evidence, (4) anything present in code or evidence that is missing from the report, and (5) any durable truth discovered in code or evidence that should be written back into authoritative artifacts. If you find drift, do not guess. Report it explicitly. Write your audit to <step-completions-dir>/step-audit-<N>.md. Create the directory if it does not already exist."
```

### Stricter audit prompt

Use this when you want an even cleaner separation between audit and remediation:

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then <phase-spec-path>, then <phase-plan-path>, then <step-completion-path><optional-project-architecture-clause>. Audit implemented Step <N> only against the specification, implementation plan, current codebase, comments, and recorded verification evidence. Do not execute any new numbered step. Do not remediate code in this session unless explicitly required to correct an objectively false completion claim that would otherwise leave the audit artifact misleading. Classify any drift as: revise report only, fix code then revise report, or update authoritative artifacts before proceeding. Write your audit to <step-completions-dir>/step-audit-<N>.md."
```

### Remediation / report-sync prompt

Use this in a fresh session after an audit has already found drift.

```bash
claude "Read CLAUDE.md, then docs/architecture/stack-context.md, then docs/architecture/domain.md, then <phase-spec-path>, then <phase-plan-path>, then <step-completion-path>, then <step-audit-path><optional-project-architecture-clause>. This is a remediation and artifact-sync session for implemented Step <N> only. Do not execute any new numbered step. Remediate only the proven drift identified in the audit. Do not add new feature scope. Run the relevant verification after changes. Update the affected authoritative artifacts and step-completion report as needed so they truthfully reflect the remediated state. Preserve the step-audit artifact as the independent audit record unless a factual contradiction requires a minimal correction. After verification, summarize exactly what was remediated, what artifacts were updated, and whether the step is now in sync."
```

### Short audit prompt

Use this only when your repo contract is strong enough to resolve paths safely.

```bash
claude "Read CLAUDE.md and audit implemented Step <N> for phase <phase-dir>. Write the audit to <step-completions-dir>/step-audit-<N>.md. Report any code/report/spec drift explicitly."
```

If Claude CLI reads the wrong spec, misses stack context, misses the completion report, cannot resolve the code under review, or writes the audit to the wrong location, switch back to the default prompt.

## Prompt generation behavior

This section defines how any model should behave when a human references this guide and asks for Claude CLI audit prompts.

### Default behavior when asked for an audit prompt

When the human asks for an audit prompt using this guide, the model should:

1. use this guide as authoritative
2. output the finished audit prompt directly
3. ask only for information that is truly missing, such as:
   - phase directory
   - step number
   - step-completion path
   - whether project architecture is required, if that cannot be inferred

The model should **not**:
- paraphrase the whole guide instead of producing the prompt
- require a separate ask for remediation if the human explicitly asked for both audit and remediation prompts
- blur audit into implementation

### Prompt bundle behavior

When the human says something like:

- "I am now generating steps. Here's the guide. Give me all the prompts for each step."
- "Give me the full prompt bundle for this phase."
- "Generate execution, verification, audit, and remediation prompts for every step."

the model should return a **full prompt bundle** in plan order.

In a full prompt bundle:
- implementation-step prompts come from `claude-cli-step-execution.md`
- verification-step prompts come from `claude-cli-step-execution.md`
- audit prompts come from this guide
- one remediation/report-sync prompt template should also be included

If the active implementation plan is available, derive the bundle from that plan. If the plan is not available, ask for it.

## Required audit artifact

Write the audit artifact to:

`docs/context/<phase>/step-completions/step-audit-<N>.md`

If the directory does not exist, Claude must create it.

### Recommended audit structure

```markdown
# Step Audit — Step <N> — <Step Title>

## Overall Assessment
- In Sync | Mostly In Sync | Partially In Sync | Out Of Sync

## Scope of Audit
- Files inspected:
- Evidence reviewed:
- Authority used:

## Spec And Plan Coverage
- Required and present:
- Required but missing:
- Present but out of scope:

## Code And Report Alignment
- Report claims supported by code:
- Report claims not fully supported by code or evidence:
- Code or evidence not reflected in the report:

## Verification Alignment
- Verification required by the plan:
- Verification evidenced:
- Verification still unproven:

## Comments And Trust Boundaries
- Required comments present:
- Missing or stale comments:
- Non-obvious trust/invariant issues:

## Durable Truth To Write Back
- None, or the exact fact and target authoritative artifact

## Recommended Disposition
- Accept as Complete
- Accept as Partially Complete
- Revise report only
- Fix code then revise report
- Update authoritative artifacts before proceeding
- Out of Sync — do not proceed

## Key Observations
- Concise explanation of the most important findings
```

## How audit and verification work together

A clean DevArch flow usually looks like this:

1. run one numbered implementation step
2. write `step-completion-<N>.md`
3. optionally run a fresh audit session for that step
4. if the audit finds proven drift, run a separate remediation/report-sync session
5. continue to the next numbered step
6. later, run the numbered verification step that closes the phase or sub-phase against done criteria

That sequence keeps the roles clear:
- implementation builds
- audit checks sync
- remediation fixes proven drift
- verification closes planned done criteria

## Summary

Audit is the independent truth check that sits beside step execution, not inside it.

Use it when you want confidence that an implemented step is not merely "done enough" but actually in sync with the specification, implementation plan, current codebase, comments, and verification evidence.

Keep audits separate, explicit, and evidence-driven.
