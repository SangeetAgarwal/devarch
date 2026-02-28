# DevArch

Software development and architecture guidance for the modern era — where AI is your pair programming partner.

## About

This repository contains practical guidance for software developers and architects, with a particular focus on effective workflows when collaborating with generative AI tools like Claude Code, GitHub Copilot, and similar assistants.

The patterns here emerged from real-world project experience, not theory. They address the actual challenges developers face when integrating AI into their daily workflow.

This is a living repository. Patterns are applied to real projects, lessons are brought back, and the workflow evolves. If something doesn't survive contact with a real codebase, it gets revised or removed.

## Why This Exists

AI-assisted development is powerful but introduces new challenges:

- **Context limitations** — AI tools have finite memory and lose context
- **Session continuity** — Work spans multiple sessions; AI doesn't remember
- **Decision traceability** — "Why did we do it this way?" gets lost
- **Knowledge transfer** — Onboarding AI to your codebase takes effort
- **Intent gets lost** — AI plans without clear directives produce generic results

Traditional development practices don't fully address these issues. This repo provides patterns that do.

## Philosophy

1. **Documentation is memory** — What you write down survives; what stays in AI context doesn't
2. **Human intent first** — Specifications capture what you want before AI plans how to build it
3. **Progressive capture** — Document as you go, not at the end
4. **Branch = Work folder** — Keep related artifacts together
5. **Explicit over implicit** — AI works better with clear structure and instructions
6. **Learn by building** — Apply patterns to real projects, bring lessons back, evolve the workflow

## Guides

| Guide                                                                        | Description                                                                                                   |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [Claude Code Workflow](docs/claude-code-workflow-guide.md)                   | Terminal-first development with automatic hooks, native skill loading, and SummonAIKit + Context7 integration |
| [Copilot Workflow](docs/copilot-workflow-guide.md)                           | PowerShell-driven workflow for Visual Studio 2026, .NET/C# projects, and Azure DevOps                         |
| [Adopting the Copilot Workflow](docs/adopting-copilot-workflow.md)           | Step-by-step setup for applying the Copilot workflow to new or existing projects                              |
| [AWS Serverless Backend](docs/aws-serverless-backend-guide.md)               | Let AI build your API: Lambda, API Gateway, DynamoDB, custom domains, hardening                               |
| [Architecture Decision Records](docs/architecture-decision-records-guide.md) | When and how to document design decisions with ADRs                                                           |

### Key Topics Covered

- **Context management** — Strategies for working within AI context limits
- **Session summaries** — Maintaining continuity across sessions
- **Work documentation** — Patterns for preserving decisions and progress
- **Project organization** — Folder structures that work with AI tools
- **Hooks and automation** — Reducing manual overhead

## Conventions

Conventions are reusable patterns this repo documents and follows. This section grows as new patterns prove themselves in real projects.

