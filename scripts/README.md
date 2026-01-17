# PowerShell Scripts for GitHub Copilot Workflow

This directory contains PowerShell scripts that automate the GitHub Copilot + Visual Studio 2026 workflow, providing functional equivalence to Claude Code CLI's automated hooks.

## Overview

These scripts help manage:
- Session summaries and context loading
- Work summaries and documentation
- Feature branch creation and structure
- Architecture Decision Records (ADRs)
- Implementation plan tracking
- Context size monitoring

## Prerequisites

- **PowerShell 5.1 or later** (pre-installed on Windows)
- **Git** (must be in PATH)
- **Visual Studio 2026** with GitHub Copilot extensions
- Repository root as working directory

## Script Reference

### Session Management

#### `New-Session.ps1`

Start a new work session with context loading.

**Usage:**
```powershell
.\scripts\New-Session.ps1
```

**What it does:**
1. Creates a new session summary file from template
2. Displays previous session for context
3. Generates Copilot prompt to load architectural context
4. Copies prompt to clipboard automatically

**Parameters:**
- `-Resume` - Resume current session instead of creating new one

**Example:**
```powershell
# Start fresh session
.\scripts\New-Session.ps1

# Resume existing session
.\scripts\New-Session.ps1 -Resume
```

**Output:**
- Creates `docs/context/session-YYYYMMDD-HHMM-{branch}.md`
- Generates context-loading prompt for Copilot
- Shows previous session content

---

#### `End-Session.ps1`

End a work session with cleanup and summary.

**Usage:**
```powershell
.\scripts\End-Session.ps1
```

**What it does:**
1. Prompts for work summary generation
2. Updates session status to "Completed"
3. Commits and pushes changes
4. Reminds to clear Copilot context

**Parameters:**
- `-NoCommit` - Skip automatic git commit
- `-NoSummary` - Skip work summary prompt

**Example:**
```powershell
# Full session end with all steps
.\scripts\End-Session.ps1

# End session without commit
.\scripts\End-Session.ps1 -NoCommit
```

---

#### `Resume-Session.ps1`

Resume work with fresh, minimal context.

**Usage:**
```powershell
.\scripts\Resume-Session.ps1
```

**What it does:**
1. Checks that context has been cleared
2. Finds latest session and work summaries
3. Generates minimal context-loading prompt
4. Emphasizes clean context start

**Example:**
```powershell
.\scripts\Resume-Session.ps1
```

**Best Practice:**
Before running, ensure you've:
- Cleared Copilot chat history
- Closed all document windows
- Ready for fresh start

---

### Documentation

#### `New-WorkSummary.ps1`

Generate a work summary using Claude Opus via Copilot.

**Usage:**
```powershell
.\scripts\New-WorkSummary.ps1 -Topic "description"
```

**What it does:**
1. Collects git information (commits, diffs, stats)
2. Generates comprehensive Copilot prompt
3. Creates template file for summary
4. Copies prompt to clipboard

**Parameters:**
- `-Topic` (required) - Brief description for filename
- `-CommitCount` - Number of recent commits to include (default: 10)

**Example:**
```powershell
# Generate summary for auth work
.\scripts\New-WorkSummary.ps1 -Topic "auth-implementation"

# Summary with last 5 commits only
.\scripts\New-WorkSummary.ps1 -Topic "bugfix-login" -CommitCount 5
```

**Output:**
- Creates `docs/work/{branch}/context/YYYY-MM-DD-HHMM-{topic}.md`
- Generates detailed prompt for Copilot

**When to use:**
- After completing a feature or component
- After multi-hour work sessions
- Before switching to different work
- After solving complex problems

---

#### `New-ADR.ps1`

Create a new Architecture Decision Record.

**Usage:**
```powershell
.\scripts\New-ADR.ps1 -Title "decision-title"
```

**What it does:**
1. Auto-numbers ADRs sequentially (ADR-001, ADR-002, etc.)
2. Generates comprehensive ADR template
3. Creates Copilot prompt to help complete ADR
4. Copies prompt to clipboard

