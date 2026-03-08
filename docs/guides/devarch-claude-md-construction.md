# DevArch: CLAUDE.md Construction Guide

This guide covers one job: building and maintaining the `CLAUDE.md` repo agent contract that makes DevArch work.

`CLAUDE.md` is the first document the LLM reads in every session. It carries the durable rules that keep the specification authoritative, the plan trustworthy, and the prompts minimal. If the rules are missing from `CLAUDE.md`, they have to go in the live prompt — which defeats the point of DevArch.

## Why CLAUDE.md exists

DevArch keeps durable thinking in the artifact stack:

1. `CLAUDE.md` — repo-level rules (always read, every session)
2. `docs/architecture/stack-context.md` — runtime constraints
3. `docs/work/<phase>/specification.md` — phase scope and decisions
4. `docs/work/<phase>/implementation-plan.md` — execution order

The live CLI prompt should be the thinnest layer. `CLAUDE.md` is what makes that possible.

Without `CLAUDE.md`, every prompt must restate: read the spec, don't build ahead, stop on gaps, verify before claiming completion, use Human Steps at the top of plans, write completion reports, don't invent scope. That is expensive, error-prone, and violates the DevArch principle that durable rules live in documents, not in ephemeral prompts.

## What CLAUDE.md must contain

At minimum, a DevArch `CLAUDE.md` should include these sections:

### 1. Project identity

A one-paragraph description of the project. Enough for the LLM to understand the domain without reading further.

### 2. Stack

The technology stack as a concise list. Reference the stack context document for full details.

### 3. Workflow

The document reading order for every session:

1. `CLAUDE.md` (this file)
2. Stack context document
3. Domain model / core specification
4. Active phase specification

This order matters. The LLM must read repo-level rules before phase-level rules.

### 4. File locations

Explicit paths for:

- Phase specifications
- Phase implementation plans
- Stack context document
- Step completion reports
- Architecture decision records
- Any other artifact the LLM needs to find

Do not make the LLM guess paths. List them.

### 5. Commands

The commands the LLM needs to run: build, dev, preview, type generation, migration creation, migration application, deployment, log tailing. Include both local and remote variants where they differ.

### 6. Domain summary

Enough domain context for the LLM to use the Ubiquitous Language correctly. Key disambiguations (e.g., "session" means different things in different bounded contexts). Domain terms that must be capitalized, never abbreviated, and used consistently in code, UI copy, and database schema.

Reference the full specification for complete business rules.

### 7. Invariants

Non-negotiable rules that override convenience. These are the rules that prevent the most expensive failures. At minimum, include:

- **The specification is the source of truth.** No artifact may introduce information not already in the spec. Update the spec first.
- **Gap analysis updates the spec before the plan.** Planning-time gaps go into the spec before the plan is completed.
- **Implementation-time gaps update the spec first.** When a gap surfaces during step execution, the LLM stops, the human resolves it in the spec, the plan is regenerated if needed, and the blocked step is re-executed.
- **Completion requires surfacing human tasks.** Do not declare complete without listing every manual step the human must do.
- **Implementation plans are derived from the spec.** Plans start with one `## Human Steps` section, use numbered steps only, include Required Comment Updates per code step, and end with Final Done Criteria Verification.
- **One numbered step per CLI session.** After the step is verified and the report is written, exit. Start the next step in a new session.
- **Step completion reports are required.** Every step produces a structured report at a predictable path. A step is not complete until the report is written.

Add project-specific invariants as they are discovered (e.g., Ubiquitous Language enforcement, bounded context boundaries, stack-context required reading).

### 8. Rules

Operational rules that are not invariants but still enforce consistency. These accumulate over time as failure modes are discovered and codified. Examples:

- After scaffolding, verify config files exist before proceeding
- Run type generation after any wrangler config change
- Verify file integrity after conversion operations
- Validate domain terms in migrations against the specification

### 9. Code Comment Policy

The durable comment rules that apply across all phases:

- When comments are required (contracts, invariants, trust boundaries, provider quirks)
- When comments are not required (obvious narration)
- The requirement to update stale comments in the same step that changes the code
- The rule that phase specs may add phase-specific comment requirements

