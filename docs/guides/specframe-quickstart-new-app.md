# SpecFrame Quickstart: Building a New App from Scratch

> **This guide is for new applications built from scratch.** The workflow differs for existing applications where code already exists. For existing apps, run SummonAIKit first to generate project context from your codebase, then create a feature specification against the existing structure.

## Prerequisites

| Tool                            | Purpose                      |
| ------------------------------- | ---------------------------- |
| Git                             | Version control              |
| GitHub account                  | Repository hosting           |
| Claude Code CLI                 | AI-assisted implementation   |
| Node.js (if building a web app) | JavaScript runtime           |
| Your stack of choice            | React, ASP.NET, Python, etc. |

---

## Step 1: Create the Repository

Create a new repository on GitHub for your application.

1. Go to github.com → New Repository
2. Name it (e.g., **my-app**)
3. Choose Public or Private
4. Check "Add a README file"
5. Select a license (MIT recommended)
6. Click Create repository

Clone it locally:

```bash
git clone https://github.com/your-username/my-app.git
cd my-app
```

---

## Step 2: Create the SpecFrame Directory Structure

SpecFrame organizes documentation alongside your code. Create the directory structure before writing any code.

```bash
mkdir -p docs/work/v1-core docs/context docs/architecture/adrs .claude
```

| Directory                 | Purpose                                                                                 |
| ------------------------- | --------------------------------------------------------------------------------------- |
| `docs/work/v1-core/`      | Work folder for your first version. Contains the specification and implementation plan. |
| `docs/context/`           | Session summaries that maintain continuity across Claude Code sessions.                 |
| `docs/architecture/adrs/` | Architecture Decision Records for significant design choices.                           |
| `.claude/`                | Claude Code configuration — project overview, settings, and skills.                     |

> Name work folders by version, feature, or branch name. For a new app, **v1-core** is a reasonable starting point. For subsequent features, use descriptive names like **user-profiles**, **payment-integration**, etc.

---

## Step 3: Copy the Session Template

If you have the SpecFrame repo cloned locally, copy the session summary template:

```bash
cp /path/to/specframe/docs/context/.session-template.md docs/context/.session-template.md
```

Session summaries are how you maintain continuity across Claude Code sessions. At the end of each session, Claude writes a summary of what was accomplished, what decisions were made, and what remains. The next session reads the summary and picks up where you left off.

---

## Step 4: Create a Minimal CLAUDE.md

CLAUDE.md is the first thing Claude Code reads when it opens your project. For a new app, create a minimal version by hand. SummonAIKit will generate a comprehensive one later, after code exists to scan.

Create `.claude/CLAUDE.md`:

```markdown
# [Your App Name]

[One-line description of what the app does.]

## Stack

- [Frontend framework]
- [Backend / database]
- [Auth approach]

## Workflow

- Specification: docs/work/v1-core/specification.md
- Session summaries: docs/context/
- ADRs: docs/architecture/adrs/

## Commands

- TBD after scaffolding

## Invariants

These rules are non-negotiable. They override convenience, momentum, and "I'll fix it after."

1. **The specification is the source of truth.** No other artifact — implementation plan, code, config, or test — may introduce information (gaps, decisions, constraints, scope changes) that is not already in the specification. When any artifact would introduce new information, update the specification FIRST.

2. **Gap analysis updates the spec before the plan.** When generating or updating an implementation plan:
   1. Read the active specification
   2. Identify all gaps (ambiguities, missing decisions, unstated constraints)
   3. Add a Gaps section to the specification and write each gap there FIRST
   4. Only then write the implementation plan, which may reference gaps in the spec
   5. Never write gaps into the implementation plan without them already existing in the specification

3. **Completion requires surfacing human tasks.** When declaring a phase complete, feature complete, or ready to test:
   1. State what was built
   2. Check the specification's External Setup section
   3. List every manual step the human must complete before the app will function
   4. For each step, state what to do, where to do it, and what to update in the codebase afterward
   5. Do not say "ready to test" or "feature complete" until you have surfaced all remaining human tasks

## Rules

- After generating an implementation plan, list all External Setup steps from the specification grouped by phase.
- After completing each phase, remind the human of any manual steps required before the next phase.
- After any file system operation that produces multiple files (scaffolding, copying, extracting), list the results to confirm before continuing.
- After scaffolding, verify all expected config files exist (env types, tsconfig, vite config, etc.) before proceeding to feature code.
- When the specification is ambiguous, stop and ask — do not assume.
- Before pushing to remote, run the full build command to verify the build succeeds. Do not rely on partial checks (e.g., type-checking alone).
- After any file conversion or generation (e.g., image format conversion), verify source files are unchanged.
```