**Parameters:**
- `-Title` (required) - Title of the decision
- `-Status` - Initial status: Proposed, Accepted, Deprecated, Superseded (default: Proposed)

**Example:**
```powershell
# Create new ADR
.\scripts\New-ADR.ps1 -Title "Use PostgreSQL for database"

# Create ADR with Accepted status
.\scripts\New-ADR.ps1 -Title "JWT authentication" -Status "Accepted"
```

**Output:**
- Creates `docs/architecture/adrs/adr-NNN-{title}.md`
- Generates completion prompt for Copilot

**Template includes:**
- Status, date, context
- Decision statement
- Consequences (positive, negative, neutral)
- Alternatives considered
- Implementation notes
- References and follow-up actions

---

### Feature Management

#### `New-Feature.ps1`

Create a new feature branch with complete work structure.

**Usage:**
```powershell
.\scripts\New-Feature.ps1 -FeatureName "feature-name"
```

**What it does:**
1. Creates feature branch (`feature-{name}`)
2. Creates work directory structure
3. Generates README.md and implementation-plan.md templates
4. Commits initial structure
5. Automatically starts new session

**Parameters:**
- `-FeatureName` (required) - Name in kebab-case (e.g., "user-auth")
- `-NoBranch` - Skip creating new branch (use current)

**Example:**
```powershell
# Create new feature
.\scripts\New-Feature.ps1 -FeatureName "user-auth"

# Use current branch
.\scripts\New-Feature.ps1 -FeatureName "api-refactor" -NoBranch
```

**Creates:**
```
docs/work/feature-{name}/
  ├── README.md              # Feature overview
  ├── implementation-plan.md # Progress tracking
  └── context/               # Work summaries
```

---

#### `Update-ImplementationPlan.ps1`

Helper to update implementation plan progress.

**Usage:**
```powershell
.\scripts\Update-ImplementationPlan.ps1
```

**What it does:**
1. Parses current implementation plan
2. Counts tasks by status (✅ Done, 🚧 In Progress, ⏳ Pending, ❌ Blocked)
3. Recalculates progress statistics
4. Updates summary table

