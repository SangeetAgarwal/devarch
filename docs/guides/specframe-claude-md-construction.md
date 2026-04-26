# SpecFrame: CLAUDE.md Construction Guide

This guide covers one job: building and maintaining the `CLAUDE.md` repo agent contract that makes SpecFrame work.

## Why CLAUDE.md exists

SpecFrame keeps durable thinking in the artifact stack:

1. `CLAUDE.md` — repo-level rules
2. `docs/architecture/stack-context.md` — runtime constraints
3. `docs/architecture/domain.md` — domain model and Ubiquitous Language
4. `docs/architecture/project-architecture.md` — integration ownership, external systems, and phasing
5. `docs/work/<phase>/specification.md` — phase scope and decisions
6. `docs/work/<phase>/implementation-plan.md` — execution order
7. `docs/context/<phase>/step-completions/` — execution evidence

The live CLI prompt should be the thinnest layer.

## What CLAUDE.md must contain

At minimum, a SpecFrame `CLAUDE.md` should include these sections:

### 1. Project identity

A one-paragraph description of the project.

### 2. Stack

A concise stack list and a reference to the stack context document.

### 3. Workflow

The document reading order for every session.

### 4. File locations

Explicit paths for:

- phase specifications
- phase implementation plans
- stack context document
- domain document
- project architecture document (when the project has integrations, external systems, or multi-phase ownership boundaries)
- phase step completion reports
- gap notes (intra-phase) and gap sweep folders (inter-phase)
- any architecture decision records or other core artifacts

A `Phase directories` table belongs here too — a flat mapping from phase letter to folder name, listed in the order phases were started. This table is the single index a reader uses to find any phase folder. Maintain it actively as new phases are added.

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

**Phase letter convention:**

- Feature phases use positional letters (`1`, `2a`, `2b-1a`, `2c`).
- Gap sweeps append the type marker after the trigger phase (`2c-gap-sweep`, `pre-launch-gap-sweep`). The type marker keeps the table self-describing — a reader sees at a glance which entries are feature work and which are deliberate cross-phase reconciliation. See `specframe-gap-sweep.md`.
- The phase letter and folder name should mirror each other through the version prefix: phase `2c-gap-sweep` lives in `v1-2c-gap-sweep`. Naming the folder by coverage (e.g., `v1-program-page-fix-sweep`) is tempting but misleading because most sweeps touch more than one surface — the inventory inside the folder enumerates what is touched.

### 5. Commands

Build, dev, preview, type generation, migration creation, migration application, deployment, and any critical verification commands.

### 6. Domain summary

Enough context for correct use of the Ubiquitous Language.

### 7. Invariants

At minimum, include:

- **The specification is the source of truth.** Update the spec first.
- **Gap analysis updates the spec before the plan.**
- **Implementation-time gaps update the spec first.**
- **Inter-phase gaps are addressed via Gap Sweep, not absorbed into the next feature phase.** When verification, post-deploy use, or the start of a new phase reveals drift across multiple prior phase specs, create a sweep phase folder (`v<version>-<trigger>-gap-sweep`), inventory the findings, edit affected prior specs in place (tagged with the sweep's phase letter), and sequence the work as a dedicated phase. Folding cross-phase drift into the next feature phase bloats that phase's spec and degrades the spec-as-source-of-truth discipline. See `specframe-gap-sweep.md`.
- **Implementation plans are derived from the spec.** Plans start with one `## Human Steps` section, use numbered steps only, include `Goal`, include `Required Comment Updates`, and end with `Final Done Criteria Verification`.
- **One numbered step per CLI session.**
- **Step completion reports are required.**
- **Durable execution discoveries are written back.** If execution or step-completion review reveals a load-bearing dependency, prerequisite, or invariant that future work depends on, promote it into the authoritative artifacts.
- **Step audits must check both directions.** An audit must verify not only that the code implements the spec (spec → code), but also that the spec captures what the code does (code → spec). If the code introduces behavioral details the spec is silent on — hardcoded values, query scoping, guard conditions, notification formats — the audit must flag them for artifact write-back. An audit that only confirms "code does what the spec says" is incomplete.

### 8. Rules

Operational rules that enforce consistency.

- **Code must match the spec exactly. Deviations are bugs, not improvements.**  
  When reviewing output, do not rationalize differences between code and spec. If code differs from the spec, fix the code or stop and record a gap. Never present a spec deviation as an optional preference.

### 9. Code Comment Policy

Durable comment rules across phases.

### 10. External integrations

OAuth providers, payment systems, schedulers, or other external services where applicable.

## Repository hygiene: what to gitignore alongside `CLAUDE.md`

`CLAUDE.md` and most files under `.claude/` are part of the project contract and should be committed. A small subset is per-developer state and should not be:

| File or path                   | Commit?      | Reason                                                                                                                          |
| ------------------------------ | ------------ | ------------------------------------------------------------------------------------------------------------------------------- |
| `.claude/CLAUDE.md`            | **Yes**      | The repo agent contract. Shared.                                                                                                |
| `.claude/settings.json`        | **Yes**      | Project-wide settings, hooks, allowed tool patterns that should apply to every contributor.                                     |
| `.claude/agents/`              | **Yes**      | Project-specific subagent definitions. Shared.                                                                                  |
| `.claude/commands/`            | **Yes**      | Project-specific slash commands. Shared.                                                                                        |
| `.claude/hooks/`               | **Yes**      | Project-specific hooks. Shared.                                                                                                 |
| `.claude/skills/`              | **Yes**      | Generated by SummonAIKit; shared so every contributor uses the same skill set.                                                  |
| `.claude/settings.local.json`  | **No**       | Per-developer overrides — same convention as `.env.local`, `tsconfig.local.json`. Leaks local preferences if committed.        |
| `.claude/.credentials.json`    | **No**       | Per-developer credentials — never commit.                                                                                       |

Add this to the project `.gitignore`:

```gitignore
# Claude Code state — local overrides and credentials should not be committed.
# Shared .claude/settings.json, .claude/agents/, .claude/commands/, .claude/hooks/,
# and .claude/skills/ remain tracked.
.claude/settings.local.json
.claude/.credentials.json
```

Without this, the first "always allow" permission approval writes the developer's local choice to `settings.local.json`, and the next routine `git add .` quietly commits it. This leaks per-machine preferences, creates churn in pull requests, and (in the case of `.credentials.json`) is a security incident.

If `settings.local.json` was committed before the gitignore entry was added, untrack it without deleting the local file:

```bash
git rm --cached .claude/settings.local.json
git commit -m "chore: untrack .claude/settings.local.json"
```

The same pattern applies to any project scaffolded from a SpecFrame template — the baseline `.gitignore` should already include these entries so downstream projects do not repeat the oversight.

## Recommended rule to add to CLAUDE.md

```markdown
### Artifact write-back rule

If execution or step-completion review reveals a durable, load-bearing fact that later work depends on, do not leave it only in a step completion report. Promote it into the appropriate authoritative artifact:

- specification for dependencies, contracts, invariants, prerequisites, or baseline capabilities
- implementation plan for sequencing or step-level dependency effects
- keep the step completion report as provenance and evidence
```

## Preferred prompt pattern

When `CLAUDE.md` contains the durable rules, the live prompt can be minimal.

**Plan generation**

```bash
claude "Read CLAUDE.md and generate a fresh implementation plan for phase docs/work/<phase>."
```

**Step execution**

```bash
claude "Read CLAUDE.md and execute Step <N> for phase docs/work/<phase>. After step execution, write step-completion-<N> to docs/context/<phase>/step-completions/step-completion-<N>.md. Create the directory if it does not exist. The completion report must state what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

If the prompt needs to restate rules that should be in `CLAUDE.md`, that is a signal to strengthen `CLAUDE.md` instead of growing the prompt.
