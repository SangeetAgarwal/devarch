<#
.SYNOPSIS
    Start a new work session with context loading.

.DESCRIPTION
    Creates a new session summary file from template, displays the previous session
    for context, and generates a Copilot prompt to load architectural context.

.PARAMETER Resume
    Resume the current session instead of creating a new one.

.EXAMPLE
    .\New-Session.ps1
    Creates a new session file and generates context-loading prompt.

.EXAMPLE
    .\New-Session.ps1 -Resume
    Resumes the current session without creating a new file.

.NOTES
    Author: DevArch
    Requires: Git, PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Resume
)

# Set error action preference
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
    Write-Header "Starting Work Session"

    # Check if we're in a git repository
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error2 "Not in a git repository. Please run this script from the repository root."
        exit 1
    }

    # Sanitize branch name for filename (replace slashes with dashes)
    $branchSafe = $gitBranch -replace '/', '-'

    Write-Info "Current branch: $gitBranch"

    # Setup paths
    $sessionDir = "docs/context"
    $today = Get-Date -Format "yyyyMMdd"
    $time = Get-Date -Format "HHmm"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $sessionFile = "$sessionDir/session-$today-$time-$branchSafe.md"
    $templateFile = "$sessionDir/.session-template.md"

    # Ensure session directory exists
    if (-not (Test-Path $sessionDir)) {
        New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null
        Write-Success "Created session directory: $sessionDir"
    }

    # Create template if it doesn't exist
    if (-not (Test-Path $templateFile)) {
        $templateContent = @"
# Session Summary: {{DATE}} - {{BRANCH}}

## Status: In Progress

## Goals
- (To be filled as work progresses)

## Completed
- (None yet)

## Key Decisions
- (None yet)

## Open Items
- (None yet)

## Files Modified
- (None yet)

## Notes
- Session started: {{TIMESTAMP}}
"@
        Set-Content -Path $templateFile -Value $templateContent -Encoding UTF8
        Write-Success "Created session template: $templateFile"
    }

    # Find previous session for this branch
    $previousSession = Get-ChildItem -Path "$sessionDir/session-*-$branchSafe.md" -ErrorAction SilentlyContinue | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1

    if ($Resume -and $previousSession) {
        Write-Info "Resuming previous session: $($previousSession.Name)"
        $sessionFile = $previousSession.FullName
    } else {
        # Create new session file from template
        $sessionContent = Get-Content -Path $templateFile -Raw
        $sessionContent = $sessionContent -replace "{{DATE}}", $today
        $sessionContent = $sessionContent -replace "{{BRANCH}}", $branchSafe
        $sessionContent = $sessionContent -replace "{{TIMESTAMP}}", $timestamp

        Set-Content -Path $sessionFile -Value $sessionContent -Encoding UTF8
        Write-Success "Created session file: $sessionFile"
    }

    # Display previous session if available
    if ($previousSession -and -not $Resume) {
        Write-Header "Previous Session Context"
        Write-Info "File: $($previousSession.Name)"
        Write-Host ""
        Get-Content -Path $previousSession.FullName | Write-Host
        Write-Host ""
    }

    # Find work folder for this branch
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
        }
    }

    # Generate Copilot prompt
    Write-Header "Copilot Context-Loading Prompt"

    $prompt = @"
I'm starting a new work session on branch **$gitBranch**.

Please help me get oriented by loading the following context:

1. **Session Summary**: Read ``$sessionFile``
"@

    if ($previousSession -and -not $Resume) {
        $prompt += @"

2. **Previous Session**: Review ``$($previousSession.FullName)``
"@
    }

    if ($hasWorkFolder) {
        $prompt += @"

3. **Feature Overview**: Read ``$workFolder/README.md`` (if exists)
4. **Implementation Plan**: Read ``$workFolder/implementation-plan.md`` (if exists)
"@
    }

    if ($latestWorkSummary) {
        $prompt += @"

5. **Latest Work Summary**: Review ``$($latestWorkSummary.FullName)``
"@
    }

    $prompt += @"


6. **Architecture Context**: Review ``.github/copilot-instructions.md`` for:
   - Project structure and conventions
   - Work patterns and session workflow
   - Critical rules and architecture principles

Based on this context, please:
- Summarize the current state of work
- List what's been completed recently
- Identify the next priority tasks
- Highlight any blockers or open questions

**Model Selection**: Use Claude Opus 4.5 for best results.
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

    Write-Host ""
    Write-Header "Next Steps"
    Write-ColorOutput -ForegroundColor White "1. Open Copilot Chat in Visual Studio (Ctrl+Shift+/)"
    Write-ColorOutput -ForegroundColor White "2. Paste the prompt (Ctrl+V)"
    Write-ColorOutput -ForegroundColor White "3. Review Copilot's summary and start working"
    Write-ColorOutput -ForegroundColor White "4. Update session file ``$sessionFile`` as you progress"
    Write-ColorOutput -ForegroundColor White "5. Run ``.\scripts\Context-Check.ps1`` periodically"
    Write-Host ""

} catch {
    Write-Error2 "Error: $($_.Exception.Message)"
    exit 1
}
