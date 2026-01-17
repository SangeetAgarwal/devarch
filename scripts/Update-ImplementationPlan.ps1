<#
.SYNOPSIS
    Helper to update implementation plan progress.

.DESCRIPTION
    Parses current implementation plan, updates phase statuses,
    and recalculates statistics.

.PARAMETER PlanFile
    Path to implementation plan file. If not specified, looks for plan in current branch's work folder.

.EXAMPLE
    .\Update-ImplementationPlan.ps1
    Updates implementation plan for current branch.

.EXAMPLE
    .\Update-ImplementationPlan.ps1 -PlanFile "docs/work/feature-auth/implementation-plan.md"
    Updates specific implementation plan.

.NOTES
    Author: DevArch
    Requires: PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$PlanFile
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

function Count-TasksByStatus($content, $phase) {
    $done = 0
    $inProgress = 0
    $pending = 0
    $blocked = 0
    $total = 0

    # Find the phase section and count tasks
    if ($content -match "(?s)### $phase.*?(?=###|\Z)") {
        $phaseSection = $matches[0]
        
        # Count by status markers
        $done = ([regex]::Matches($phaseSection, "✅|Done")).Count
        $inProgress = ([regex]::Matches($phaseSection, "🚧|In Progress")).Count
        $pending = ([regex]::Matches($phaseSection, "⏳|Pending")).Count
        $blocked = ([regex]::Matches($phaseSection, "❌|Blocked")).Count
        
        # Total is sum of all statuses
        $total = $done + $inProgress + $pending + $blocked
    }

    return @{
        Done = $done
        InProgress = $inProgress
        Pending = $pending
        Blocked = $blocked
        Total = $total
    }
}

try {
    Write-Header "Update Implementation Plan"

    # Determine plan file
    if (-not $PlanFile) {
        $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error2 "Not in a git repository and no plan file specified."
            exit 1
        }
        
        # Sanitize branch name for path (replace slashes with dashes)
        $branchSafe = $gitBranch -replace '/', '-'
        
        $PlanFile = "docs/work/$branchSafe/implementation-plan.md"
    }

    if (-not (Test-Path $PlanFile)) {
        Write-Error2 "Implementation plan not found: $PlanFile"
        Write-Info "Create a plan file first or specify correct path."
        exit 1
    }

    Write-Info "Plan file: $PlanFile"

    # Read current plan
    $content = Get-Content -Path $PlanFile -Raw

    # Extract phase names
    $phases = @()
    $phaseMatches = [regex]::Matches($content, '### (Phase \d+:.*?)(?=\n)')
    foreach ($match in $phaseMatches) {
        $phases += $match.Groups[1].Value.Trim()
    }

    if ($phases.Count -eq 0) {
        Write-Error2 "No phases found in implementation plan"
        exit 1
    }

    Write-Info "Found $($phases.Count) phases"

    # Calculate statistics for each phase
    $allStats = @()
    $totalDone = 0
    $totalInProgress = 0
    $totalPending = 0
    $totalBlocked = 0
    $totalTasks = 0

    foreach ($phase in $phases) {
        $stats = Count-TasksByStatus $content $phase
        $allStats += [PSCustomObject]@{
            Phase = $phase
            Done = $stats.Done
            InProgress = $stats.InProgress
            Pending = $stats.Pending
            Blocked = $stats.Blocked
            Total = $stats.Total
        }
        
        $totalDone += $stats.Done
        $totalInProgress += $stats.InProgress
        $totalPending += $stats.Pending
        $totalBlocked += $stats.Blocked
        $totalTasks += $stats.Total
    }

    # Display current statistics
    Write-Host ""
    Write-Header "Current Progress"
    
    Write-Host ""
    foreach ($stat in $allStats) {
        $phaseName = $stat.Phase
        Write-ColorOutput -ForegroundColor Cyan $phaseName
        Write-ColorOutput -ForegroundColor White "  Total: $($stat.Total) | ✅ $($stat.Done) | 🚧 $($stat.InProgress) | ⏳ $($stat.Pending) | ❌ $($stat.Blocked)"
    }

    Write-Host ""
    Write-ColorOutput -ForegroundColor Green "Overall Progress:"
    if ($totalTasks -gt 0) {
        $percentComplete = [math]::Round(($totalDone / $totalTasks) * 100, 0)
        Write-ColorOutput -ForegroundColor White "  $totalDone of $totalTasks tasks complete ($percentComplete%)"
    } else {
        Write-ColorOutput -ForegroundColor White "  No tasks found"
    }

    # Generate updated summary table
    $summaryTable = @"
| Phase | Tasks | Done | In Progress | Pending | Blocked |
|-------|-------|------|-------------|---------|---------|
"@

    foreach ($stat in $allStats) {
        $phaseNum = if ($stat.Phase -match 'Phase (\d+)') { $matches[1] } else { "?" }
        $phaseName = $stat.Phase -replace 'Phase \d+:\s*', ''
        $summaryTable += @"

| $phaseNum. $phaseName | $($stat.Total) | $($stat.Done) | $($stat.InProgress) | $($stat.Pending) | $($stat.Blocked) |
"@
    }

    $summaryTable += @"

| **TOTAL** | **$totalTasks** | **$totalDone** | **$totalInProgress** | **$totalPending** | **$totalBlocked** |
"@

    if ($totalTasks -gt 0) {
        $percentComplete = [math]::Round(($totalDone / $totalTasks) * 100, 0)
        $summaryTable += @"


**Overall Progress**: $percentComplete% ($totalDone/$totalTasks tasks)
"@
    }

    # Update the plan file
    if ($content -match '(?s)## Progress Summary.*?(?=##|\Z)') {
        $oldSummary = $matches[0]
        $newSummary = @"
## Progress Summary

$summaryTable
"@
        $content = $content -replace [regex]::Escape($oldSummary), $newSummary
        
        Set-Content -Path $PlanFile -Value $content -Encoding UTF8
        Write-Success "Updated progress summary in $PlanFile"
    } else {
        Write-Info "Could not find Progress Summary section to update"
        Write-Info "You may need to manually add the statistics"
    }

    # Provide next steps
    Write-Host ""
    Write-Header "Next Steps"
    Write-ColorOutput -ForegroundColor White "1. Review the updated statistics"
    Write-ColorOutput -ForegroundColor White "2. Update task statuses in the phase tables as needed"
    Write-ColorOutput -ForegroundColor White "3. Run this script again to recalculate"
    Write-ColorOutput -ForegroundColor White "4. Commit changes: git add $PlanFile && git commit -m `"docs: update implementation plan`""
    Write-Host ""

    # Show warnings
    if ($totalBlocked -gt 0) {
        Write-Error2 "$totalBlocked tasks are blocked - review and address blockers"
    }

    if ($totalInProgress -gt 3) {
        Write-Info "$totalInProgress tasks in progress - consider focusing on fewer tasks"
    }

} catch {
    Write-Error2 "Error: $($_.Exception.Message)"
    exit 1
}
