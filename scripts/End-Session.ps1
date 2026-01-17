<#
.SYNOPSIS
    End a work session with cleanup and summary.

.DESCRIPTION
    Prompts for work summary generation, reminds to clear Copilot context,
    updates session file status, and commits changes.

.PARAMETER NoCommit
    Skip automatic git commit.

.PARAMETER NoSummary
    Skip work summary generation prompt.

.EXAMPLE
    .\End-Session.ps1
    Ends session with all cleanup steps.

.EXAMPLE
    .\End-Session.ps1 -NoCommit
    Ends session without committing changes.

.NOTES
    Author: DevArch
    Requires: Git, PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$NoCommit,

    [Parameter(Mandatory=$false)]
    [switch]$NoSummary
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
    Write-Header "Ending Work Session"

    # Check if we're in a git repository
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error2 "Not in a git repository. Please run this script from the repository root."
        exit 1
    }

    Write-Info "Branch: $gitBranch"

    # Find current session file
    $sessionDir = "docs/context"
    $today = Get-Date -Format "yyyyMMdd"
    
    # Sanitize branch name for filename (replace slashes with dashes)
    $branchSafe = $gitBranch -replace '/', '-'
    
    $currentSession = Get-ChildItem -Path "$sessionDir/session-$today-*-$branchSafe.md" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $currentSession) {
        Write-Info "No session file found for today. Looking for recent sessions..."
        $currentSession = Get-ChildItem -Path "$sessionDir/session-*-$branchSafe.md" -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
    }

    if ($currentSession) {
        Write-Info "Current session: $($currentSession.Name)"
        
        # Update session status to "Completed"
        $sessionContent = Get-Content -Path $currentSession.FullName -Raw
        if ($sessionContent -match "Status:\s*In Progress") {
            $sessionContent = $sessionContent -replace "Status:\s*In Progress", "Status: Completed ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
            Set-Content -Path $currentSession.FullName -Value $sessionContent -Encoding UTF8
            Write-Success "Updated session status to 'Completed'"
        }
    } else {
        Write-Info "No session file found for this branch"
    }

    # Prompt for work summary
    if (-not $NoSummary) {
        Write-Host ""
        Write-Header "Work Summary"
        Write-ColorOutput -ForegroundColor White "Should you generate a work summary?"
        Write-Host ""
        Write-Info "Generate a work summary if you:"
        Write-ColorOutput -ForegroundColor White "  • Completed a significant feature or component"
        Write-ColorOutput -ForegroundColor White "  • Had a multi-hour work session"
        Write-ColorOutput -ForegroundColor White "  • Made important architectural decisions"
        Write-ColorOutput -ForegroundColor White "  • Solved complex problems"
        Write-Host ""
        
        $response = Read-Host "Generate work summary now? (y/N)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            $topic = Read-Host "Enter topic for work summary (e.g., 'auth-implementation')"
            if ($topic) {
                & "$PSScriptRoot\New-WorkSummary.ps1" -Topic $topic
            }
        }
    }

    # Check git status
    Write-Host ""
    Write-Header "Git Status"
    
    $gitStatus = git status --short
    if ($gitStatus) {
        Write-Info "Uncommitted changes:"
        Write-Host $gitStatus
        Write-Host ""

        if (-not $NoCommit) {
            $response = Read-Host "Commit all changes? (Y/n)"
            if ($response -ne 'n' -and $response -ne 'N') {
                $commitMsg = Read-Host "Enter commit message (or press Enter for default)"
                if (-not $commitMsg) {
                    $commitMsg = "chore: end session - save progress"
                }
                
                git add -A
                git commit -m $commitMsg
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Changes committed"
                    
                    $response = Read-Host "Push to remote? (Y/n)"
                    if ($response -ne 'n' -and $response -ne 'N') {
                        git push
                        if ($LASTEXITCODE -eq 0) {
                            Write-Success "Changes pushed to remote"
                        } else {
                            Write-Info "Push failed. You may need to push manually."
                        }
                    }
                } else {
                    Write-Info "Commit failed. Please commit manually."
                }
            }
        }
    } else {
        Write-Success "No uncommitted changes"
    }

    # Context cleanup reminder
    Write-Host ""
    Write-Header "Context Cleanup Checklist"
    Write-ColorOutput -ForegroundColor White "Before closing Visual Studio, remember to:"
    Write-Host ""
    Write-ColorOutput -ForegroundColor Yellow "  1. Clear Copilot Chat History"
    Write-ColorOutput -ForegroundColor White "     • Open Copilot Chat settings"
    Write-ColorOutput -ForegroundColor White "     • Click 'Clear chat history'"
    Write-Host ""
    Write-ColorOutput -ForegroundColor Yellow "  2. Close All Document Windows"
    Write-ColorOutput -ForegroundColor White "     • Window → Close All Documents (or Ctrl+Shift+W)"
    Write-ColorOutput -ForegroundColor White "     • This frees up context for next session"
    Write-Host ""
    Write-ColorOutput -ForegroundColor Yellow "  3. Save Solution/Project Files"
    Write-ColorOutput -ForegroundColor White "     • File → Save All (Ctrl+Shift+S)"
    Write-Host ""

    Write-Host ""
    Write-Header "Session Ended"
    Write-Success "Session cleanup complete!"
    Write-Host ""
    Write-Info "To resume work:"
    Write-ColorOutput -ForegroundColor White "  1. Open Visual Studio"
    Write-ColorOutput -ForegroundColor White "  2. Run: .\scripts\Resume-Session.ps1"
    Write-ColorOutput -ForegroundColor White "  3. Load minimal context and continue"
    Write-Host ""

} catch {
    Write-Error2 "Error: $($_.Exception.Message)"
    exit 1
}
