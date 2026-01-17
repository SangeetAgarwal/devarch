# DevArch

Software development and architecture guidance for the modern era — where AI is your pair programming partner.

## About

This repository contains practical guidance for software developers and architects, with a particular focus on effective workflows when collaborating with generative AI tools like Claude Code, GitHub Copilot, and similar assistants.

The patterns here emerged from real-world project experience, not theory. They address the actual challenges developers face when integrating AI into their daily workflow.

## Why This Exists

AI-assisted development is powerful but introduces new challenges:

- **Context limitations** — AI tools have finite memory and lose context
- **Session continuity** — Work spans multiple sessions; AI doesn't remember
- **Decision traceability** — "Why did we do it this way?" gets lost
- **Knowledge transfer** — Onboarding AI to your codebase takes effort

Traditional development practices don't fully address these issues. This repo provides patterns that do.

## Contents

### Workflow Guides

Choose the guide that matches your tooling:

| Tool / Environment | Guide | Best For |
|--------------------|-------|----------|
| **Claude Code CLI** | [Claude Code Workflow Guide](docs/claude-code-workflow-guide.md) | Terminal-first development, automatic hooks, integrated workflow |
| **GitHub Copilot + Visual Studio 2026** | [Copilot Workflow Guide](docs/copilot-workflow-guide.md) | Windows development, .NET/C# projects, Azure DevOps integration |

Both workflows provide **100% functional equivalence** — same patterns, same results, different tools.

### Additional Guides

| Guide | Description |
|-------|-------------|
| [AWS Serverless Backend Guide](docs/aws-serverless-backend-guide.md) | Let AI build your API: Lambda, API Gateway, DynamoDB, custom domains, hardening |
| [Architecture Decision Records](docs/architecture-decision-records-guide.md) | When and how to document design decisions with ADRs |

### Key Topics Covered

- **Context management** — Strategies for working within AI context limits
- **Session summaries** — Maintaining continuity across sessions
- **Work documentation** — Patterns for preserving decisions and progress
- **Project organization** — Folder structures that work with AI tools
- **Hooks and automation** — Reducing manual overhead

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
├── scripts/                              # 8 PowerShell automation scripts
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
│       └── {branch-name}/                # Work folders (match branch names)
│           ├── README.md
│           ├── implementation-plan.md
│           └── context/                  # Work summaries
└── [your existing code]
```

The scripts work in any repository - they just manage documentation and generate Copilot prompts. Your actual code stays in your existing structure.

### Next Steps After Setup

1. Read the [Copilot Workflow Guide](docs/copilot-workflow-guide.md) for detailed usage
2. Run `.\scripts\New-Session.ps1` to start your first session
3. Use `.\scripts\Context-Check.ps1` regularly to monitor context
4. Generate work summaries after significant milestones with `.\scripts\New-WorkSummary.ps1`

## Philosophy

1. **Documentation is memory** — What you write down survives; what stays in AI context doesn't
2. **Progressive capture** — Document as you go, not at the end
3. **Branch = Work folder** — Keep related artifacts together
4. **Explicit over implicit** — AI works better with clear structure and instructions

## Dual Workflow Approach

This repository supports two complementary workflows:

### Claude Code CLI Workflow
- **Automation**: Automatic hooks for session management
- **Integration**: Native CLI commands (`write work summary`, `/context`)
- **Best for**: Terminal-based development, quick automation

### GitHub Copilot + Visual Studio Workflow
- **Automation**: PowerShell scripts for session management
- **Integration**: Visual Studio 2026, Azure DevOps pipelines
- **Best for**: Windows development, .NET ecosystem, enterprise environments

**Both workflows share the same core principles:**
- Session summaries for context continuity
- Work folders matching branches
- ADRs for architectural decisions
- Implementation plans for progress tracking
- Progressive documentation throughout development

## Contributing

Found a pattern that works well? Have improvements to suggest? Contributions are welcome.

## License

MIT

---

*These patterns evolved from building [Sharpee](https://github.com/ChicagoDave/sharpee), a parser-based interactive fiction engine, using AI-assisted development.*
