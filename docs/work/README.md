# Work Folders

This directory contains work-specific documentation organized by git branch.

## Purpose

Work folders provide **permanent, detailed documentation** for features, projects, and significant work. They serve as:
- Feature specifications and planning
- Implementation tracking and progress
- Detailed work summaries and context
- Historical record after merge to main

## The Branch = Work Folder Pattern

**Your git branch name MUST match your work folder name.**

```
Git Branch                  Work Folder
──────────────────────     ─────────────────────────────
feature-auth            →  docs/work/feature-auth/
api-refactor            →  docs/work/api-refactor/
bugfix-login-timeout    →  docs/work/bugfix-login-timeout/
project-migration       →  docs/work/project-migration/
```

This pattern ensures:
- All related artifacts stay together
- Easy to find documentation for any branch
- Historical record persists after branch merge

## Folder Structure

Each work folder follows this structure:

```
docs/work/{branch-name}/
├── README.md                    # Feature overview and requirements
├── implementation-plan.md       # Progress tracking with phases
├── context/                     # Detailed work summaries
│   ├── 2026-01-15-0930-initial-planning.md
│   ├── 2026-01-16-1400-core-implementation.md
│   └── 2026-01-17-1000-testing-complete.md
├── design.md                    # (Optional) Detailed design docs
├── research.md                  # (Optional) Research findings
├── testing-plan.md              # (Optional) Testing strategy
└── evidence/                    # (Optional) Screenshots, logs, etc.
```

## Core Files

### README.md

The feature overview document. Contains:
- **Overview**: What this feature does and why
- **Requirements**: Functional and non-functional
- **Technical Approach**: Architecture and components
- **Testing Strategy**: How to test
- **Acceptance Criteria**: Definition of done
- **Implementation Phases**: High-level phases
- **References**: Links to ADRs, issues, etc.

**Create with:**
```powershell
.\scripts\New-Feature.ps1 -FeatureName "feature-name"
```

### implementation-plan.md

Progress tracking document with phase tables. Contains:
- **Phase Breakdown**: Tables with tasks and statuses
- **Progress Summary**: Statistics and percentages
- **Recently Completed**: What's been done
- **Priority Next Steps**: What's next
- **Blockers**: What's blocking progress

**Status markers:**
- ✅ Done - Task completed
- 🚧 In Progress - Currently working
- ⏳ Pending - Not started
- ❌ Blocked - Cannot proceed

**Update with:**
```powershell
.\scripts\Update-ImplementationPlan.ps1
```

### context/ subfolder

Detailed work summaries for significant milestones. Each summary includes:
- Objective and what was accomplished
- Key decisions and rationale
- Challenges and solutions
- Code quality notes
- Next steps and references

**Create with:**
```powershell
.\scripts\New-WorkSummary.ps1 -Topic "description"
```

## When to Create

Create a work folder when:
- Starting a new feature or significant work
- Beginning a project that spans multiple sessions
- Working on complex bug fixes that need documentation
- Doing refactoring that affects multiple components

**Use the script:**
```powershell
.\scripts\New-Feature.ps1 -FeatureName "user-authentication"
```

This creates:
- Git branch: `feature-user-authentication`
- Work folder: `docs/work/feature-user-authentication/`
- README.md and implementation-plan.md templates
- Initial session file

## When to Update

Update work folder contents:
- **README.md**: When requirements change or design evolves
- **implementation-plan.md**: After completing tasks or changing status
- **context/ summaries**: After significant work sessions or milestones

## Lifecycle

### 1. Create Feature
```powershell
.\scripts\New-Feature.ps1 -FeatureName "feature-name"
```
- Creates branch and work folder
- Generates template files
- Starts initial session

### 2. Plan and Design
- Fill in README.md with requirements and approach
- Refine implementation-plan.md with specific tasks
- Create ADRs for design decisions
- Add research.md or design.md if needed

### 3. Implement
- Update implementation-plan.md as tasks complete
- Generate work summaries for milestones
- Add evidence (screenshots, logs) as needed
- Keep session files updated in `docs/context/`

### 4. Complete and Merge
- Mark all tasks as ✅ Done in implementation plan
- Generate final work summary
- Update README.md with final notes
- Merge branch to main
- **Keep work folder** - it's permanent documentation!

