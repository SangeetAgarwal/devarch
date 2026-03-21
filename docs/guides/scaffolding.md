# Scaffolding with SummonAIKit + Context7

## Purpose

SummonAIKit and Context7 are two separate tools that together ensure Claude Code has deep, accurate knowledge of your project from the first session and throughout development.

- **SummonAIKit CLI** analyzes your codebase and generates Claude Code skills — structured documentation that helps Claude understand your project.
- **Context7 MCP** provides live, version-specific documentation lookup during coding sessions, ensuring Claude references current APIs rather than outdated training data.

They are complementary but independent. SummonAIKit runs once to scaffold. Context7 runs continuously as an MCP server during every session.

## SummonAIKit CLI

### What It Does

SummonAIKit scans your codebase — project files, dependencies, configurations, folder structure — and generates Claude Code infrastructure:

### What It Generates

```
.claude/
├── CLAUDE.md           # Project overview — tech stack, conventions, architecture
├── skills/             # Tech-specific knowledge files
│   ├── react.md
│   ├── nextjs.md
│   └── ...
├── hooks/              # Lifecycle hooks (e.g., skill-instructions-hook.sh)
└── settings.json       # Hook registration
```

| Artifact | Purpose |
|---|---|
| `CLAUDE.md` | Project identity. Auto-loaded by Claude Code at session start. |
| `.claude/skills/` | Technology-specific knowledge files generated from your actual dependencies. |
| `skill-instructions-hook.sh` | UserPromptSubmit hook that forces skill evaluation on every prompt. |
| `settings.json` | Hook registration wiring. |

### How to Use

Point SummonAIKit at your existing repo. It scans, identifies your tech stack, and generates the above artifacts. No manual configuration needed.

For full setup instructions, see: https://summonaikit.com/docs/getting-started

## Context7 MCP

### What It Does

Context7 is an MCP (Model Context Protocol) server developed by Upstash. It connects Claude Code to live, official documentation for the libraries you are actually using. Instead of relying on training data that may be outdated, Claude reads current docs on demand.

### How It Works

Context7 provides two main tools:
- `resolve-library-id` — matches library names to Context7-compatible identifiers
- `query-docs` — retrieves version-specific documentation for specific libraries

When Claude Code encounters a library reference during a coding session, Context7 fetches current documentation and injects it into the context.

### Setup

Add Context7 as an MCP server in Claude Code:

```bash
claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp
```

Or for the full plugin with skills, agents, and commands, install via the Context7 marketplace in Claude Code.

Context7 also offers a docs-researcher agent for focused lookups that keep context lean during long tasks.

For full setup instructions, see: https://context7.com/docs/clients/claude-code

### Usage

Simply add "use context7" to any prompt where you need current documentation, or let the auto-trigger skill recognize when documentation would help. For example:

- "Create a Next.js middleware that checks for a valid JWT in cookies. use context7"
- "Show me how to configure Express.js session middleware. use context7"

## How They Work Together

SummonAIKit and Context7 solve different problems at different times:

| Tool | When | What |
|---|---|---|
| SummonAIKit | Once, at scaffolding time | Generates static project context (CLAUDE.md, skills) from your codebase |
| Context7 | Continuously, during every session | Provides live documentation lookup for current library APIs |

SummonAIKit tells Claude "here's what this project uses." Context7 tells Claude "here's the current documentation for what this project uses."

## When to Use

### Existing Repos (Primary Use Case)

1. Run SummonAIKit to scaffold CLAUDE.md and skills
2. Configure Context7 MCP for live documentation
3. Proceed with SpecArch workflow

```
Existing codebase → SummonAIKit scaffolds → Context7 MCP configured → Ready for SpecArch workflow
```

### New (Greenfield) Repos

SummonAIKit can't scaffold what doesn't exist. For greenfield projects:

1. Write `specification.md` first (see `docs/guides/specification.md`)
2. Have Claude Code scaffold the initial project structure
3. Run SummonAIKit after the initial code exists
4. Configure Context7 MCP for live documentation
5. Continue with the SpecArch workflow

```
specification.md → Claude Code scaffolds project → SummonAIKit generates skills → Continue with SpecArch
```

## Relationship to SpecArch

SummonAIKit + Context7 handle the **tooling and knowledge layer**. SpecArch handles the **workflow layer**.

- **CLAUDE.md** (SummonAIKit) tells Claude "here's the project"
- **Skills** (SummonAIKit) tell Claude "here's what we use and how"
- **Context7 MCP** tells Claude "here's the current documentation"
- **Hooks** (SummonAIKit) ensure skills are evaluated every prompt
- **SpecArch workflow** structures how you and Claude collaborate over time

They are complementary. SummonAIKit + Context7 make every session informed. SpecArch makes every session productive and traceable.