### 10. External integrations (if applicable)

For projects with external services (payment processors, scheduling engines, OAuth providers, CDNs), include:

- Integration pattern (which bounded context, which direction)
- API details sufficient for the LLM to avoid common mistakes
- What the external service owns vs what the project owns
- Runtime constraints (e.g., no `crypto.createHmac` on Cloudflare Workers)

## What does NOT belong in CLAUDE.md

- Phase-specific scope, decisions, or constraints — these belong in phase specs
- Step-by-step implementation details — these belong in implementation plans
- Runtime verification procedures — these belong in step completion reports
- Full API documentation — reference external docs, don't paste them
- Speculative future-phase details — only document what is decided

The test: if it would change when the phase changes, it belongs in the phase spec, not in `CLAUDE.md`.

## How CLAUDE.md grows

`CLAUDE.md` is a living document. It grows through the self-improving loop:

1. A failure mode is observed during execution (LLM skipped file verification, invented scope, ignored a runtime constraint).
2. The failure is documented in the lessons learned or step completion report.
3. A rule is added to `CLAUDE.md` that prevents the same failure class in all future sessions.

Over time, `CLAUDE.md` accumulates the project's institutional memory. New sessions benefit from every past failure without the human restating the lessons in the prompt.

### When to add a rule

Add a rule to `CLAUDE.md` when a failure mode:

- threatens correctness, trust, or debuggability
- has occurred more than once, or is likely to recur
- can be prevented by a clear, enforceable statement

### When NOT to add a rule

Do not add a rule for:

- cosmetic nits that don't affect correctness
- one-off issues unlikely to recur
- phase-specific constraints that belong in the phase spec
- rules that are already in the stack context document

## CLAUDE.md and the preferred prompt pattern

When `CLAUDE.md` contains all the durable rules, the live prompt can be minimal:

**Plan generation:**
```bash
claude "Read CLAUDE.md and generate a fresh implementation plan for phase docs/work/<phase>."
```

**Step execution:**
```bash
claude "Read CLAUDE.md and execute Step <N> for phase docs/work/<phase>. After step execution, write step-completion-<N> to docs/context/<phase>/step-completions/step-completion-<N>.md. Create the directory if it does not exist. The completion report must state what changed, why it changed, verification performed, and any gaps, blockers, or unresolved items."
```

If the prompt needs to restate rules that should be in `CLAUDE.md`, that is a signal to update `CLAUDE.md` rather than continue compensating in the prompt.

## Authority hierarchy

`CLAUDE.md` is layer 1 in the authority stack:

1. `CLAUDE.md` — repo-level rules
2. Stack context document — runtime constraints
3. Phase specification — scope, decisions, done criteria
4. Phase implementation plan — execution order
5. Live CLI prompt — session-specific instructions

Higher layers override lower layers. If the spec says "use ULID for IDs" and `CLAUDE.md` says nothing about ID generation, the spec wins. If `CLAUDE.md` says "all D1 tables use STRICT" and the spec doesn't mention it, `CLAUDE.md` wins — it's a repo-level constraint.

The live prompt is the lowest authority. It should contain only what is unique to this specific invocation and does not belong in any durable document.

## Template checklist

When creating a `CLAUDE.md` for a new project, verify it includes:

- [ ] Project identity (one paragraph)
- [ ] Stack (concise list, reference stack context for details)
- [ ] Workflow (document reading order)
- [ ] File locations (specs, plans, step reports, stack context)
- [ ] Commands (build, dev, preview, types, migrations, deploy)
- [ ] Domain summary (Ubiquitous Language, key disambiguations)
- [ ] Invariants (spec is source of truth, gap analysis, plan shape, one step per session, completion reports)
- [ ] Rules (operational rules accumulated from execution)
- [ ] Code Comment Policy (when required, when not, staleness rule)
- [ ] External integrations (if applicable)

If any of these are missing, the live prompt will have to compensate — and that compensation should be a signal to update `CLAUDE.md`.
