# Project Instructions for GitHub Copilot

> **Model Selection**: Use **Claude Opus 4.5** when available for best results with architectural reasoning and context management.

## Overview

This repository provides practical guidance for AI-assisted software development, with a focus on effective workflows when collaborating with AI tools like Claude Code CLI and GitHub Copilot.

The workflow patterns here address real challenges in AI-assisted development:
- Context limitations and memory loss
- Session continuity across multiple work periods
- Decision traceability and knowledge transfer
- Progressive documentation and context management

## MAJOR DIRECTIONS

### Critical Rules

1. **NEVER delete files without explicit confirmation**
2. **ALWAYS check existing patterns before adding new ones**
3. **Documentation is memory** - What you write survives; what stays in context doesn't
4. **Progressive capture** - Document as you go, not at the end
5. **Explicit over implicit** - AI works better with clear structure and instructions

### Context Management (CRITICAL)

GitHub Copilot in Visual Studio has context limitations. Follow these practices:

1. **Start sessions with clean context**
   - Clear Copilot chat history before starting new work
   - Close unnecessary document windows
   - Load only essential files for current task

2. **Monitor context size regularly**
   - Use `scripts/Context-Check.ps1` to estimate context usage
   - Keep fewer than 10 files open simultaneously
   - Close completed work files promptly

3. **Save context before cleanup**
   - Run `scripts/End-Session.ps1` before clearing context
   - Generate work summaries for significant changes
   - Commit and push changes before context refresh

4. **Resume with minimal context**
   - Use `scripts/Resume-Session.ps1` to load only essential context
   - Read session summaries and work summaries
   - Load implementation plans and ADRs as needed

## Architecture Principles

### Documentation Structure

The project follows a strict documentation hierarchy:

```
docs/
├── context/                    # Session summaries (progressive)
│   ├── session-YYYYMMDD-HHMM-{branch}.md
│   └── archived/               # Old sessions
├── architecture/
│   └── adrs/                   # Architecture Decision Records
│       └── adr-NNN-{title}.md
├── work/
│   └── {branch}/               # Work area matching git branch
│       ├── README.md           # Feature overview
│       ├── implementation-plan.md  # Progress tracking
│       └── context/            # Detailed work summaries
│           └── YYYY-MM-DD-HHMM-{topic}.md
└── reference/                  # Stable reference docs
```

### Branch = Work Folder Pattern

**Git branch name MUST match work folder name.**

- Branch: `feature-auth` → Work folder: `docs/work/feature-auth/`
- Branch: `api-refactor` → Work folder: `docs/work/api-refactor/`

This keeps all related artifacts together and maintains historical documentation after merge.

## Current Work

Track active work in session files and implementation plans. Always update these as work progresses:

- Current session: Check latest `docs/context/session-*.md`
- Active features: Check `docs/work/{branch}/implementation-plan.md`
- Recent decisions: Check `docs/architecture/adrs/` for latest ADRs

## Project Structure

### Core Directories

- `docs/` - All documentation, organized by type and purpose
- `scripts/` - PowerShell automation scripts for workflow management
- `.azuredevops/pipelines/` - Azure DevOps CI/CD pipelines
- `.github/` - GitHub and Copilot configuration

### File Naming Conventions

- Session summaries: `session-YYYYMMDD-HHMM-{branch}.md`
- Work summaries: `YYYY-MM-DD-HHMM-{topic}.md`
- ADRs: `adr-NNN-{title}.md` (sequential numbering)
- Branches: `feature-*`, `bugfix-*`, `project-*`

## Work Patterns

### Starting a New Feature

Use the automated script:
```powershell
.\scripts\New-Feature.ps1 -FeatureName "feature-name"
```

This will:
1. Create feature branch
2. Create `docs/work/feature-name/` directory
3. Generate README.md and implementation-plan.md templates
4. Start a new session automatically

Or manually:
1. Create branch: `git checkout -b feature-name`
2. Create work directory: `docs/work/feature-name/`
3. Write `README.md` describing the feature
4. Write `implementation-plan.md` to track progress
5. Run `scripts/New-Session.ps1` to start session

### Session Workflow

#### Starting a Session
```powershell
.\scripts\New-Session.ps1
```
- Creates session file from template
- Shows previous session for context
- Generates Copilot prompt with architectural context

