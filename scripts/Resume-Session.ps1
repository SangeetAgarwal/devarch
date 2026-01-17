<#
.SYNOPSIS
    Resume work with fresh context.

.DESCRIPTION
    Finds latest session and work summaries, generates a minimal context-loading
    prompt, and emphasizes clean context start.

.EXAMPLE
    .\Resume-Session.ps1
    Resumes work with minimal context loading.

.NOTES
    Author: DevArch
    Requires: Git, PowerShell 5.1+
#>

[CmdletBinding()]
param()

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
    Write-Header "Resuming Work Session"

    # Check if we're in a git repository
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error2 "Not in a git repository. Please run this script from the repository root."
        exit 1
    }

    Write-Info "Branch: $gitBranch"

    # Sanitize branch name for filename (replace slashes with dashes)
    $branchSafe = $gitBranch -replace '/', '-'

    # Context cleanup reminder
    Write-Host ""
    Write-Header "Pre-Resume Context Cleanup"
    Write-ColorOutput -ForegroundColor White "Have you completed these steps?"
    Write-Host ""
    Write-ColorOutput -ForegroundColor Yellow "  ☐ Cleared Copilot chat history (Settings → Clear chat)"
    Write-ColorOutput -ForegroundColor Yellow "  ☐ Closed all document windows (Window → Close All Documents)"
    Write-ColorOutput -ForegroundColor Yellow "  ☐ Ready to load fresh context"
    Write-Host ""
    
    $response = Read-Host "Continue with fresh context? (Y/n)"
    if ($response -eq 'n' -or $response -eq 'N') {
        Write-Info "Please clear context first, then run this script again."
        exit 0
    }

    # Find latest session file
    $sessionDir = "docs/context"
    $latestSession = Get-ChildItem -Path "$sessionDir/session-*-$branchSafe.md" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($latestSession) {
        Write-Success "Found latest session: $($latestSession.Name)"
    } else {
        Write-Info "No previous session found for this branch"
    }

    # Find work folder
    $workFolder = "docs/work/$gitBranch"
    $hasWorkFolder = Test-Path $workFolder

    # Find latest work summary
    $latestWorkSummary = $null
    if ($hasWorkFolder) {
        $contextFolder = "$workFolder/context"
        if (Test-Path $contextFolder) {
            $latestWorkSummary = Get-ChildItem -Path "$contextFolder/*.md" -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 1
            
            if ($latestWorkSummary) {
                Write-Success "Found latest work summary: $($latestWorkSummary.Name)"
            }
        }
    }

    # Find relevant ADRs (most recent 3)
    $recentADRs = Get-ChildItem -Path "docs/architecture/adrs/adr-*.md" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 3

    # Generate minimal context-loading prompt
    Write-Host ""
    Write-Header "Minimal Context-Loading Prompt"

    $prompt = @"
I'm resuming work on branch **$gitBranch** with a **fresh, clean context**.

Please help me get oriented by loading ONLY the essential context:
"@

    $filesList = @()

    if ($latestSession) {
        $prompt += @"


1. **Latest Session Summary**: ``$($latestSession.FullName)``
   - Read to understand recent progress and open items
"@
        $filesList += $latestSession.FullName
    }

    if ($hasWorkFolder) {
        $prompt += @"


2. **Feature Overview**: ``$workFolder/README.md``
   - Quick reminder of feature goals and requirements
"@
        $filesList += "$workFolder/README.md"

        $prompt += @"


3. **Implementation Plan**: ``$workFolder/implementation-plan.md``
   - Check current progress and next priority tasks
"@
        $filesList += "$workFolder/implementation-plan.md"
    }

    if ($latestWorkSummary) {
        $prompt += @"


4. **Latest Work Summary**: ``$($latestWorkSummary.FullName)``
   - Detailed context from last significant work session
"@
        $filesList += $latestWorkSummary.FullName
    }

    if ($recentADRs) {
        $prompt += @"


5. **Recent Architecture Decisions**:
"@
        foreach ($adr in $recentADRs) {
            $prompt += @"

   - ``$($adr.FullName)``
"@
            $filesList += $adr.FullName
        }
    }

    $prompt += @"


---

## Instructions

Based on ONLY the files listed above, please provide a **concise summary** (max 200 words):

1. **Current Status**: Where are we in this feature?
2. **Recently Completed**: What was done in the last session?
3. **Next Priorities**: What should I work on next? (top 3 items)
4. **Known Blockers**: Any issues or dependencies?

**Important**:
- Keep the summary brief and actionable
- Don't load any other files unless I explicitly ask
- This is a fresh context - we're starting lean

**Model Selection**: Use Claude Opus 4.5 for best results.

---

**Files to Review**:
"@

    foreach ($file in $filesList) {
        $prompt += @"

- ``$file``
"@
    }

    Write-Host $prompt
    Write-Host ""

    # Copy to clipboard if available
    if (Get-Command Set-Clipboard -ErrorAction SilentlyContinue) {
        $prompt | Set-Clipboard
        Write-Success "Prompt copied to clipboard! Paste into Copilot Chat."
    } else {
        Write-Info "Clipboard not available. Copy the prompt above manually."
    }

    Write-Host ""
    Write-Header "Next Steps"
    Write-ColorOutput -ForegroundColor White "1. Open Copilot Chat in Visual Studio (Ctrl+Shift+/)"
    Write-ColorOutput -ForegroundColor White "2. Paste the prompt (Ctrl+V)"
    Write-ColorOutput -ForegroundColor White "3. Review the summary - should be brief!"
    Write-ColorOutput -ForegroundColor White "4. Start working with minimal context loaded"
    Write-ColorOutput -ForegroundColor White "5. Load additional files ONLY as needed for specific tasks"
    Write-Host ""
    Write-Header "Context Management Tips"
    Write-ColorOutput -ForegroundColor Yellow "  • Keep fewer than 10 files open"
    Write-ColorOutput -ForegroundColor Yellow "  • Close files immediately after use"
    Write-ColorOutput -ForegroundColor Yellow "  • Run Context-Check.ps1 every 30-60 minutes"
    Write-ColorOutput -ForegroundColor Yellow "  • Be selective with @workspace (loads everything)"
    Write-Host ""

} catch {
    Write-Error2 "Error: $($_.Exception.Message)"
    exit 1
}