> The **Invariants** section is critical. Without it, Claude Code will write gaps into the implementation plan instead of the specification, say "feature complete" when external services haven't been configured, or introduce decisions that aren't tracked in the spec. The invariants redefine the workflow contract between human and LLM.

---

## Step 5: Write the Specification

The specification is the most important document in the SpecFrame workflow. It captures your intent, constraints, and decisions before the LLM generates an implementation plan. Without it, the LLM guesses.

Create **docs/work/v1-core/specification.md** covering these sections:

| Section            | What to Write                                                                                                         |
| ------------------ | --------------------------------------------------------------------------------------------------------------------- |
| **Intent**         | What the app does and why it exists. Two to three sentences.                                                          |
| **Users**          | Who uses the app and what each user type can do.                                                                      |
| **Stack**          | Frontend, backend, database, auth, hosting. Be specific.                                                              |
| **Authentication** | How users log in. Social login, email/password, SSO, etc.                                                             |
| **Features**       | Each feature with field-level detail — types, required/optional, defaults, validation.                                |
| **Data Model**     | Tables, columns, types, constraints, relationships. Include security policies.                                        |
| **Constraints**    | Non-functional requirements — mobile-first, performance, simplicity, etc.                                             |
| **Out of Scope**   | What you are explicitly not building in this version. Prevents scope creep.                                           |
| **Decisions**      | Answers to any open questions. If questions remain, list them — resolve before building.                              |
| **External Setup** | Manual steps the human must complete outside Claude Code — creating accounts, configuring services, copying API keys. |

> A specification template is available in the SpecFrame repo at **docs/guides/specification.md**. The level of detail matters — field-level data models, validation rules, and explicit scope boundaries give the LLM enough to generate a precise implementation plan rather than a generic one.

### When to Add Event Storming and DDD