| Convention                             | What It Does                                                                                                                                                                                                             | Guide                                                |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------- |
| **specification.md**                   | Human-authored directive capturing intent, constraints, and decisions before the LLM generates an implementation plan. Lives at `docs/work/{feature}/specification.md`.                                                  | [guide](docs/guides/specification.md)                |
| **SummonAIKit + Context7 scaffolding** | Auto-generates `CLAUDE.md`, skills, and hooks from your codebase (SummonAIKit). Provides live, version-specific documentation lookup during sessions (Context7).                                                         | [guide](docs/guides/scaffolding.md)                  |
| **Skill-building standards**           | Guidelines for creating custom workflow skills aligned with Anthropic's official conventions — YAML frontmatter, progressive disclosure, trigger phrases.                                                                | [guide](docs/guides/skill-standards.md)              |
| **Skill template**                     | Starter template for new skills.                                                                                                                                                                                         | [template](docs/guides/skill-template/SKILL.md)      |
| **Gap resolution**                     | After the LLM generates an implementation plan, review the gaps it surfaces, make decisions, and update the specification. The spec remains the single source of truth.                                                  | [guide](docs/guides/specification.md#gap-resolution) |
| **External setup**                     | Explicitly list manual steps the human must complete outside of Claude Code — creating accounts, configuring services, copying API keys. Prevents the LLM from building against services that don't exist.               | [guide](docs/guides/specification.md#external-setup) |
| **Verification**                       | After the build, verify the implementation against the specification. Two layers: tests (prove code works) and specification verification (prove it matches requirements). Code is cheap — confidence is the bottleneck. | [guide](docs/guides/specification.md#verification)   |

## Dual Workflow Approach

This repository supports two complementary workflows:

### Claude Code CLI Workflow

- **Automation**: Automatic hooks for session management
- **Integration**: Native CLI commands (`write work summary`, `/context`)
- **Scaffolding**: SummonAIKit + Context7 for project context and live documentation
- **Best for**: Terminal-based development, quick automation

### GitHub Copilot + Visual Studio Workflow

- **Automation**: PowerShell scripts for session management
- **Integration**: Visual Studio 2026, Azure DevOps pipelines
- **Best for**: Windows development, .NET ecosystem, enterprise environments

Both workflows share the same core principles — session continuity, work folders, ADRs — adapted to each tool's strengths:

- Session summaries for context continuity
- Work folders matching branches
- ADRs for architectural decisions
- Implementation plans for progress tracking
- Specifications for capturing human intent
- Progressive documentation throughout development

## Quick Start

### For Claude Code CLI Users

```bash
# Clone and start
git clone https://github.com/SangeetAgarwal/devarch.git
cd devarch

# Read the guide
cat docs/claude-code-workflow-guide.md

# Set up hooks (optional)
# See guide for .claude/settings.json configuration
```

### For GitHub Copilot + Visual Studio 2026 Users

```powershell
# Clone repository
git clone https://github.com/SangeetAgarwal/devarch.git
cd devarch

# Create a new feature
.\scripts\New-Feature.ps1 -FeatureName "your-feature"

# Read the comprehensive guide
code docs\copilot-workflow-guide.md

# See all available scripts
Get-ChildItem .\scripts\*.ps1
```

**Prerequisites:**

- PowerShell 5.1+ (pre-installed on Windows)
- Git
- Visual Studio 2026 with GitHub Copilot extensions
- Claude Opus 4.5 model (select in Copilot settings)

## Applying This Workflow to Your Own Projects

Once you've reviewed this repository, you can apply the GitHub Copilot workflow to any of your projects:

### For a New Project

```powershell
# 1. Create your project repository
mkdir my-project && cd my-project
git init

# 2. Copy the workflow files from devarch
# Option A: Manual copy
# Copy these to your project:
#   - scripts/ (all PowerShell scripts)
#   - .github/copilot-instructions.md
#   - .copilotignore
#   - docs/context/.session-template.md

# Option B: Using git (recommended)
git remote add devarch https://github.com/SangeetAgarwal/devarch.git
git fetch devarch
git checkout devarch/copilot/adapt-cli-workflow-for-copilot -- scripts/ .github/copilot-instructions.md .copilotignore docs/context/.session-template.md
git remote remove devarch

# 3. Customize for your project
# Edit .github/copilot-instructions.md:
#   - Update "Overview" section with your project description
#   - Update "Current Work" section
#   - Update "Project Structure" to match your codebase
# Edit .copilotignore:
#   - Add your project-specific build outputs
#   - Add framework-specific folders to ignore

# 4. Create required directories
mkdir -p docs/context docs/architecture/adrs docs/work

# 5. Start your first feature
.\scripts\New-Feature.ps1 -FeatureName "initial-setup"
# This creates the branch, work folder, and initial documentation

# 6. Begin working with the workflow
# The generated prompt is already in your clipboard - paste into Copilot Chat
```

### For an Existing Project

```powershell
# 1. Navigate to your existing repository
cd path/to/your-existing-repo

# 2. Copy the workflow files (same as above - Option A or B)
git remote add devarch https://github.com/SangeetAgarwal/devarch.git
git fetch devarch
git checkout devarch/copilot/adapt-cli-workflow-for-copilot -- scripts/ .github/copilot-instructions.md .copilotignore docs/context/.session-template.md
git remote remove devarch

# 3. Customize for your existing project
# Edit .github/copilot-instructions.md with your:
#   - Project overview and architecture
#   - Current conventions and patterns
#   - Existing folder structure
#   - Build/test commands
# Edit .copilotignore for your build artifacts

# 4. Create documentation structure (if not exists)
mkdir -p docs/context docs/architecture/adrs docs/work

# 5. Start tracking your current work
.\scripts\New-Session.ps1
# Paste the generated prompt into Copilot Chat to begin
```

### Key Files to Customize

After copying the workflow files, customize these for your specific project:

1. **`.github/copilot-instructions.md`** (IMPORTANT)
   - Replace the devarch-specific content with your project details
   - Update the "Overview", "Current Work", and "Project Structure" sections
   - Add your project's specific conventions, patterns, and architecture decisions
   - Update build/test commands

2. **`.copilotignore`**
   - Add your project-specific build directories (e.g., `target/` for Java, `build/` for Gradle)
   - Add framework-specific folders (e.g., `venv/` for Python, `vendor/` for PHP)
   - Keep the common entries already present

3. **`docs/context/.session-template.md`** (optional)
   - Modify the template structure if you need different sections
   - Most projects can use it as-is

### What Gets Created

The workflow creates this structure in your project:

```
your-project/
├── .github/
│   └── copilot-instructions.md          # Project instructions for Copilot
├── .copilotignore                        # Context optimization
├── scripts/                              # PowerShell automation scripts
│   ├── New-Session.ps1
│   ├── Resume-Session.ps1
│   ├── End-Session.ps1
│   ├── New-WorkSummary.ps1
│   ├── New-Feature.ps1
│   ├── New-ADR.ps1
│   ├── Context-Check.ps1
│   ├── Update-ImplementationPlan.ps1
│   └── README.md
├── docs/
│   ├── context/                          # Session summaries
│   │   ├── .session-template.md
│   │   └── session-*.md
│   ├── architecture/
│   │   └── adrs/                         # Architecture decisions
│   └── work/
│       └── {branch-name}/               # Work folders (match branch names)
│           ├── README.md
│           ├── implementation-plan.md
│           └── context/                  # Work summaries
└── [your existing code]
```

The scripts work in any repository — they manage documentation and generate Copilot prompts. Your actual code stays in your existing structure.

### Next Steps After Setup

1. Read the [Copilot Workflow Guide](docs/copilot-workflow-guide.md) for detailed usage
2. Run `.\scripts\New-Session.ps1` to start your first session
3. Use `.\scripts\Context-Check.ps1` regularly to monitor context
4. Generate work summaries after significant milestones with `.\scripts\New-WorkSummary.ps1`

## Full Project Structure

This shows the complete structure including both workflow toolchains and all conventions:

```
your-project/
├── .claude/                              # Claude Code configuration (CLI workflow)
│   ├── CLAUDE.md                         # Project overview (generated by SummonAIKit)
│   ├── settings.json                     # Hooks and permissions
│   └── skills/                           # Tech-specific and custom skills
├── .github/
│   └── copilot-instructions.md           # Project instructions (Copilot workflow)
├── .copilotignore                        # Context optimization (Copilot workflow)
├── scripts/                              # PowerShell automation (Copilot workflow)
├── docs/
│   ├── context/                          # Session summaries
│   │   ├── .session-template.md
│   │   └── session-*.md
│   ├── architecture/
│   │   └── adrs/                         # Architecture decision records
│   ├── guides/                           # Workflow conventions and standards
│   │   ├── scaffolding.md
│   │   ├── specification.md
│   │   ├── skill-standards.md
│   │   └── skill-template/
│   │       └── SKILL.md
│   ├── references/                       # Reference material (PDFs, etc.)
│   └── work/
│       └── {feature-name}/               # Work folders (match branch names)
│           ├── specification.md           # Human intent
│           ├── implementation-plan.md     # LLM-generated plan
│           ├── README.md                  # Retrospective (written after completion)
│           └── context/                   # Work summaries
└── [your existing code]
```

## References

| Resource                                                       | Location                             |
| -------------------------------------------------------------- | ------------------------------------ |
| Anthropic's Complete Guide to Building Skills for Claude (PDF) | [docs/references/](docs/references/) |

## Contributing

Found a pattern that works well? Have improvements to suggest? Contributions are welcome.

## License

MIT

---

_Built by [Sangeet Agarwal](https://github.com/SangeetAgarwal)._