#### During a Session
- Update session file progressively as you work
- Mark completed items with ✅
- Document key decisions immediately
- Run `Context-Check.ps1` periodically

#### Ending a Session
```powershell
.\scripts\End-Session.ps1
```
- Prompts for work summary generation
- Reminds to clear Copilot context
- Updates session status
- Commits and pushes changes

#### Resuming a Session
```powershell
.\scripts\Resume-Session.ps1
```
- Finds latest session and work summaries
- Generates minimal context-loading prompt
- Emphasizes clean context start

### Work Summaries

Generate after significant work:
```powershell
.\scripts\New-WorkSummary.ps1 -Topic "description"
```

This collects:
- Recent commits and diffs
- Changed files and statistics
- Generates comprehensive Claude Opus prompt

Saves to: `docs/work/{branch}/context/YYYY-MM-DD-HHMM-{topic}.md`

**When to create:**
- After completing a feature or major component
- After multi-hour work sessions
- Before switching to different work
- After solving complex problems

### Architecture Decision Records (ADRs)

Create before implementing significant changes:
```powershell
.\scripts\New-ADR.ps1 -Title "decision-title"
```

Auto-numbers (ADR-001, ADR-002, etc.) and generates template with:
- Status, context, decision
- Consequences (positive, negative, neutral)
- Alternatives considered
- Implementation notes

**When to write:**
- Before complex feature implementation
- When choosing between multiple approaches
- For decisions affecting multiple components
- For hard-to-reverse decisions (schemas, APIs, frameworks)

### Implementation Plans

Located at: `docs/work/{branch}/implementation-plan.md`

Track progress with phase tables:

| Phase | Task | Status | Notes |
|-------|------|--------|-------|
| 1 | Setup | ✅ Done | Completed |
| 1 | Config | 🚧 In Progress | 80% complete |
| 2 | Tests | ⏳ Pending | Blocked by config |
| 3 | Deploy | ❌ Blocked | Waiting for approval |

Update with:
```powershell
.\scripts\Update-ImplementationPlan.ps1
```

## Copilot Chat Patterns

### Effective Prompting

1. **Load context explicitly**
   ```
   @workspace Read docs/work/feature-auth/README.md and implementation-plan.md.
   Review the current progress and suggest next steps.
   ```

2. **Reference architecture**
   ```
   Based on ADR-007 (monetary values as integers), implement the price 
   calculation function following the established pattern.
   ```

3. **Request summaries**
   ```
   Generate a work summary for the authentication middleware implementation.
   Include: objectives, what was accomplished, key decisions, challenges,
   next steps. Use the format in docs/work/feature-auth/context/ examples.
   ```

4. **Get specific help**
   ```
   Review the session file docs/context/session-20260117-1400-feature-auth.md
   and help me complete the remaining open items.
   ```

### Context Loading Strategy

For new sessions, use this prompt pattern (generated by `Resume-Session.ps1`):

```
I'm resuming work on [branch-name]. Please help me get started:

1. Read the feature overview: docs/work/[branch]/README.md
2. Review the implementation plan: docs/work/[branch]/implementation-plan.md
3. Check the latest session: docs/context/session-[latest].md
4. Read the most recent work summary: docs/work/[branch]/context/[latest].md
5. Review relevant ADRs: [list specific ADRs]

Based on these, summarize:
- Current status
- Completed work
- Next priority tasks
- Any blockers
```

## Azure DevOps Integration

### Pipelines

Located in `.azuredevops/pipelines/`:

- `session-tracking.yml` - Auto-generates session documentation on push
- `work-summary.yml` - Manual trigger for work summary assistance

### Work Item Linking

Reference work items in commits:
```
git commit -m "feat: implement auth middleware #1234"
```

Link ADRs to work items in the ADR's References section.

## Visual Studio 2026 Workflow

### Key Keyboard Shortcuts

- `Ctrl+Shift+/` - Open Copilot Chat
- `Ctrl+I` - Inline Copilot suggestions
- `Alt+/` - Next Copilot suggestion
- `Esc` - Dismiss Copilot suggestion
- `Ctrl+K Ctrl+X` - Open snippet picker

