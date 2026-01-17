<#
.SYNOPSIS
    Generate a work summary using Claude Opus via Copilot.

.DESCRIPTION
    Collects git information (commits, diffs, stats) and generates a comprehensive
    Copilot prompt to create a detailed work summary. Saves the summary to the
    appropriate context folder.

.PARAMETER Topic
    Brief description of the work (used in filename).

.PARAMETER CommitCount
    Number of recent commits to include (default: 10).

.EXAMPLE
    .\New-WorkSummary.ps1 -Topic "auth-implementation"
    Generates a work summary for authentication implementation.

.EXAMPLE
    .\New-WorkSummary.ps1 -Topic "bugfix-login" -CommitCount 5
    Generates a summary with last 5 commits.

.NOTES
    Author: DevArch
    Requires: Git, PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Topic,

    [Parameter(Mandatory=$false)]
    [int]$CommitCount = 10
)

$ErrorActionPreference = "Stop"

# Colors for console output
function Write-ColorOutput($ForegroundColor, $Message) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    Write-Output $Message
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header($Message) {
    Write-Host ""
    Write-ColorOutput -ForegroundColor Cyan "═══════════════════════════════════════════════════════════════"
    Write-ColorOutput -ForegroundColor Cyan "  $Message"
    Write-ColorOutput -ForegroundColor Cyan "═══════════════════════════════════════════════════════════════"
    Write-Host ""
}

function Write-Success($Message) {
    Write-ColorOutput -ForegroundColor Green "✓ $Message"
}

function Write-Info($Message) {
    Write-ColorOutput -ForegroundColor Yellow "ℹ $Message"
}

function Write-Error2($Message) {
    Write-ColorOutput -ForegroundColor Red "✗ $Message"
}

try {
    Write-Header "Generating Work Summary"

    # Check if we're in a git repository
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error2 "Not in a git repository. Please run this script from the repository root."
        exit 1
    }

    # Sanitize branch name for filename (replace slashes with dashes)
    $branchSafe = $gitBranch -replace '/', '-'

    Write-Info "Branch: $gitBranch"
    Write-Info "Topic: $Topic"

    # Setup paths
    $workFolder = "docs/work/$gitBranch"
    $contextFolder = "$workFolder/context"
    $today = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HHmm"
    $summaryFile = "$contextFolder/$today-$time-$Topic.md"

    # Ensure context directory exists
    if (-not (Test-Path $contextFolder)) {
        New-Item -ItemType Directory -Path $contextFolder -Force | Out-Null
        Write-Success "Created context directory: $contextFolder"
    }

    # Collect git information
    Write-Info "Collecting git information..."

    # Recent commits
    $commits = git log --oneline -n $CommitCount 2>$null
    if ($LASTEXITCODE -ne 0) {
        $commits = "No commits found"
    }

    # Changed files since last tag or first commit
    $changedFiles = git diff --name-status HEAD~$CommitCount..HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        $changedFiles = git diff --name-status --cached 2>$null
        if ($LASTEXITCODE -ne 0) {
            $changedFiles = "No changes found"
        }
    }

    # Diff statistics
    $diffStats = git diff --stat HEAD~$CommitCount..HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        $diffStats = git diff --stat --cached 2>$null
        if ($LASTEXITCODE -ne 0) {
            $diffStats = "No statistics available"
        }
    }

    # Current status
    $gitStatus = git status --short 2>$null
    if ($LASTEXITCODE -ne 0) {
        $gitStatus = "Unable to get git status"
    }

    # Generate Copilot prompt
    Write-Header "Copilot Work Summary Prompt"

    $prompt = @"
Please generate a comprehensive work summary for the work completed on branch **$gitBranch**.

**Topic**: $Topic

---

## Git Information

### Recent Commits (last $CommitCount)
``````
$commits
``````

### Changed Files
``````
$changedFiles
``````

### Diff Statistics
``````
$diffStats
``````

### Current Status
``````
$gitStatus
``````

---

## Instructions

Please create a detailed work summary following this structure:

``````markdown
# Work Summary: $Topic

**Date**: $today
**Branch**: ``$gitBranch``

## Objective
[What we set out to accomplish]

## What Was Accomplished
[Detailed description of work done, organized by area/component]

## Key Decisions
[Important choices made and rationale]

## Challenges & Solutions
[Problems encountered and how they were solved]

## Code Quality
[Notes on testing, code review, documentation]

## Files Modified
[List of key files changed with brief description]

## Next Steps
[What remains to be done, organized by priority]

## References
[Links to related files, ADRs, session files, etc.]
``````

**Requirements**:
1. Be specific and detailed - this summary will be used to resume work later
2. Highlight any architectural decisions or patterns established
3. Document any workarounds or technical debt created
4. Note any blockers or dependencies
5. Include specific file paths and line numbers where relevant
6. Cross-reference related ADRs, session files, or implementation plans

**Model Selection**: Use Claude Opus 4.5 for best quality.

After generating the summary, I'll save it to: ``$summaryFile``
"@

    Write-Host $prompt
    Write-Host ""

    # Copy to clipboard if available
    if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
        $prompt | Set-Clipboard
        Write-Success "Prompt copied to clipboard! Paste into Copilot Chat."
    } else {
        Write-Info "Clipboard not available. Copy the prompt above manually."
    }

    # Create placeholder file
    $placeholderContent = @"
# Work Summary: $Topic

**Date**: $today
**Branch**: ``$gitBranch``

## Objective
[Generated by Copilot - paste response here]

## What Was Accomplished


## Key Decisions


## Challenges & Solutions


## Code Quality


## Files Modified


## Next Steps


## References

"@

    Set-Content -Path $summaryFile -Value $placeholderContent -Encoding UTF8
    Write-Success "Created summary template: $summaryFile"

    Write-Host ""
    Write-Header "Next Steps"
    Write-ColorOutput -ForegroundColor White "1. Open Copilot Chat in Visual Studio (Ctrl+Shift+/)"
    Write-ColorOutput -ForegroundColor White "2. Paste the prompt (Ctrl+V)"
    Write-ColorOutput -ForegroundColor White "3. Review and edit the generated summary"
    Write-ColorOutput -ForegroundColor White "4. Copy the summary and paste it into: $summaryFile"
    Write-ColorOutput -ForegroundColor White "5. Commit the summary: git add $summaryFile && git commit -m `"docs: add work summary for $Topic`""
    Write-Host ""

} catch {
    Write-Error2 "Error: $($_.Exception.Message)"
    exit 1
}
