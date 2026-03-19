# DevArch: CLAUDE.md Construction Guide

This guide covers one job: building and maintaining the `CLAUDE.md` repo agent contract that makes DevArch work.

## Why CLAUDE.md exists

DevArch keeps durable thinking in the artifact stack:

1. `CLAUDE.md` — repo-level rules
2. `docs/architecture/stack-context.md` — runtime constraints
3. `docs/architecture/domain.md` — domain model and Ubiquitous Language
4. `docs/architecture/project-architecture.md` — integration ownership, external systems, and phasing
5. `docs/work/<phase>/specification.md` — phase scope and decisions
6. `docs/work/<phase>/implementation-plan.md` — execution order
7. `docs/context/<phase>/step-completions/` — execution evidence

The live CLI prompt should be the thinnest layer.

## What CLAUDE.md must contain

At minimum, a DevArch `CLAUDE.md` should include these sections:

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
- any architecture decision records or other core artifacts

### 5. Commands

Build, dev, preview, type generation, migration creation, migration application, deployment, and any critical verification commands.

### 6. Domain summary

Enough context for correct use of the Ubiquitous Language.

### 7. Invariants

At minimum, include:

- **The specification is the source of truth.** Update the spec first.
- **Gap analysis updates the spec before the plan.**
- **Implementation-time gaps update the spec first.**
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