For straightforward CRUD apps, a specification is sufficient. For complex domains with multiple actors, policies, bounded contexts, or intricate business rules, add an event storm and domain model alongside the specification. These base artifacts describe the full domain and can serve multiple specifications. Templates are available in the SpecFrame repo at **docs/guides/**.

---

## Step 6: Commit and Push

Before opening Claude Code, commit the structure and specification so everything is tracked.

### First, set up `.gitignore` for Claude Code state

Some files inside `.claude/` are per-developer state and must not be committed — primarily local-override settings and credentials. Create or extend `.gitignore` with:

```gitignore
# Claude Code state — local overrides and credentials should not be committed.
# Shared .claude/settings.json, .claude/agents/, .claude/commands/, .claude/hooks/,
# and .claude/skills/ remain tracked.
.claude/settings.local.json
.claude/.credentials.json
```

The convention follows the same pattern as `.env` vs `.env.local` and `tsconfig.json` vs `tsconfig.local.json`: shared, project-wide files stay tracked; local-only overrides do not. Without this entry, the first time Claude Code asks you to approve a permission and you click "always allow," your local choice gets written to `settings.local.json` and committed alongside the next routine `git add .` — leaking your machine's preferences into the shared repo and creating noise in pull requests.

If you accidentally committed `settings.local.json` already, untrack it without deleting the local file:

```bash
git rm --cached .claude/settings.local.json
git commit -m "chore: untrack .claude/settings.local.json"
```

### Then commit

```bash
git add .
git commit -m "Add SpecFrame structure and v1 specification"
git push
```

At this point, your repo should look like:

```
my-app/
├── .claude/
│   └── CLAUDE.md                   # Minimal project overview
├── .gitignore                      # Includes .claude/settings.local.json
├── docs/
│   ├── architecture/
│   │   └── adrs/                   # Empty, ready for decisions
│   ├── context/
│   │   └── .session-template.md    # Session summary template
│   └── work/
│       └── v1-core/
│           └── specification.md    # Your specification
└── README.md
```

---

## Step 7: Open Claude Code and Generate the Implementation Plan

Open Claude Code in your project directory and give it this prompt:

```
Read the specification at docs/work/v1-core/specification.md.
Identify any gaps — ambiguities, missing decisions, unstated constraints —
and add them to a Gaps section in the specification.
Then generate an implementation plan at docs/work/v1-core/implementation-plan.md
that references those gaps.
```

Claude Code will read your specification, update it with any gaps it identifies, and then produce an implementation plan. The plan may reference gaps in the spec, but the gaps themselves live in the specification — never only in the plan.

**Review the plan. Answer the gaps. Then tell Claude Code to proceed.**

> **Important:** The LLM must write gaps into the specification before or during plan generation — not only into the plan. If the implementation plan contains gaps that aren't in the specification, the workflow invariant has been violated. The specification is always the source of truth for gaps, not the plan. If this happens, stop and have the LLM move the gaps to the specification before continuing.

> The implementation plan is not final — it evolves as you build. But starting from a plan grounded in your specification is fundamentally different from starting with "build me an app."

---

## Step 7b: Resolve Gaps

The specification now has a Gaps section — decisions that weren't addressed when the spec was originally written. These need answers before building starts.

1. Read each gap and the LLM's recommendation (if provided in the implementation plan)
2. Accept, override, or defer each one
3. **Update the Decisions section of the specification** with every resolved gap

Tag each resolved gap with `*(gap)*` at the end so you can track which decisions were made upfront vs surfaced during planning. This keeps the specification as the single source of truth for what was decided and why.

Then tell Claude Code:

```
I've updated the specification with gap decisions. Re-read docs/work/v1-core/specification.md. Plan approved. Start Phase 1.
```

> Don't skip this step. Unresolved gaps become assumptions the LLM makes silently during implementation. Resolved gaps documented in the specification become decisions you can trace later.

---

## Step 8: After Scaffolding — Run SummonAIKit and Configure Context7

Once Claude Code has scaffolded your project and you have actual code, run SummonAIKit to generate a comprehensive CLAUDE.md and technology-specific skills.

**Run SummonAIKit:**

```bash
npx summonaikit
```

This scans your codebase and generates:

1. An updated **.claude/CLAUDE.md** with full project context
2. Technology-specific skills in **.claude/skills/** (e.g., react.md, supabase.md)
3. Hooks and settings configuration

> **After SummonAIKit runs, review the generated CLAUDE.md.** Ensure the Invariants section from Step 4 is preserved. If SummonAIKit overwrites it, re-add the Invariants manually. The generated Rules and project context are additive — the Invariants are non-negotiable and must remain.

**Configure Context7:**

Add Context7 as an MCP server in your Claude Code configuration. Context7 provides live, version-specific documentation lookup during sessions, preventing the LLM from using outdated API references. See the SpecFrame scaffolding guide at **docs/guides/scaffolding.md** for setup details.

---

## Step 9: Build in Sessions

With the implementation plan reviewed and scaffolding in place, build your app in sessions. Each session follows this cycle:

| Phase     | What Happens                                                                                                 |
| --------- | ------------------------------------------------------------------------------------------------------------ |
| **Start** | Claude Code reads CLAUDE.md, skills, and the latest session summary. It knows where you left off.            |
| **Build** | Work through the implementation plan. Make decisions. Record ADRs for significant choices.                   |
| **End**   | Claude Code writes a session summary to docs/context/. This becomes the starting point for the next session. |

> Session summaries solve the biggest problem in AI-assisted development: context loss between sessions. Without them, every session starts from scratch. With them, Claude Code picks up exactly where you left off.

---

## Step 10: Verify Against Specification

After the build is complete, verify the implementation against the specification. Code is cheap — the LLM generates it in minutes. Confidence that it does what you intended is the bottleneck.

Verification has four layers. Each catches different classes of bugs. Create a separate work folder for each (e.g., `docs/work/v1_1-tests/`, `docs/work/v1_2-e2e/`).

### Layer 1: Unit & Integration Tests

Test logic that runs inside the application — no external services.

| Category           | What to Test                                     | Why                         |
| ------------------ | ------------------------------------------------ | --------------------------- |
| Validation         | Range checks, required fields, format rules      | Silent data corruption      |
| Calculations       | Derived values, display formatting               | User sees wrong information |
| Business rules     | State transitions, time ordering, access control | Core domain integrity       |
| Auth guards        | Protected routes, session handling               | Security                    |
| Component behavior | Forms, navigation, conditional rendering         | UI contract with user       |

Mock external dependencies (databases, APIs, auth providers). These tests prove the application sends the right calls — not that the external service accepts them.

### Layer 2: E2E Data Layer Tests

Test that the real external service accepts what the application sends. These close the gap between "the app calls the API correctly" (Layer 1) and "the database actually enforces the rules" (Layer 2).

Run these against a **dedicated test environment** — never production.

| Category              | What to Test                                             | Why                                                  |
| --------------------- | -------------------------------------------------------- | ---------------------------------------------------- |
| CRUD operations       | Insert, select, update, delete against real database     | Proves schema accepts app's data shapes              |
| Constraints           | CHECK constraints, NOT NULL, uniqueness                  | Proves database rejects invalid data                 |
| Security policies     | Row-level security, access control, cross-user isolation | Proves one user cannot access another's data         |
| Auto-generated values | IDs, timestamps, triggers                                | Proves database defaults and triggers fire correctly |
| Data shape            | Returned columns match what the app expects              | Catches schema drift                                 |

**Key decisions for E2E specs:**

- **API-level, not browser-level.** Call the database client directly — no DOM, no UI framework. Fast and focused on the data layer.
- **Separate credentials.** Use dedicated test environment variables (e.g., `.env.test.local`). Never reuse production credentials.
- **Programmatic auth.** Production may use OAuth (Google, Facebook), but tests need programmatic login (email/password, API keys, service tokens). Configure the test environment to support this.
- **Service role for cleanup.** Use an admin/service role for test setup and teardown that bypasses security policies. This ensures cleanup succeeds even if a test breaks the user session.
- **Two users for security tests.** User A creates data, User B tries to access it. Service role verifies the data actually exists. This proves security policies work.
- **Full isolation.** Each test creates its own data and cleans it up. No test depends on another test's data.

### Layer 3: Specification Verification

Walk the original specification feature by feature. For each requirement, confirm the implementation satisfies it:

```markdown
| Spec Requirement                          | Status | Notes                      |
| ----------------------------------------- | ------ | -------------------------- |
| Landing page shows title and subtitle     | ✅     |                            |
| Social login with Google                  | ✅     |                            |
| History shows reverse chronological order | ✅     |                            |
| Confirm before delete                     | ❌     | Missing — added to backlog |
```

Any ❌ becomes a bug fix or goes into the next work folder. The specification is the source of truth for what "done" means.

### Layer 4: Perspective Assessment

After tests pass and the specification checklist is verified, run a perspective-based assessment. Feed the specification and key implementation files to Claude with Research enabled and prompt it to assess from multiple professional perspectives — for example, a senior developer focusing on code quality, a QA specialist focusing on test coverage gaps, and a security specialist focusing on authentication and data access policies. The specification is the source of truth for what correct looks like. The perspectives surface blind spots that the other three layers miss.

This is not a replacement for tests or specification verification. Tests prove the code works. Specification verification proves it does what you intended. Perspective assessment asks: what did you miss?

In practice, prioritize the files where bugs would be most costly — security policies, authentication configuration, validation logic, and any business rules from the specification. You don't need to include every file.

> This technique requires Claude's Research mode (available in claude.ai and Claude Desktop, not Claude Code). See the [Claude Code Workflow Guide](docs/claude-code-workflow-guide.md) for guidance on when to use Research mode versus Claude Code.

This technique was adapted from David Cornelson's workflow described in [Building Complex Software with Claude AI](https://www.linkedin.com/pulse/building-complex-software-claude-ai-david-cornelson-ededc/).

### When to Use Which Layer

Not every app needs all four layers. Match the verification to the architecture:

| App Type                                 | Layer 1  | Layer 2                                                 | Layer 3 | Layer 4  |
| ---------------------------------------- | -------- | ------------------------------------------------------- | ------- | -------- |
| Static site (no backend)                 | Optional | Skip                                                    | Yes     | Optional |
| Frontend + mocked API                    | Yes      | Skip until API exists                                   | Yes     | Yes      |
| Frontend + database (Supabase, Firebase) | Yes      | Yes — database constraints and security policies matter | Yes     | Yes      |
| Full stack with API server               | Yes      | Yes — test API endpoints against real database          | Yes     | Yes      |

---

## Summary

| Step | Action                                                 | Produces                                                                                         |
| ---- | ------------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| 1    | Create repository on GitHub and clone locally          | Empty repo                                                                                       |
| 2    | Create SpecFrame directory structure                     | docs/work/, docs/context/, docs/architecture/adrs/, .claude/                                     |
| 3    | Copy session template from SpecFrame repo                | docs/context/.session-template.md                                                                |
| 4    | Create minimal CLAUDE.md with Invariants               | .claude/CLAUDE.md                                                                                |
| 5    | Write the specification                                | docs/work/v1-core/specification.md                                                               |
| 6    | Commit and push                                        | Clean starting point in version control                                                          |
| 7    | Open Claude Code; gaps to spec first, then plan        | Updated specification + docs/work/v1-core/implementation-plan.md                                 |
| 7b   | Resolve gaps; update specification Decisions section   | Complete specification with all decisions tagged _(gap)_                                         |
| 8    | After scaffolding: run SummonAIKit, configure Context7 | Full CLAUDE.md, skills, live docs                                                                |
| 9    | Build in sessions with summaries                       | Working application                                                                              |
| 10   | Verify against specification                           | Unit/integration tests, E2E data layer tests, specification verification, perspective assessment |

## What NOT to Do at This Stage

1. **Don't run SummonAIKit before code exists** — there's nothing to scan yet.
2. **Don't configure Context7 before scaffolding** — there are no libraries to look up docs for yet.
3. **Don't scaffold the project manually** (e.g., create-react-app, vite init) — let Claude Code do it based on the specification.
4. **Don't skip the specification** — it's the difference between "build me an app" and a directed implementation.
5. **Don't add event storming or DDD for simple CRUD apps** — save those for complex domains.

## Resources

| Resource                                   | Location                                  |
| ------------------------------------------ | ----------------------------------------- |
| SpecFrame repo                               | https://github.com/SangeetAgarwal/specframe |
| SpecFrame philosophy                         | docs/guides/specframe-philosophy.md         |
| Specification convention guide             | docs/guides/specification.md              |
| Scaffolding guide (SummonAIKit + Context7) | docs/guides/scaffolding.md                |
| Skill-building standards                   | docs/guides/skill-standards.md            |
| Claude Code workflow guide                 | docs/claude-code-workflow-guide.md        |
