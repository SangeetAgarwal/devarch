<#
.SYNOPSIS
    Create a new feature branch with complete work structure.

.DESCRIPTION
    Creates a new feature branch, sets up the work directory structure,
    generates README.md and implementation-plan.md templates, and
    automatically starts a new session.

.PARAMETER FeatureName
    Name of the feature (will be used for branch and folder names).
    Should be kebab-case (e.g., "user-authentication").

.PARAMETER NoBranch
    Skip creating a new git branch (use current branch).

.EXAMPLE
    .\New-Feature.ps1 -FeatureName "user-auth"
    Creates feature-user-auth branch and work structure.

.EXAMPLE
    .\New-Feature.ps1 -FeatureName "api-refactor" -NoBranch
    Creates work structure for current branch.

.NOTES
    Author: DevArch
    Requires: Git, PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$FeatureName,

    [Parameter(Mandatory=$false)]
    [switch]$NoBranch
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
    Write-Header "Creating New Feature: $FeatureName"

    # Validate feature name
    if ($FeatureName -notmatch '^[a-z0-9-]+$') {
        Write-Error2 "Feature name must be lowercase with hyphens only (e.g., 'user-auth')"
        exit 1
    }

    # Check if we're in a git repository
    git rev-parse --git-dir 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error2 "Not in a git repository. Please run this script from the repository root."
        exit 1
    }

    # Determine branch name
    if (-not $NoBranch) {
        $branchName = "feature-$FeatureName"
        
        # Check if branch already exists
        $branchExists = git rev-parse --verify $branchName 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Error2 "Branch '$branchName' already exists. Use a different name or checkout the existing branch."
            exit 1
        }

        # Create new branch
        git checkout -b $branchName 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Error2 "Failed to create branch '$branchName'"
            exit 1
        }
        Write-Success "Created and switched to branch: $branchName"
    } else {
        $branchName = git rev-parse --abbrev-ref HEAD
        Write-Info "Using current branch: $branchName"
    }

    # Setup work directory
    $workFolder = "docs/work/$branchName"
    $contextFolder = "$workFolder/context"

    if (-not (Test-Path $workFolder)) {
        New-Item -ItemType Directory -Path $workFolder -Force | Out-Null
        Write-Success "Created work directory: $workFolder"
    }

    if (-not (Test-Path $contextFolder)) {
        New-Item -ItemType Directory -Path $contextFolder -Force | Out-Null
        Write-Success "Created context directory: $contextFolder"
    }

    # Create README.md
    $readmePath = "$workFolder/README.md"
    if (-not (Test-Path $readmePath)) {
        $readmeContent = @"
# Feature: $FeatureName

## Overview

[Describe what this feature does and why it's needed]

## Requirements

### Functional Requirements
- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

### Non-Functional Requirements
- [ ] Performance: [specify requirements]
- [ ] Security: [specify requirements]
- [ ] Accessibility: [specify requirements]

## Technical Approach

### Architecture
[Describe the high-level architecture and design patterns]

### Components
- **Component 1**: [Description]
- **Component 2**: [Description]

### Data Model
[Describe any data structures, database schemas, or API contracts]

### Dependencies
- [List external libraries, services, or other features this depends on]

## Testing Strategy

### Unit Tests
- [ ] Test scenario 1
- [ ] Test scenario 2

### Integration Tests
- [ ] Integration scenario 1
- [ ] Integration scenario 2

### Manual Testing
- [ ] Manual test case 1
- [ ] Manual test case 2

## Acceptance Criteria

- [ ] Criterion 1: [Specific, measurable outcome]
- [ ] Criterion 2: [Specific, measurable outcome]
- [ ] Criterion 3: [Specific, measurable outcome]

## Implementation Phases

See [implementation-plan.md](./implementation-plan.md) for detailed progress tracking.

### Phase 1: Setup
[Description of initial setup work]

### Phase 2: Core Implementation
[Description of main implementation work]

### Phase 3: Testing & Refinement
[Description of testing and polish work]

### Phase 4: Documentation & Deployment
[Description of final steps]

## References

- Related ADRs: [List ADR numbers and titles]
- Related Issues: [Link to issue tracker items]
- Design Docs: [Links to any external design documents]

## Notes

[Any additional notes, decisions, or context]
"@
        Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8
        Write-Success "Created README.md: $readmePath"
    } else {
        Write-Info "README.md already exists: $readmePath"
    }

    # Create implementation-plan.md
    $planPath = "$workFolder/implementation-plan.md"
    if (-not (Test-Path $planPath)) {
        $planContent = @"
# $FeatureName Implementation Plan

**Branch**: ``$branchName``  
**Started**: $(Get-Date -Format "yyyy-MM-dd")  
**Status**: In Progress

---

## Phase Breakdown

### Phase 1: Setup & Planning
| Task | Status | Assignee | Notes |
|------|--------|----------|-------|
| Create feature branch | ✅ Done | | Completed $(Get-Date -Format "yyyy-MM-dd") |
| Write README and plan | ✅ Done | | Completed $(Get-Date -Format "yyyy-MM-dd") |
| Review architecture | ⏳ Pending | | |
| Create ADRs if needed | ⏳ Pending | | |

### Phase 2: Core Implementation
| Task | Status | Assignee | Notes |
|------|--------|----------|-------|
| Implement component 1 | ⏳ Pending | | |
| Implement component 2 | ⏳ Pending | | |
| Implement component 3 | ⏳ Pending | | |

### Phase 3: Testing
| Task | Status | Assignee | Notes |
|------|--------|----------|-------|
| Write unit tests | ⏳ Pending | | |
| Write integration tests | ⏳ Pending | | |
| Manual testing | ⏳ Pending | | |
| Fix issues | ⏳ Pending | | |

### Phase 4: Documentation & Deployment
| Task | Status | Assignee | Notes |
|------|--------|----------|-------|
| Update documentation | ⏳ Pending | | |
| Code review | ⏳ Pending | | |
| Merge to main | ⏳ Pending | | |

---

## Progress Summary

| Phase | Tasks | Done | In Progress | Pending | Blocked |
|-------|-------|------|-------------|---------|---------|
| 1. Setup & Planning | 4 | 2 | 0 | 2 | 0 |
| 2. Core Implementation | 3 | 0 | 0 | 3 | 0 |
| 3. Testing | 4 | 0 | 0 | 4 | 0 |
| 4. Documentation | 3 | 0 | 0 | 3 | 0 |
| **TOTAL** | **14** | **2** | **0** | **12** | **0** |

**Overall Progress**: 14% (2/14 tasks)

---

## Recently Completed

- $(Get-Date -Format "yyyy-MM-dd"): Created feature branch and work structure

## Priority Next Steps

1. Review architecture and create necessary ADRs
2. Begin core implementation
3. Set up testing infrastructure

## Blockers

- None currently

## Notes

[Add notes about decisions, challenges, or important context here]

---

**Status Legend**:
- ✅ **Done**: Task completed
- 🚧 **In Progress**: Currently working on this
- ⏳ **Pending**: Not started yet
- ❌ **Blocked**: Cannot proceed due to dependency or issue
"@
        Set-Content -Path $planPath -Value $planContent -Encoding UTF8
        Write-Success "Created implementation-plan.md: $planPath"
    } else {
        Write-Info "implementation-plan.md already exists: $planPath"
    }

    # Commit the structure
    git add "$workFolder/*" 2>$null
    if ($LASTEXITCODE -eq 0) {
        git commit -m "feat: initialize $FeatureName feature structure" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Committed feature structure"
        }
    }

    Write-Host ""
    Write-Header "Feature Structure Created"
    Write-ColorOutput -ForegroundColor White "Branch: $branchName"
    Write-ColorOutput -ForegroundColor White "Work Folder: $workFolder"
    Write-ColorOutput -ForegroundColor White "README: $readmePath"
    Write-ColorOutput -ForegroundColor White "Plan: $planPath"
    Write-Host ""

    # Start a new session
    Write-Info "Starting new session..."
    Write-Host ""
    
    & "$PSScriptRoot\New-Session.ps1"

} catch {
    Write-Error2 "Error: $($_.Exception.Message)"
    exit 1
}
