# DevArch Quickstart: Building a New App from Scratch

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

## Step 2: Create the DevArch Directory Structure

DevArch organizes documentation alongside your code. Create the directory structure before writing any code.

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

If you have the DevArch repo cloned locally, copy the session summary template:

```bash
cp /path/to/devarch/docs/context/.session-template.md docs/context/.session-template.md
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

## Rules

- When declaring a phase complete, feature complete, or ready to test:
  1. State what was built
  2. Check the specification's External Setup section
  3. List every manual step the human must complete before the app will function
  4. For each step, state what to do, where to do it, and what to update in the codebase afterward
  5. Do not say "ready to test" or "feature complete" until you have surfaced all remaining human tasks
- After generating an implementation plan, list all External Setup steps from the specification grouped by phase.
- After completing each phase, remind the human of any manual steps required before the next phase.
- After any file system operation that produces multiple files (scaffolding, copying, extracting), list the results to confirm before continuing.
- After scaffolding, verify all expected config files exist (env types, tsconfig, vite config, etc.) before proceeding to feature code.
- When the specification is ambiguous, stop and ask — do not assume.
- When implementing a feature not already in the specification, update the specification to include it before or alongside the code change.
```

> The **Rules** section is critical. Without it, Claude Code will say "feature complete" when the code is done — even if external services haven't been configured. The rules redefine "complete" to mean "code is done and all human tasks have been surfaced."

---

## Step 5: Write the Specification

The specification is the most important document in the DevArch workflow. It captures your intent, constraints, and decisions before the LLM generates an implementation plan. Without it, the LLM guesses.

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

> A specification template is available in the DevArch repo at **docs/guides/specification.md**. The level of detail matters — field-level data models, validation rules, and explicit scope boundaries give the LLM enough to generate a precise implementation plan rather than a generic one.

### When to Add Event Storming and DDD

For straightforward CRUD apps, a specification is sufficient. For complex domains with multiple actors, policies, bounded contexts, or intricate business rules, add an event storm and domain model alongside the specification. These base artifacts describe the full domain and can serve multiple specifications. Templates are available in the DevArch repo at **docs/guides/**.

---

## Step 6: Commit and Push

Before opening Claude Code, commit the structure and specification so everything is tracked.

```bash
git add .
git commit -m "Add DevArch structure and v1 specification"
git push
```

At this point, your repo should look like:

```
my-app/
├── .claude/
│   └── CLAUDE.md                   # Minimal project overview
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
Read the specification at docs/work/v1-core/specification.md
and generate an implementation plan. Identify gaps.
```

Claude Code will read your specification and produce an implementation plan at **docs/work/v1-core/implementation-plan.md**. It will also surface open questions — things the specification didn't cover or areas where it needs a decision from you.

**Review the plan. Answer the gaps. Then tell Claude Code to proceed.**

> The implementation plan is not final — it evolves as you build. But starting from a plan grounded in your specification is fundamentally different from starting with "build me an app."

---

## Step 7b: Resolve Gaps

The implementation plan will include a gaps section — decisions the specification didn't address. These need answers before building starts.

1. Read each gap and the LLM's recommendation
2. Accept, override, or defer each one
3. **Update your specification** with every decision

Add resolved gaps to the **Decisions** section of `docs/work/v1-core/specification.md`. Tag each with `*(gap)*` at the end so you can track which decisions were made upfront vs surfaced during planning. This keeps the specification as the single source of truth for what was decided and why.

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

**Configure Context7:**

Add Context7 as an MCP server in your Claude Code configuration. Context7 provides live, version-specific documentation lookup during sessions, preventing the LLM from using outdated API references. See the DevArch scaffolding guide at **docs/guides/scaffolding.md** for setup details.

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

### Layer 1: Tests

Create a test specification in a new work folder (e.g., `docs/work/v1_1-tests/specification.md`). Focus on logic that breaks silently:

- **Validation logic** — range checks, required fields, format rules
- **Calculations** — derived values, display formatting
- **Business rules** — state transitions, time ordering, access control
- **Auth guards** — protected routes, session handling

Tests are living documentation. A new developer reads the test suite and knows what the app does.

### Layer 2: Specification Verification

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

---

## Summary

| Step | Action                                                 | Produces                                                     |
| ---- | ------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | Create repository on GitHub and clone locally          | Empty repo                                                   |
| 2    | Create DevArch directory structure                     | docs/work/, docs/context/, docs/architecture/adrs/, .claude/ |
| 3    | Copy session template from DevArch repo                | docs/context/.session-template.md                            |
| 4    | Create minimal CLAUDE.md                               | .claude/CLAUDE.md                                            |
| 5    | Write the specification                                | docs/work/v1-core/specification.md                           |
| 6    | Commit and push                                        | Clean starting point in version control                      |
| 7    | Open Claude Code; generate implementation plan         | docs/work/v1-core/implementation-plan.md                     |
| 7b   | Resolve gaps; update specification                     | Complete specification with all decisions                    |
| 8    | After scaffolding: run SummonAIKit, configure Context7 | Full CLAUDE.md, skills, live docs                            |
| 9    | Build in sessions with summaries                       | Working application                                          |
| 10   | Verify against specification                           | Test suite + specification verification checklist            |

## What NOT to Do at This Stage

1. **Don't run SummonAIKit before code exists** — there's nothing to scan yet.
2. **Don't configure Context7 before scaffolding** — there are no libraries to look up docs for yet.
3. **Don't scaffold the project manually** (e.g., create-react-app, vite init) — let Claude Code do it based on the specification.
4. **Don't skip the specification** — it's the difference between "build me an app" and a directed implementation.
5. **Don't add event storming or DDD for simple CRUD apps** — save those for complex domains.

## Resources

| Resource                                   | Location                                  |
| ------------------------------------------ | ----------------------------------------- |
| DevArch repo                               | https://github.com/SangeetAgarwal/devarch |
| Specification convention guide             | docs/guides/specification.md              |
| Scaffolding guide (SummonAIKit + Context7) | docs/guides/scaffolding.md                |
| Skill-building standards                   | docs/guides/skill-standards.md            |
| Claude Code workflow guide                 | docs/claude-code-workflow-guide.md        |