### 5. Post-Merge
- Work folder stays as historical record
- Helps onboarding and future reference
- Can be referenced in new work
- Never delete after merge

## Best Practices

1. **One branch, one folder** - Never mix work from multiple branches
2. **Start with templates** - Use `New-Feature.ps1` to create structure
3. **Update progressively** - Don't wait until end to document
4. **Be specific** - "Implemented JWT auth" not "worked on auth"
5. **Link to ADRs** - Reference architecture decisions
6. **Include evidence** - Screenshots, logs, test results
7. **Keep it organized** - Use subfolders for large features
8. **Don't delete** - Keep work folders after merge for history

## What Goes Where

| Content | Location | Why |
|---------|----------|-----|
| Session notes | `docs/context/session-*.md` | Short-term, per-session |
| Work summaries | `docs/work/{branch}/context/` | Detailed, milestone-based |
| Feature overview | `docs/work/{branch}/README.md` | Requirements and approach |
| Progress tracking | `docs/work/{branch}/implementation-plan.md` | Task status and phases |
| Architecture decisions | `docs/architecture/adrs/` | Cross-cutting, permanent |
| Code | `src/`, `lib/`, etc. | Implementation |

## Example Work Folder

```
docs/work/feature-user-auth/
├── README.md                    # Feature: User Authentication
│                                # - JWT-based auth
│                                # - Login, logout, refresh endpoints
│                                # - Role-based access control
│
├── implementation-plan.md       # 4 phases, 18 tasks
│                                # Overall: 85% complete (15/18)
│                                # Phase 1: ✅ Done
│                                # Phase 2: ✅ Done
│                                # Phase 3: 🚧 In Progress
│                                # Phase 4: ⏳ Pending
│
├── context/
│   ├── 2026-01-15-0930-planning-and-design.md
│   ├── 2026-01-16-1400-jwt-implementation.md
│   ├── 2026-01-17-1000-middleware-and-tests.md
│   └── 2026-01-18-1530-rbac-implementation.md
│
├── design.md                    # Detailed auth flow diagrams
│                                # Token structure and validation
│
└── evidence/
    ├── auth-flow.png           # Flow diagram
    ├── test-results.png        # Test coverage screenshot
    └── postman-collection.json # API test collection
```

## Comparison to Session Summaries

| Aspect | Work Folder | Session Summary |
|--------|-------------|-----------------|
| **Scope** | Entire feature/project | Single work session |
| **Duration** | Days to weeks | Hours |
| **Detail** | Very detailed | Brief bullets |
| **Location** | `docs/work/{branch}/` | `docs/context/` |
| **Permanence** | Permanent (kept after merge) | Temporary (archived) |
| **Audience** | Future you, team, new devs | Immediate you |
| **Updates** | After milestones | During session |

## Tips

1. **Use scripts** - Don't create structure manually
2. **Link everything** - Cross-reference ADRs, sessions, issues
3. **Include evidence** - Screenshots and logs are valuable
4. **Update plans** - Keep implementation-plan.md current
5. **Write for others** - Someone else should understand your work
6. **Don't overthink** - Start simple, add detail as needed

## Troubleshooting

**Q: Should I create a work folder for small bug fixes?**  
A: Use judgment. If it's a one-line fix, probably not. If it requires investigation, design changes, or affects multiple components, yes.

**Q: What if my branch name changes?**  
A: Rename the work folder to match. Update references in implementation plan and summaries.

**Q: Can I have nested work folders?**  
A: Not recommended. Each branch gets one folder. Use subfolders within the work folder for organization.

**Q: What happens to the work folder after merge?**  
A: It stays! It's permanent documentation. Never delete.

**Q: How detailed should work summaries be?**  
A: Very detailed. Include code snippets, specific decisions, challenges faced, and solutions. Future you will thank you.

## See Also

- [Session Summaries](../context/README.md) - Short-term session notes
- [ADR Guide](../../docs/architecture-decision-records-guide.md) - Architecture decisions
- [Copilot Workflow Guide](../copilot-workflow-guide.md) - Complete workflow
- [Scripts README](../../scripts/README.md) - Automation scripts
