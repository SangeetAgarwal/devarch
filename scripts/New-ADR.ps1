<#
.SYNOPSIS
    Create a new Architecture Decision Record (ADR).

.DESCRIPTION
    Auto-numbers ADRs, generates comprehensive ADR template, and creates
    a Copilot prompt to help complete the ADR.

.PARAMETER Title
    Title of the decision (will be kebab-cased for filename).

.PARAMETER Status
    Initial status (Proposed, Accepted, Deprecated, Superseded).
    Default: Proposed

.EXAMPLE
    .\New-ADR.ps1 -Title "Use PostgreSQL for database"
    Creates ADR with auto-numbered ID.

.EXAMPLE
    .\New-ADR.ps1 -Title "JWT authentication" -Status "Accepted"
    Creates ADR with Accepted status.

.NOTES
    Author: DevArch
    Requires: PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$false)]
    [ValidateSet("Proposed", "Accepted", "Deprecated", "Superseded")]
    [string]$Status = "Proposed"
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
    Write-Header "Creating New ADR: $Title"

    # Setup paths
    $adrDir = "docs/architecture/adrs"
    
    # Ensure ADR directory exists
    if (-not (Test-Path $adrDir)) {
        New-Item -ItemType Directory -Path $adrDir -Force | Out-Null
        Write-Success "Created ADR directory: $adrDir"
    }

    # Find next ADR number
    $existingADRs = Get-ChildItem -Path "$adrDir/adr-*.md" -ErrorAction SilentlyContinue
    $maxNumber = 0
    
    foreach ($adr in $existingADRs) {
        if ($adr.Name -match 'adr-(\d+)') {
            $number = [int]$matches[1]
            if ($number -gt $maxNumber) {
                $maxNumber = $number
            }
        }
    }
    
    $adrNumber = $maxNumber + 1
    $adrId = "ADR-{0:D3}" -f $adrNumber
    Write-Info "Next ADR number: $adrId"

    # Create kebab-case filename
    $titleKebab = $Title.ToLower() -replace '\s+', '-' -replace '[^a-z0-9-]', ''
    $adrFileName = "adr-{0:D3}-{1}.md" -f $adrNumber, $titleKebab
    $adrPath = "$adrDir/$adrFileName"

    if (Test-Path $adrPath) {
        Write-Error2 "ADR file already exists: $adrPath"
        exit 1
    }

    # Get current date
    $today = Get-Date -Format "yyyy-MM-dd"

    # Create ADR content
    $adrContent = @"
# $adrId`: $Title

## Status

$Status

## Date

$today

## Context

What is the issue that we're seeing that is motivating this decision or change?

Describe:
- The problem or requirement
- Relevant constraints (technical, business, timeline)
- Forces at play (performance, maintainability, cost, team expertise)
- Current situation and why it needs to change

## Decision

What is the change that we're proposing and/or doing?

State the decision clearly and directly:
- "We will use X"
- "We will not do Y"
- "All Z must follow pattern W"

Be specific about:
- What technology/pattern/approach we're adopting
- How it will be implemented
- What existing code/patterns will change

## Consequences

What becomes easier or more difficult to do because of this change?

### Positive

- [Benefit 1: Describe specific advantage]
- [Benefit 2: Describe specific advantage]
- [Benefit 3: Describe specific advantage]

### Negative

- [Drawback 1: Describe specific disadvantage or cost]
- [Drawback 2: Describe specific disadvantage or cost]

### Neutral

- [Side effect 1: Neither good nor bad, but worth noting]
- [Side effect 2: Neither good nor bad, but worth noting]

## Alternatives Considered

### Alternative 1: [Name]

- **Pros**: [What makes this appealing]
- **Cons**: [What makes this less suitable]
- **Rejected because**: [Specific reason why we chose not to go this route]

### Alternative 2: [Name]

- **Pros**: [What makes this appealing]
- **Cons**: [What makes this less suitable]
- **Rejected because**: [Specific reason why we chose not to go this route]

## Implementation Notes

[Optional section for implementation details]

- Migration plan (if applicable)
- Rollout strategy
- Backward compatibility considerations
- Timeline and phases

## References

- Related ADRs: [List other ADR numbers]
- External documentation: [Links to relevant docs]
- Discussions: [Links to design discussions, RFCs, or meeting notes]
- Code examples: [Links to example implementations]

## Follow-up Actions

- [ ] Action item 1
- [ ] Action item 2
- [ ] Action item 3

## Notes

[Any additional context, caveats, or observations]
"@

    Set-Content -Path $adrPath -Value $adrContent -Encoding UTF8
    Write-Success "Created ADR: $adrPath"

    # Update ADR index if it exists
    $indexPath = "$adrDir/README.md"
    if (Test-Path $indexPath) {
        Write-Info "Remember to update $indexPath with the new ADR"
    }

    # Generate Copilot prompt
    Write-Host ""
    Write-Header "Copilot ADR Completion Prompt"

    $prompt = @"
I've created a new Architecture Decision Record (ADR) that needs to be completed.

**ADR**: $adrId - $Title  
**File**: ``$adrPath``  
**Status**: $Status

Please help me complete this ADR by:

1. Reading the template at ``$adrPath``
2. Asking me questions to understand:
   - The context and problem we're solving
   - The decision we're making and why
   - Alternatives we considered
   - Expected consequences (positive and negative)

3. After gathering information, help me fill in each section:
   - **Context**: Why is this decision needed?
   - **Decision**: What are we deciding to do?
   - **Consequences**: What are the impacts?
   - **Alternatives Considered**: What else did we evaluate?
   - **Implementation Notes**: How will this be rolled out?
   - **References**: Related docs, ADRs, discussions

4. Ensure the ADR is:
   - Specific and actionable
   - Documents the "why" not just the "what"
   - Captures enough context for future readers
   - Lists concrete pros/cons for alternatives

**Model Selection**: Use Claude Opus 4.5 for best quality.

Let's start by discussing the context. What problem or requirement is motivating this decision?
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
    Write-ColorOutput -ForegroundColor White "3. Work with Copilot to complete the ADR"
    Write-ColorOutput -ForegroundColor White "4. Edit the file: $adrPath"
    Write-ColorOutput -ForegroundColor White "5. Update the ADR index: $indexPath"
    Write-ColorOutput -ForegroundColor White "6. Commit: git add $adrPath && git commit -m `"docs: add $adrId $Title`""
    Write-Host ""

    Write-Header "ADR Best Practices"
    Write-ColorOutput -ForegroundColor Yellow "  • Write ADRs BEFORE implementing the decision"
    Write-ColorOutput -ForegroundColor Yellow "  • Focus on the 'why' not just the 'what'"
    Write-ColorOutput -ForegroundColor Yellow "  • Document alternatives even if quickly rejected"
    Write-ColorOutput -ForegroundColor Yellow "  • Be honest about negative consequences"
    Write-ColorOutput -ForegroundColor Yellow "  • Keep ADRs concise but complete"
    Write-ColorOutput -ForegroundColor Yellow "  • Update status as decisions evolve"
    Write-Host ""

} catch {
    Write-Error2 "Error: $($_.Exception.Message)"
    exit 1
}