### Recommended Extensions

- GitHub Copilot (required)
- GitHub Copilot Chat (required)
- PowerShell (for script execution)
- GitLens (for better git integration)

### File Organization

Keep Solution Explorer organized:
- Pin frequently accessed files
- Use solution folders matching docs structure
- Close unused files to reduce context

### Testing in Visual Studio

- Use Test Explorer for running tests
- Right-click → Run Tests for specific tests
- View → Test Explorer (Ctrl+E, T)

## Context Management Strategies

### Manual Context Management

Unlike Claude Code CLI with automatic hooks, Copilot requires manual context management:

1. **Before starting work:**
   - Clear Copilot chat history: Settings → Clear chat
   - Close all document tabs: Window → Close All Documents
   - Run `Resume-Session.ps1` for context-loading prompt

2. **During work:**
   - Keep only relevant files open (< 10 files)
   - Close completed work files immediately
   - Run `Context-Check.ps1` every 30-60 minutes
   - Be selective with `@workspace` usage (loads entire workspace)

3. **When context feels heavy:**
   - Generate work summary with `New-WorkSummary.ps1`
   - Commit and push changes
   - Clear chat history
   - Close all documents
   - Reload only essential context

4. **Signs of context overload:**
   - Copilot responses become generic or incorrect
   - Copilot forgets earlier discussion
   - Suggestions become irrelevant
   - Response time increases

### Context Size Estimation

Approximate token usage:
- 1 line of code ≈ 10 tokens
- 1 file (100 lines) ≈ 1,000 tokens
- 1 chat message ≈ 50-500 tokens
- Workspace context ≈ 2,000-10,000 tokens

Target: Keep total context under 30,000 tokens for best results.

## Comparison with Claude Code CLI

| Aspect | Claude Code CLI | GitHub Copilot + VS 2026 |
|--------|-----------------|--------------------------|
| Context Management | Automatic hooks | Manual scripts |
| Session Start | Auto-creates session file | Run `New-Session.ps1` |
| Work Summary | `write work summary` command | Run `New-WorkSummary.ps1` |
| Context Check | `/context` command | Run `Context-Check.ps1` |
| Model | Claude Sonnet/Opus | Claude Opus 4.5 (select in VS) |
| Integration | Native CLI | Visual Studio extension |
| Automation | Built-in hooks | PowerShell scripts |
| Workflow | Fully automated | Semi-automated |

**Key Difference**: Copilot workflow requires more manual trigger of scripts, but provides same functional equivalence through PowerShell automation.

## Troubleshooting

### Copilot Not Responding Correctly

1. Clear chat history and reload context
2. Close unnecessary files
3. Verify model selection (use Claude Opus 4.5)
4. Restart Visual Studio if issues persist

### Scripts Not Working

1. Check PowerShell execution policy: `Get-ExecutionPolicy`
2. If restricted: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
3. Run scripts from repository root directory
4. Ensure git is available in PATH

### Context Feels Overloaded

1. Run `New-WorkSummary.ps1` immediately
2. Commit all changes
3. Clear Copilot chat: Settings → Clear chat
4. Close all documents: Window → Close All Documents
5. Run `Resume-Session.ps1`
6. Load only minimal required context

### Git Issues in Scripts

1. Ensure you're in a git repository
2. Check git configuration: `git config --list`
3. Verify branch name: `git branch --show-current`
4. Run `git status` to check repository state

## Additional Resources

- [Claude Code Workflow Guide](docs/claude-code-workflow-guide.md) - Original workflow patterns
- [Architecture Decision Records Guide](docs/architecture-decision-records-guide.md) - ADR best practices
- [AWS Serverless Backend Guide](docs/aws-serverless-backend-guide.md) - Serverless architecture patterns
- [Scripts README](../scripts/README.md) - Detailed script documentation

## Notes

This workflow is designed to provide 100% functional equivalence to the Claude Code CLI workflow, adapted for manual triggering in the Visual Studio environment. The core principles remain the same:

1. **Documentation is memory**
2. **Progressive capture**
3. **Branch = Work folder**
4. **Explicit over implicit**
5. **Context management is critical**

Use the PowerShell scripts to reduce friction and maintain the same productivity as Claude Code CLI users enjoy.
