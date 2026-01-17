<#
.SYNOPSIS
    Monitor context size and provide recommendations.

.DESCRIPTION
    Estimates context usage based on open files and chat messages,
    warns when context is getting large, and recommends cleanup actions.

.EXAMPLE
    .\Context-Check.ps1
    Checks current context size and provides recommendations.

.NOTES
    Author: DevArch
    This script provides estimates since actual Copilot context is not directly queryable.
    Requires: PowerShell 5.1+
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

function Write-Warning2($Message) {
    Write-ColorOutput -ForegroundColor Red "⚠ $Message"
}

try {
    Write-Header "Context Size Check"

    # Estimate tokens (very rough approximation)
    # Real context depends on Copilot's internal state which we can't query directly

    Write-Info "This is an ESTIMATE based on observable factors"
    Write-Info "Actual Copilot context may vary"
    Write-Host ""

    # Check git branch
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        $gitBranch = "unknown"
    }

    Write-Info "Branch: $gitBranch"

    # Estimate session duration (proxy for chat messages)
    $sessionDir = "docs/context"
    $today = Get-Date -Format "yyyyMMdd"
    
    # Sanitize branch name for filename (replace slashes with dashes)
    $branchSafe = $gitBranch -replace '/', '-'
    
    $currentSession = Get-ChildItem -Path "$sessionDir/session-$today-*-$branchSafe.md" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    $estimatedMessages = 0
    $sessionDuration = 0

    if ($currentSession) {
        $sessionStart = $currentSession.CreationTime
        $sessionDuration = [math]::Round(((Get-Date) - $sessionStart).TotalMinutes, 0)
        # Rough estimate: 1 message exchange every 5 minutes
        $estimatedMessages = [math]::Max(1, [int]($sessionDuration / 5))
    }

    Write-Info "Session duration: ~$sessionDuration minutes"
    Write-Info "Estimated chat messages: ~$estimatedMessages"

    # Token estimation
    $estimatedTokens = 0

    # Chat messages: ~200 tokens per exchange (prompt + response)
    $chatTokens = $estimatedMessages * 200
    $estimatedTokens += $chatTokens

    # Workspace context: Check if large folders exist
    $workspaceTokens = 2000 # Base workspace metadata
    
    # Check for large dependency folders that might be loaded
    $largeFolders = @("node_modules", "packages", "bin", "obj", "dist", ".git")
    $largeFound = @()
    
    foreach ($folder in $largeFolders) {
        if (Test-Path $folder) {
            $largeFound += $folder
        }
    }

    if ($largeFound.Count -gt 0) {
        $workspaceTokens += 5000 # Penalty for large folders
    }

    $estimatedTokens += $workspaceTokens

    # File count estimate (we can't know which files are open in VS, so we'll estimate)
    Write-Host ""
    Write-ColorOutput -ForegroundColor White "Manual Check Required:"
    Write-ColorOutput -ForegroundColor White "How many files do you currently have open in Visual Studio?"
    $openFilesInput = Read-Host "Enter number (or press Enter to skip)"
    
    $openFiles = 0
    if ($openFilesInput -match '^\d+$') {
        $openFiles = [int]$openFilesInput
    }

    if ($openFiles -gt 0) {
        # Estimate: Average file is 100 lines = ~1000 tokens
        $fileTokens = $openFiles * 1000
        $estimatedTokens += $fileTokens
    }

    # Calculate status
    Write-Host ""
    Write-Header "Context Analysis"

    $targetLimit = 30000 # Conservative estimate for good performance
    $percentUsed = [math]::Round(($estimatedTokens / $targetLimit) * 100, 0)

    Write-ColorOutput -ForegroundColor White "Estimated Total Tokens: ~$estimatedTokens"
    Write-ColorOutput -ForegroundColor White "Target Limit: $targetLimit tokens"
    Write-ColorOutput -ForegroundColor White "Estimated Usage: $percentUsed%"
    Write-Host ""

    # Breakdown
    Write-Info "Breakdown:"
    Write-ColorOutput -ForegroundColor White "  • Chat messages: ~$chatTokens tokens ($estimatedMessages exchanges)"
    Write-ColorOutput -ForegroundColor White "  • Workspace context: ~$workspaceTokens tokens"
    if ($openFiles -gt 0) {
        Write-ColorOutput -ForegroundColor White "  • Open files: ~$($openFiles * 1000) tokens ($openFiles files)"
    }

    # Status and recommendations
    Write-Host ""
    if ($percentUsed -lt 50) {
        Write-Success "Context usage is LOW - You're good to continue!"
        Write-ColorOutput -ForegroundColor Green "No action needed at this time."
    }
    elseif ($percentUsed -lt 75) {
        Write-Warning2 "Context usage is MODERATE - Start being mindful"
        Write-Host ""
        Write-ColorOutput -ForegroundColor Yellow "Recommendations:"
        Write-ColorOutput -ForegroundColor White "  • Close files you're not actively editing"
        Write-ColorOutput -ForegroundColor White "  • Be selective with @workspace queries"
        Write-ColorOutput -ForegroundColor White "  • Consider clearing chat in next 15-30 minutes"
    }
    else {
        Write-Warning2 "Context usage is HIGH - Take action soon!"
        Write-Host ""
        Write-ColorOutput -ForegroundColor Red "RECOMMENDED ACTIONS:"
        Write-ColorOutput -ForegroundColor White "  1. Generate work summary: .\scripts\New-WorkSummary.ps1 -Topic `"current-work`""
        Write-ColorOutput -ForegroundColor White "  2. Commit your changes: git add -A && git commit -m `"wip: save progress`""
        Write-ColorOutput -ForegroundColor White "  3. Clear Copilot chat history (Settings → Clear chat)"
        Write-ColorOutput -ForegroundColor White "  4. Close all documents (Window → Close All Documents)"
        Write-ColorOutput -ForegroundColor White "  5. Resume with: .\scripts\Resume-Session.ps1"
    }

    # Additional warnings
    Write-Host ""
    if ($openFiles -gt 10) {
        Write-Warning2 "You have $openFiles files open - Consider closing some"
    }

    if ($sessionDuration -gt 120) {
        Write-Warning2 "Session has been running for $sessionDuration minutes (2+ hours)"
        Write-Info "Long sessions tend to accumulate context. Consider a fresh start."
    }

    if ($largeFound.Count -gt 0) {
        Write-Warning2 "Large folders detected: $($largeFound -join ', ')"
        Write-Info "These folders may bloat context. Ensure they're in .copilotignore"
    }

    Write-Host ""
    Write-Header "Context Management Tips"
    Write-ColorOutput -ForegroundColor Cyan "  • Check context every 30-60 minutes"
    Write-ColorOutput -ForegroundColor Cyan "  • Keep fewer than 10 files open"
    Write-ColorOutput -ForegroundColor Cyan "  • Clear chat after major milestones"
    Write-ColorOutput -ForegroundColor Cyan "  • Use targeted file requests instead of @workspace"
    Write-ColorOutput -ForegroundColor Cyan "  • Fresh context = better responses"
    Write-Host ""

} catch {
    Write-ColorOutput -ForegroundColor Red "Error: $($_.Exception.Message)"
    exit 1
}