**Parameters:**
- `-PlanFile` - Path to plan file (default: current branch's plan)

**Example:**
```powershell
# Update plan for current branch
.\scripts\Update-ImplementationPlan.ps1

# Update specific plan
.\scripts\Update-ImplementationPlan.ps1 -PlanFile "docs/work/feature-auth/implementation-plan.md"
```

**Task Status Markers:**
- `✅ Done` - Task completed
- `🚧 In Progress` - Currently working on this
- `⏳ Pending` - Not started yet
- `❌ Blocked` - Cannot proceed due to dependency

---

### Utilities

#### `Context-Check.ps1`

Monitor context size and provide recommendations.

**Usage:**
```powershell
.\scripts\Context-Check.ps1
```

**What it does:**
1. Estimates context usage based on observable factors
2. Prompts for open file count
3. Analyzes session duration and chat activity
4. Warns when context is getting large
5. Recommends cleanup actions

**Example:**
```powershell
.\scripts\Context-Check.ps1
```

**Provides:**
- Estimated token usage
- Usage percentage vs. target limit
- Breakdown by category
- Actionable recommendations

**Warnings:**
- Low (< 50%) - Continue normally
- Moderate (50-75%) - Start being mindful
- High (> 75%) - Take action soon

**Note:** This is an estimate since actual Copilot context is not directly queryable.

---

## Workflow Examples

### Starting a New Feature

```powershell
# 1. Create feature with complete structure
.\scripts\New-Feature.ps1 -FeatureName "user-authentication"

# 2. Work is created automatically:
#    - Branch: feature-user-authentication
#    - Work folder: docs/work/feature-user-authentication/
#    - Session file created
#    - Copilot prompt generated and copied

# 3. Paste prompt into Copilot Chat
# 4. Start implementing
```

### During a Work Session

```powershell
# Check context periodically (every 30-60 min)
.\scripts\Context-Check.ps1

# If context is getting high:
# 1. Generate work summary
.\scripts\New-WorkSummary.ps1 -Topic "progress-update"

# 2. End session
.\scripts\End-Session.ps1

# 3. Clear Copilot context (manually in VS)
# 4. Resume with fresh context
.\scripts\Resume-Session.ps1
```

### Making Architecture Decisions

```powershell
# 1. Create ADR before implementation
.\scripts\New-ADR.ps1 -Title "Use JWT for authentication"

# 2. Work with Copilot to complete ADR
#    (prompt is copied to clipboard)

# 3. Edit the generated file
code docs/architecture/adrs/adr-NNN-use-jwt-for-authentication.md

# 4. Commit the ADR
git add docs/architecture/adrs/adr-NNN-*.md
git commit -m "docs: add ADR for JWT authentication"
```

### Ending Work Day

```powershell
# 1. Update implementation plan
.\scripts\Update-ImplementationPlan.ps1

# 2. Generate work summary if significant work done
.\scripts\New-WorkSummary.ps1 -Topic "daily-progress"

# 3. End session with cleanup
.\scripts\End-Session.ps1

# 4. Push changes (done automatically by End-Session)
```

### Starting Work Day

```powershell
# 1. Clear context manually:
#    - Clear Copilot chat history
#    - Close all documents

# 2. Resume with minimal context
.\scripts\Resume-Session.ps1

# 3. Paste generated prompt into Copilot Chat

# 4. Review summary and continue work
```

---

## Common Issues

### Execution Policy Error

**Error:** "cannot be loaded because running scripts is disabled on this system"

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Git Not Found

**Error:** "git is not recognized as an internal or external command"

**Solution:** Ensure Git is installed and in your PATH environment variable.

### Clipboard Not Working

**Issue:** Prompt not copied to clipboard

**Solution:** Manually copy the output displayed in console. The scripts display the full prompt even if clipboard fails.

### Wrong Directory

**Error:** "Not in a git repository"

**Solution:** Run scripts from the repository root directory:
```powershell
cd /path/to/devarch
.\scripts\New-Session.ps1
```

---

## Script Conventions

All scripts follow these conventions:

1. **Approved PowerShell Verbs:** New-, Update-, etc.
2. **Parameter Validation:** Required parameters are enforced
3. **Error Handling:** Graceful errors with helpful messages
4. **Color Output:** Color-coded console messages for better UX
5. **UTF-8 Encoding:** All generated files use UTF-8
6. **Git Integration:** Handle git errors gracefully
7. **Clipboard Support:** Auto-copy prompts when available

---

## Tips

1. **Run from repository root** - Always execute scripts from the root directory
2. **Use tab completion** - PowerShell supports tab completion for script paths
3. **Check help** - Use `Get-Help .\scripts\ScriptName.ps1` for details
4. **Chain commands** - You can chain related scripts together
5. **Customize templates** - Edit generated files to match your needs

---

## Integration with Visual Studio

### Setting up shortcuts

Create a Visual Studio external tools entry:

1. Tools → External Tools → Add
2. Title: "New Session"
3. Command: `powershell.exe`
4. Arguments: `-ExecutionPolicy Bypass -File "$(SolutionDir)scripts\New-Session.ps1"`
5. Initial directory: `$(SolutionDir)`

Repeat for other commonly used scripts.

### PowerShell Terminal

Use PowerShell terminal in Visual Studio:

1. View → Terminal (Ctrl+`)
2. Select PowerShell from dropdown
3. Run scripts directly: `.\scripts\New-Session.ps1`

---

## Additional Resources

- [Copilot Workflow Guide](../docs/copilot-workflow-guide.md) - Full workflow documentation
- [Copilot Instructions](../.github/copilot-instructions.md) - Project instructions for Copilot
- [Claude Code Workflow Guide](../docs/claude-code-workflow-guide.md) - Original workflow patterns

---

## Contributing

When adding new scripts:

1. Follow PowerShell approved verb naming
2. Include parameter validation
3. Add color-coded output
4. Handle errors gracefully
5. Update this README
6. Test on Windows PowerShell 5.1+

---

**Note:** These scripts provide 100% functional equivalence to Claude Code CLI hooks, adapted for manual triggering in the Visual Studio environment. The core workflow remains the same, just with explicit script execution instead of automatic hooks.
