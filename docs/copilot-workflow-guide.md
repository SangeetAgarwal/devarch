# GitHub Copilot + Visual Studio 2026 Workflow Guide

A comprehensive guide to productive collaboration with GitHub Copilot in Visual Studio 2026, providing 100% functional equivalence to the Claude Code CLI workflow. This guide is tool/framework agnostic and can be adapted to any software project.

## Philosophy

This workflow optimizes for:
- **Context continuity** across sessions (Copilot has context limitations)
- **Traceability** of decisions and work completed
- **Efficient handoffs** between sessions
- **Manual control** of context management (no automatic hooks)
- **Documentation as memory** - what you write survives; context doesn't

## Key Differences from Claude Code CLI

| Aspect | Claude Code CLI | GitHub Copilot + VS 2026 |
|--------|-----------------|--------------------------|
| **Context Management** | Automatic with `/context` command | Manual estimation via `Context-Check.ps1` |
| **Session Start** | Automatic hook creates session file | Run `New-Session.ps1` manually |
| **Work Summary** | `write work summary` command | Run `New-WorkSummary.ps1` manually |
| **Context Check** | `/context` shows exact remaining | Script estimates based on observable factors |
| **Model Selection** | Auto-selected by Claude | Manually select Claude Opus 4.5 in VS |
| **Integration** | Native CLI with hooks | Visual Studio extension + PowerShell scripts |
| **Automation** | Built-in SessionStart/Stop hooks | PowerShell scripts replace hooks |
| **Workflow** | Fully automated | Semi-automated (manual triggers) |

### What This Means

**Claude Code CLI** has automatic hooks that trigger at session start, before compact, and on stop. **GitHub Copilot** requires you to manually run equivalent PowerShell scripts at appropriate times.

**But the result is identical**: Same documentation structure, same context management patterns, same workflow benefits.

---

## Context Management (CRITICAL)

Unlike Claude Code CLI's `/context` command, GitHub Copilot doesn't expose its internal context usage directly. You must **actively manage context** to maintain productivity.

### The Golden Rules

1. **Manual context management is YOUR responsibility**
2. **Clear context regularly** - Don't let it accumulate
3. **Keep file count low** - Fewer than 10 open files at a time
4. **Check context proactively** - Every 30-60 minutes with `Context-Check.ps1`
5. **Document before clearing** - Always save work summaries first

### Context Limitations in Copilot

GitHub Copilot loads context from:
- Currently open files in Visual Studio
- Chat conversation history
- Workspace metadata (when using `@workspace`)
- Project structure and file index

**Problem**: There's no direct way to see "10% context remaining" like in Claude Code CLI.

**Solution**: Use observable proxies (session duration, file count, chat length) to estimate context usage.

### The Safe Context Reset Workflow

When context feels heavy (slow responses, forgetting earlier context, generic suggestions):

1. **STOP** all current work immediately
2. **CHECK** - Run `.\scripts\Context-Check.ps1` to estimate usage
3. **SAVE** - Run `.\scripts\New-WorkSummary.ps1 -Topic "progress-update"`
4. **COMMIT** - Save all changes: `git add . && git commit -m "WIP: save before context reset"`
5. **PUSH** - `git push` to remote
6. **CLEAR COPILOT**:
   - Copilot Chat → Settings → Clear chat history
   - Window → Close All Documents (Ctrl+Shift+W)
7. **CLOSE** Visual Studio completely (optional but recommended)
8. **RESTART** Visual Studio with fresh session
9. **RESUME** - Run `.\scripts\Resume-Session.ps1`
10. **LOAD** minimal context - Paste the generated prompt
11. **CONTINUE** with full context available

### Warning Signs of Context Overload

- Copilot responses become generic or incorrect
- Copilot forgets earlier discussion points
- Suggestions become irrelevant to current work
- Response time increases noticeably
- Copilot ignores project-specific patterns

**When in doubt, clear context and resume fresh.**

### Estimating Context Usage

Approximate token usage (rough estimates):
- 1 line of code ≈ 10 tokens
- 1 file (100 lines) ≈ 1,000 tokens
- 1 chat message exchange ≈ 200-500 tokens
- Workspace context (with `@workspace`) ≈ 2,000-10,000 tokens
- Open file in editor ≈ 500-2,000 tokens depending on size

**Target**: Keep total context under 30,000 tokens for best results.

**Use `Context-Check.ps1`** to get periodic estimates and recommendations.

---

## Getting Started: Applying to Your Project

This workflow can be applied to any project. Here's how to set it up:

### For a New Project

```powershell
# 1. Create your project
mkdir my-project && cd my-project
git init

# 2. Copy workflow files from devarch
git remote add devarch https://github.com/SangeetAgarwal/devarch.git
git fetch devarch
git checkout devarch/copilot/adapt-cli-workflow-for-copilot -- scripts/ .github/copilot-instructions.md .copilotignore docs/context/.session-template.md
git remote remove devarch

# 3. Customize .github/copilot-instructions.md for your project
# Update: Overview, Current Work, Project Structure sections

# 4. Create documentation structure
mkdir -p docs/context docs/architecture/adrs docs/work

# 5. Start your first feature
.\scripts\New-Feature.ps1 -FeatureName "initial-setup"
```

### For an Existing Project

```powershell
cd your-existing-repo

# 1. Copy workflow files (same command as above)
# 2. Customize copilot-instructions.md for your codebase
# 3. Create docs/ structure if needed
# 4. Start using: .\scripts\New-Session.ps1
```

**Key customizations needed:**
- `.github/copilot-instructions.md` - Update with your project's architecture, conventions, and structure
- `.copilotignore` - Add your project-specific build outputs and large files

The scripts are portable and work in any repository - they just manage documentation in `docs/` and generate Copilot prompts.

---

## Folder Structure

Organize your project with these directories:

```
project/
├── .github/
│   └── copilot-instructions.md  # Project instructions for Copilot
├── docs/
│   ├── context/                 # Session summaries (progressive)
│   │   ├── .session-template.md
│   │   ├── session-YYYYMMDD-HHMM-{branch}.md
│   │   └── archived/            # Old sessions
│   ├── architecture/
│   │   └── adrs/                # Architecture Decision Records
│   ├── work/
│   │   └── {branch}/            # Work area matching git branch name
│   │       ├── README.md
│   │       ├── implementation-plan.md
│   │       └── context/         # Detailed work summaries
│   └── reference/               # Stable reference docs
├── scripts/                     # PowerShell workflow automation
│   ├── New-Session.ps1
│   ├── End-Session.ps1
│   ├── Resume-Session.ps1
│   ├── New-WorkSummary.ps1
│   ├── Context-Check.ps1
│   └── ...
└── ...
```

### Purpose of Each Area

| Directory | Purpose | Updated |
|-----------|---------|---------|
| `.github/copilot-instructions.md` | Project instructions Copilot reads automatically | As patterns emerge |
| `docs/context/` | Session-level progress summaries | Every session |
| `docs/work/{branch}/` | **All artifacts for a branch**: plans, specs, research, evidence | Throughout feature work |
| `docs/work/{branch}/context/` | Detailed work summaries | After significant work |
| `docs/architecture/adrs/` | Architecture decisions | When making design choices |
| `scripts/` | PowerShell automation scripts | As workflow evolves |

### The Branch = Work Folder Pattern

**Your git branch name should match your work folder.** If you're on branch `feature-auth`, your work lives in `docs/work/feature-auth/`.

This folder contains everything related to that work:
- `README.md` - Overview of the feature/project
- `implementation-plan.md` - Tracking progress
- Research notes, specs, design docs
- `context/` subfolder for work summaries

When the branch merges to main, the work folder stays as historical documentation.

---

## Visual Studio 2026 Integration

### Essential Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+/` | Open Copilot Chat |
| `Ctrl+I` | Inline Copilot suggestions |
| `Alt+/` | Next Copilot suggestion |
| `Esc` | Dismiss Copilot suggestion |
| `Ctrl+K Ctrl+X` | Open snippet picker |
| `Ctrl+Shift+W` | Close all documents |
| `Ctrl+Shift+S` | Save all |
| `Ctrl+`` | Open terminal |
| `Ctrl+E, T` | Test Explorer |

### Model Selection

**Always use Claude Opus 4.5 when available** for best results with architectural reasoning and context management.

To select model in Visual Studio:
1. Open Copilot Chat (Ctrl+Shift+/)
2. Click model selector dropdown
3. Choose "Claude Opus 4.5" (or latest Opus version)

### Recommended Extensions

- **GitHub Copilot** (required) - AI pair programmer
- **GitHub Copilot Chat** (required) - Conversational AI assistant
- **PowerShell** - For running workflow scripts
- **GitLens** - Enhanced git integration and history

### Workspace Organization

Keep your Visual Studio workspace clean:

1. **Pin frequently accessed files** to keep them visible
2. **Use Solution Folders** matching your docs structure
3. **Close unused files immediately** - Every open file adds to context
4. **Limit open files** to fewer than 10 at a time
5. **Use File Explorer** instead of opening files just to peek

### PowerShell Terminal in Visual Studio

Set up integrated PowerShell terminal:

1. View → Terminal (Ctrl+`)
2. Select PowerShell from shell dropdown
3. Terminal opens at solution root
4. Run scripts: `.\scripts\New-Session.ps1`

---

## PowerShell Scripts: Your Automation Tools

These scripts provide 100% functional equivalence to Claude Code CLI hooks.

### Overview

| Script | Purpose | Equivalent to |
|--------|---------|---------------|
| `New-Session.ps1` | Start work session, load context | SessionStart hook |
| `End-Session.ps1` | Finalize session, commit changes | Stop hook |
| `Resume-Session.ps1` | Resume with minimal fresh context | Manual restart workflow |
| `New-WorkSummary.ps1` | Document completed work | `write work summary` command |
| `Context-Check.ps1` | Estimate context usage | `/context` command |
| `New-ADR.ps1` | Create Architecture Decision Record | Manual ADR creation |
| `New-Feature.ps1` | Create feature branch + structure | Manual setup |
| `Update-ImplementationPlan.ps1` | Update progress tracking | Manual updates |

### Script Execution Requirements

**First-time setup** (if needed):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Always run from repository root**:
```powershell
cd C:\path\to\your\project
.\scripts\New-Session.ps1
```

### Quick Reference

```powershell
# Start new session
.\scripts\New-Session.ps1

# Check context size
.\scripts\Context-Check.ps1

# Generate work summary
.\scripts\New-WorkSummary.ps1 -Topic "description"

# End session
.\scripts\End-Session.ps1

# Resume work (after clearing context)
.\scripts\Resume-Session.ps1

# Create new feature
.\scripts\New-Feature.ps1 -FeatureName "feature-name"

# Create ADR
.\scripts\New-ADR.ps1 -Title "decision-title"
```

---

## Session Workflow

### Starting a New Session

**Step 1: Run the script**
```powershell
.\scripts\New-Session.ps1
```

**What happens:**
1. Creates new session file: `docs/context/session-YYYYMMDD-HHMM-{branch}.md`
2. Displays previous session for context continuity
3. Generates Copilot prompt with architectural context
4. Copies prompt to clipboard automatically

**Step 2: Load context in Copilot**
1. Open Copilot Chat (Ctrl+Shift+/)
2. Select Claude Opus 4.5 model
3. Paste prompt (Ctrl+V)
4. Review Copilot's summary

**Step 3: Start working**
- Update session file as you make progress
- Keep it current with completed items, decisions, open tasks

### During a Work Session

**Progressive documentation** - Update as you go:

```markdown
## Completed
- ✅ Implemented user authentication middleware
- ✅ Added JWT token validation
- ✅ Created unit tests for auth flow

## Key Decisions
- Using bcrypt for password hashing (industry standard)
- JWT tokens expire after 24 hours
- Refresh tokens stored in httpOnly cookies

## Open Items
- Need to implement password reset flow
- TODO: Add rate limiting to login endpoint
- Review: Security audit of auth implementation

## Files Modified
- `src/middleware/auth.ts` - Authentication middleware
- `src/utils/jwt.ts` - JWT utilities
- `tests/auth.test.ts` - Auth tests
```

**Context monitoring** - Check regularly:
```powershell
# Every 30-60 minutes during active work
.\scripts\Context-Check.ps1
```

**File management**:
- Close files immediately after editing
- Keep fewer than 10 files open
- Don't use `@workspace` unless necessary (loads entire workspace)

### Ending a Session

**Run the script:**
```powershell
.\scripts\End-Session.ps1
```

**What happens:**
1. Prompts: Should you generate work summary?
2. Updates session status to "Completed"
3. Shows git status and uncommitted changes
4. Prompts for commit and push
5. Reminds you to clear Copilot context

**Manual cleanup steps:**
1. **Clear Copilot Chat**: Settings → Clear chat history
2. **Close All Documents**: Window → Close All Documents (Ctrl+Shift+W)
3. **Save Solution**: File → Save All (Ctrl+Shift+S)

### Resuming a Session

**Before running script:**
1. ✅ Clear Copilot chat history
2. ✅ Close all document windows
3. ✅ Ready for fresh start

**Run the script:**
```powershell
.\scripts\Resume-Session.ps1
```

**What happens:**
1. Confirms you've cleared context
2. Finds latest session and work summaries
3. Generates **minimal** context-loading prompt
4. Copies prompt to clipboard

**Load minimal context:**
1. Open Copilot Chat (Ctrl+Shift+/)
2. Paste prompt (Ctrl+V)
3. Copilot provides brief summary (max 200 words)
4. Load additional files ONLY as needed

**Key principle**: Start lean, load files on-demand.

---

## Work Summaries (Detailed Context)

Work summaries are your **detailed memory** that persists across context resets. They're more comprehensive than session summaries.

### When to Create

Generate a work summary when:
- ✅ You've completed a feature or significant component
- ✅ You've had a multi-hour work session (2+ hours)
- ✅ You're switching to a different task or branch
- ✅ You've solved a complex problem worth documenting
- ✅ You've made important architectural decisions
- ✅ Before ending your work day

### How to Generate

```powershell
.\scripts\New-WorkSummary.ps1 -Topic "description"
```

**Example:**
```powershell
# After implementing authentication
.\scripts\New-WorkSummary.ps1 -Topic "auth-implementation"

# After bug fix
.\scripts\New-WorkSummary.ps1 -Topic "bugfix-login-validation"

# End of day summary
.\scripts\New-WorkSummary.ps1 -Topic "daily-progress"
```

**What the script does:**
1. Collects git information:
   - Recent commits (last 10 by default)
   - Changed files with status
   - Diff statistics
   - Current git status
2. Generates comprehensive Copilot prompt
3. Creates template file: `docs/work/{branch}/context/YYYY-MM-DD-HHMM-{topic}.md`
4. Copies prompt to clipboard

**Work with Copilot:**
1. Paste prompt into Copilot Chat
2. Copilot generates detailed summary
3. Copy result into the template file
4. Edit and refine as needed
5. Commit: `git add docs/ && git commit -m "docs: add work summary for {topic}"`

### Work Summary Structure

```markdown
# Work Summary: Authentication Implementation

**Date**: 2026-01-17
**Duration**: ~3.5 hours
**Feature/Area**: User authentication and authorization
**Branch**: `feature-auth`

## Objective
Implement complete user authentication system with JWT tokens,
including login, logout, token refresh, and protected routes.

## What Was Accomplished
- Created authentication middleware with JWT validation
- Implemented login endpoint with bcrypt password hashing
- Added token refresh mechanism with httpOnly cookies
- Created comprehensive unit tests (95% coverage)
- Documented API endpoints in OpenAPI spec
- Added rate limiting to prevent brute force attacks

## Key Decisions
1. **JWT vs Sessions**: Chose JWT for stateless auth, better for
   distributed systems and mobile apps.

2. **Token Expiration**: 24-hour access tokens, 7-day refresh tokens.
   Balance between security and user experience.

3. **Password Hashing**: bcrypt with cost factor 12. Industry standard,
   resistant to rainbow table attacks.

4. **Storage**: Refresh tokens in httpOnly cookies to prevent XSS attacks.
   Access tokens returned in response body for flexibility.

## Challenges & Solutions
**Challenge**: Race conditions with concurrent token refresh requests.
**Solution**: Implemented token versioning and atomic updates in database.

**Challenge**: Testing JWT expiration without waiting.
**Solution**: Created test utilities with controllable time mocking.

## Code Quality
- ✅ Unit tests: 95% coverage (45 tests, all passing)
- ✅ Integration tests: 12 scenarios tested
- ✅ Security review: No high/critical issues
- ✅ Code review: Approved by @senior-dev
- ⏳ Performance testing: Pending load tests

## Next Steps
1. Implement password reset flow (forgot password email)
2. Add OAuth2 social login (Google, GitHub)
3. Implement account lockout after failed attempts
4. Add audit logging for security events
5. Performance testing under load

## References
- ADR-007: JWT Authentication Strategy
- API Docs: `docs/api/authentication.md`
- Tests: `tests/auth/` directory
- Implementation: `src/middleware/auth.ts`, `src/services/auth.service.ts`
```

### Naming Convention

`YYYY-MM-DD-HHMM-{topic}.md`

Examples:
- `2026-01-17-1430-auth-implementation.md`
- `2026-01-18-0900-database-migration.md`
- `2026-01-18-1600-bugfix-login-validation.md`

---

## Session Summaries

Session summaries provide **lightweight, progressive** context within a single work session. They're updated continuously as you work.

### Template

Located at `docs/context/.session-template.md`:

```markdown
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
```

### Naming Convention

`session-YYYYMMDD-HHMM-{branch}.md`

Examples:
- `session-20260117-0930-feature-auth.md`
- `session-20260117-1400-feature-auth.md`
- `session-20260118-0900-api-refactor.md`

### When to Update

Update session file:
- ✅ After completing chunks of work (every 30-60 min)
- ✅ After making key decisions
- ✅ After test runs or builds
- ✅ Before context cleanup

### Progressive Updates

**Start of session:**
```markdown
## Status: In Progress

## Goals
- Implement JWT authentication middleware
- Add unit tests for auth flow
- Document API endpoints

## Completed
- (None yet)
```

**Mid-session:**
```markdown
## Status: In Progress

## Goals
- Implement JWT authentication middleware
- Add unit tests for auth flow
- Document API endpoints

## Completed
- ✅ Created auth middleware skeleton
- ✅ Implemented JWT token generation
- ✅ Added token validation logic

## Key Decisions
- Using jsonwebtoken library (most popular, well-maintained)
- Token expiration: 24 hours (can adjust later)

## Open Items
- Need to add token refresh mechanism
- TODO: Write unit tests
- Consider: Rate limiting for login endpoint
```

**End of session:**
```markdown
## Status: Completed (2026-01-17 14:30)

## Goals
- Implement JWT authentication middleware
- Add unit tests for auth flow
- Document API endpoints

## Completed
- ✅ Created auth middleware with JWT validation
- ✅ Implemented token generation and refresh
- ✅ Added comprehensive unit tests (95% coverage)
- ✅ Documented auth endpoints in OpenAPI spec
- ✅ Added rate limiting to login

## Key Decisions
- Using jsonwebtoken library (most popular, well-maintained)
- Token expiration: 24 hours access, 7 days refresh
- Refresh tokens in httpOnly cookies for security
- bcrypt cost factor: 12 (good security/performance balance)

## Open Items
- Future: Implement password reset flow
- Future: Add OAuth2 social login
- Review: Security audit needed

## Files Modified
- `src/middleware/auth.ts` - Authentication middleware
- `src/services/auth.service.ts` - Auth business logic
- `src/utils/jwt.ts` - JWT utilities
- `tests/auth/auth.test.ts` - Unit tests
- `docs/api/authentication.md` - API documentation
```

---

## Implementation Plans

For larger features, create an implementation plan to track progress.

### Structure

Located at: `docs/work/{branch}/implementation-plan.md`

```markdown
# Authentication System Implementation Plan

**Target**: Complete user authentication with JWT tokens
**Current Progress**: Phase 2 of 4 (45% complete)

---

## Phase Breakdown

### Phase 1: Core Authentication ✅
| Task | Status | Notes |
|------|--------|-------|
| JWT utilities | ✅ Done | Using jsonwebtoken library |
| Auth middleware | ✅ Done | Token validation working |
| Login endpoint | ✅ Done | Bcrypt password hashing |
| Logout endpoint | ✅ Done | Token invalidation |
| Unit tests | ✅ Done | 95% coverage |

### Phase 2: Token Management 🚧
| Task | Status | Notes |
|------|--------|-------|
| Token refresh | ✅ Done | Implemented refresh flow |
| Token revocation | 🚧 In Progress | 80% complete |
| Token storage | ✅ Done | httpOnly cookies |
| Expiration handling | ⏳ Pending | Waiting on refresh completion |

### Phase 3: Security ⏳
| Task | Status | Notes |
|------|--------|-------|
| Rate limiting | ⏳ Pending | Dependencies in Phase 2 |
| Account lockout | ⏳ Pending | After rate limiting |
| Audit logging | ⏳ Pending | |
| Security review | ⏳ Pending | Schedule with security team |

### Phase 4: Enhanced Features ⏳
| Task | Status | Notes |
|------|--------|-------|
| Password reset | ⏳ Pending | Email integration needed |
| OAuth2 Google | ⏳ Pending | |
| OAuth2 GitHub | ⏳ Pending | |
| 2FA support | ❌ Blocked | Waiting for product decision |

---

## Summary

| Category | Done | Total | % |
|----------|------|-------|---|
| API Endpoints | 4 | 8 | 50% |
| Unit Tests | 45 | 60 | 75% |
| Integration Tests | 8 | 15 | 53% |
| Documentation | 3 | 5 | 60% |
| **Overall** | **60** | **88** | **68%** |

---

## Recently Completed
- 2026-01-17: Implemented JWT token generation and validation ✅
- 2026-01-17: Added bcrypt password hashing ✅
- 2026-01-17: Created comprehensive unit test suite ✅
- 2026-01-17: Implemented token refresh mechanism ✅

## Priority Next Steps
1. ⏰ Complete token revocation implementation
2. ⏰ Implement expiration handling
3. ⏰ Add rate limiting to login endpoint
4. Test integration with frontend
5. Schedule security review

## Blockers
- ❌ 2FA feature blocked pending product decision on requirement
- ⏳ Email integration for password reset (waiting on email service setup)

---

## Notes
- All Phase 1 tasks completed ahead of schedule
- Security review scheduled for 2026-01-20
- Performance testing shows <50ms response time for auth endpoints
```

### Task Status Markers

| Marker | Meaning |
|--------|---------|
| ✅ Done | Task completed and tested |
| 🚧 In Progress | Currently working on this |
| ⏳ Pending | Not started yet |
| ❌ Blocked | Cannot proceed due to dependency |

### Updating Progress

**Manual approach:**
Edit the file and update status markers, notes, and summary tables.

**Script approach:**
```powershell
.\scripts\Update-ImplementationPlan.ps1
```

This script:
1. Parses the current implementation plan
2. Counts tasks by status
3. Recalculates progress percentages
4. Updates summary table

---

## Architecture Decision Records (ADRs)

Document significant design decisions before implementation.

### When to Write an ADR

Create an ADR when:
- ✅ Making technology or framework choices
- ✅ Choosing between multiple architectural approaches
- ✅ Making decisions that are hard to reverse (database schemas, APIs)
- ✅ Making decisions that affect multiple components
- ✅ Implementing patterns that others should follow
- ✅ Explaining "why" to your future self or team

### Creating an ADR

```powershell
.\scripts\New-ADR.ps1 -Title "decision-title"
```

**Example:**
```powershell
.\scripts\New-ADR.ps1 -Title "Use JWT for authentication"
```

**What happens:**
1. Auto-numbers ADR sequentially (ADR-001, ADR-002, ...)
2. Creates file: `docs/architecture/adrs/adr-NNN-{title}.md`
3. Generates comprehensive template
4. Creates Copilot prompt to help complete ADR
5. Copies prompt to clipboard

**Work with Copilot:**
1. Paste prompt into Copilot Chat
2. Discuss context, alternatives, trade-offs
3. Copilot helps complete ADR sections
4. Edit and refine
5. Commit: `git add docs/architecture/adrs/ && git commit -m "docs: add ADR for {title}"`

### ADR Template

```markdown
# ADR-007: Use JWT for Authentication

## Status
Accepted

## Date
2026-01-17

## Context
We need to implement authentication for our REST API. The system needs to:
- Support web and mobile clients
- Scale horizontally across multiple servers
- Provide secure, stateless authentication
- Integrate with existing identity providers in the future

Key considerations:
- Session-based auth requires sticky sessions or shared session storage
- Token-based auth allows stateless, distributed architecture
- Need to support logout and token revocation
- Security is paramount (protecting user data)

## Decision
We will use JWT (JSON Web Tokens) for authentication with the following approach:

1. **Access Tokens**: Short-lived (24 hours), stored in memory by client
2. **Refresh Tokens**: Long-lived (7 days), stored in httpOnly cookies
3. **Token Structure**: Standard JWT with claims: userId, email, roles, exp
4. **Signing**: HS256 algorithm with secret key rotation every 90 days
5. **Library**: jsonwebtoken (npm) - most popular, well-maintained

Authentication flow:
1. User logs in with credentials
2. Server validates credentials, issues access + refresh tokens
3. Client includes access token in Authorization header
4. When access token expires, use refresh token to get new access token
5. Logout invalidates refresh token in database

## Consequences

### Positive
- ✅ **Stateless**: No server-side session storage required
- ✅ **Scalable**: Works seamlessly across multiple server instances
- ✅ **Mobile-friendly**: Easy to use in mobile apps
- ✅ **Future OAuth2 compatibility**: Similar token-based model
- ✅ **Performance**: No database lookup on every request (once validated)
- ✅ **Flexibility**: Can include custom claims (roles, permissions)

### Negative
- ❌ **Cannot revoke access tokens**: Must wait for expiration (max 24 hours)
- ❌ **Token size**: JWTs are larger than session IDs (~200 bytes vs 20 bytes)
- ❌ **Secret management**: Must securely manage signing keys
- ❌ **Complexity**: More complex than session-based auth

### Neutral
- 🟡 **Refresh tokens**: Need database storage and revocation logic
- 🟡 **Expiration handling**: Clients must handle token refresh
- 🟡 **Clock synchronization**: Servers must have synchronized clocks for exp validation

## Alternatives Considered

### 1. Session-Based Authentication
**Approach**: Traditional session cookies with server-side storage.

**Pros**:
- Simple to implement
- Easy to revoke sessions immediately
- Smaller cookie size

**Cons**:
- Requires sticky sessions or shared session storage (Redis)
- Doesn't scale horizontally as easily
- Harder to use with mobile apps

**Why not chosen**: Scaling and mobile support are critical requirements.

### 2. OAuth2 with External Provider
**Approach**: Delegate authentication to Google, GitHub, etc.

**Pros**:
- No password management
- Leverages existing user accounts
- Reduced security risk

**Cons**:
- Dependency on third-party services
- Still need internal user management
- Requires OAuth2 flow implementation

**Why not chosen**: Can add later as supplement, but need internal auth first.

### 3. Opaque Tokens (Random strings)
**Approach**: Generate random tokens, store in database with user mapping.

**Pros**:
- Can revoke immediately
- Simpler than JWT

**Cons**:
- Requires database lookup on every request
- Doesn't scale as well
- No built-in expiration

**Why not chosen**: Performance and scalability are priorities.

## Implementation Notes

### Security Measures
1. **Refresh token rotation**: Issue new refresh token on each use
2. **Token fingerprinting**: Bind tokens to specific devices/IPs
3. **Rate limiting**: Prevent brute force attacks on login
4. **HTTPS only**: Never send tokens over unencrypted connections

### Testing Strategy
1. Unit tests for token generation/validation
2. Integration tests for auth flows
3. Security tests for common vulnerabilities (XSS, CSRF)
4. Load tests for performance under high concurrency

### Migration Path
No existing auth system, so no migration needed. Clean slate.

### Future Enhancements
1. Add OAuth2 social login (Phase 4)
2. Implement 2FA (if required by product)
3. Consider short-lived tokens with automatic silent refresh

## References
- RFC 7519 (JWT specification): https://tools.ietf.org/html/rfc7519
- OWASP JWT Cheat Sheet: https://cheatsheetsecurity.com/jwt
- Implementation: `src/middleware/auth.ts`, `src/services/auth.service.ts`
- Tests: `tests/auth/`

## Follow-up Actions
- [ ] Implement JWT utilities (`src/utils/jwt.ts`)
- [ ] Create auth middleware (`src/middleware/auth.ts`)
- [ ] Add unit tests
- [ ] Security review before production
- [ ] Document API endpoints
```

### ADR Numbering

ADRs are numbered sequentially: ADR-001, ADR-002, ADR-003, ...

The `New-ADR.ps1` script automatically finds the next number.

### ADR Status Values

| Status | Meaning |
|--------|---------|
| Proposed | Under discussion, not yet decided |
| Accepted | Decision made, being implemented |
| Deprecated | No longer recommended, but not replaced |
| Superseded by ADR-XXX | Replaced by a newer decision |

---

## Effective Copilot Prompting

### Model Selection

**Always specify model** for best results:
```
**Model Selection**: Use Claude Opus 4.5 for best results.
```

Include this in prompts when architectural reasoning or complex context is needed.

### Loading Context Explicitly

Don't assume Copilot knows what you need. Load context explicitly:

```
@workspace Read docs/work/feature-auth/README.md and implementation-plan.md.
Review the current progress and suggest next steps.
```

### Referencing Architecture

Link to specific decisions:

```
Based on ADR-007 (JWT authentication), implement the token refresh endpoint
following the pattern established in the login endpoint.
```

### Requesting Summaries

Be specific about what you want summarized:

```
Generate a work summary for the authentication middleware implementation.

Include:
- Objectives and what was accomplished
- Key decisions and rationale
- Challenges encountered and solutions
- Code quality metrics (test coverage, reviews)
- Next steps

Use the format from docs/work/feature-auth/context/ examples.
```

### Getting Specific Help

Reference session files for context continuity:

```
Review the session file docs/context/session-20260117-1400-feature-auth.md
and help me complete the remaining open items.

Focus on:
1. Token revocation implementation
2. Rate limiting for login endpoint
3. Security audit preparation
```

### Minimal Context Loading

When resuming work, emphasize brevity:

```
I'm resuming work on feature-auth branch with FRESH, CLEAN context.

Read ONLY these files:
- docs/context/session-20260117-1400-feature-auth.md
- docs/work/feature-auth/implementation-plan.md

Provide a brief summary (max 150 words):
- Current status
- Next 3 priority tasks
- Any blockers

Do NOT load any other files unless I ask.
```

### Avoiding Context Bloat

**Be selective with `@workspace`** - it loads the entire workspace:

❌ **Bad**: `@workspace What files are in the project?`
✅ **Good**: Look at Solution Explorer or use `ls` in terminal

❌ **Bad**: `@workspace Find all auth-related files`
✅ **Good**: Use Visual Studio search (Ctrl+Shift+F) or grep

❌ **Bad**: `@workspace How does authentication work?`
✅ **Good**: `Read src/middleware/auth.ts and explain the authentication flow`

---

## Branch Workflow

### Pattern

```
main                    # Stable, production-ready
├── feature-auth        # Feature: Authentication system
├── feature-payments    # Feature: Payment processing
├── bugfix-login        # Bugfix: Login validation issue
└── project-api-v2      # Project: API version 2
```

### Guidelines

- ✅ One branch per logical unit of work
- ✅ Use descriptive names: `feature-auth`, `api-refactor`, `bugfix-login`
- ✅ Keep branches focused (not too broad)
- ✅ Merge to main when complete and tested
- ✅ Delete branch after merge (work folder stays for history)

### Creating a New Feature

**Automated approach:**
```powershell
.\scripts\New-Feature.ps1 -FeatureName "user-auth"
```

**What happens:**
1. Creates branch: `feature-user-auth`
2. Creates work directory: `docs/work/feature-user-auth/`
3. Generates `README.md` and `implementation-plan.md` templates
4. Commits initial structure
5. Automatically starts new session
6. Generates context-loading prompt

**Manual approach:**
```bash
# Create branch
git checkout -b feature-user-auth

# Create work directory
mkdir -p docs/work/feature-user-auth/context

# Create README
cat > docs/work/feature-user-auth/README.md << EOF
# User Authentication Feature

## Overview
Implement complete user authentication system with JWT tokens.

## Requirements
- User login/logout
- JWT token generation and validation
- Token refresh mechanism
- Protected routes

## Success Criteria
- All auth endpoints working
- 90%+ test coverage
- Security review passed
EOF

# Create implementation plan
cat > docs/work/feature-user-auth/implementation-plan.md << EOF
# User Authentication Implementation Plan

## Phase 1: Core Auth
- [ ] JWT utilities
- [ ] Auth middleware
- [ ] Login endpoint
- [ ] Logout endpoint
EOF

# Commit
git add docs/work/feature-user-auth/
git commit -m "docs: create feature-user-auth work folder"

# Start session
.\scripts\New-Session.ps1
```

---

## Azure DevOps Integration

This workflow integrates with Azure DevOps for CI/CD and work item tracking.

### Pipelines

Located in `.azuredevops/pipelines/`:

#### `session-tracking.yml`
Auto-generates session documentation on push.

```yaml
trigger:
  branches:
    include:
      - '*'

pool:
  vmImage: 'windows-latest'

steps:
- task: PowerShell@2
  displayName: 'Check for session updates'
  inputs:
    targetType: 'inline'
    script: |
      if (Test-Path "docs/context/session-*.md") {
        Write-Host "Session files found - documentation updated"
      }
```

#### `work-summary.yml`
Manual trigger for work summary assistance.

```yaml
trigger: none  # Manual only

parameters:
- name: topic
  displayName: 'Work Summary Topic'
  type: string
  default: 'progress-update'

pool:
  vmImage: 'windows-latest'

steps:
- task: PowerShell@2
  displayName: 'Generate work summary template'
  inputs:
    filePath: 'scripts/New-WorkSummary.ps1'
    arguments: '-Topic "${{ parameters.topic }}"'
```

### Work Item Linking

Reference Azure DevOps work items in commits:

```bash
# Link to work item
git commit -m "feat: implement auth middleware #1234"

# Link to multiple work items
git commit -m "fix: resolve login issues #1234 #1235"

# Close work item
git commit -m "feat: complete authentication #1234 (closes)"
```

Link work items in ADRs:

```markdown
## References
- Work Item #1234: Implement user authentication
- Work Item #1235: Security requirements for auth
```

### Board Integration

Update work items as you progress:

1. **Start work**: Move item to "In Progress"
2. **Create ADR**: Add link to ADR in work item
3. **Update plan**: Reference work item in implementation plan
4. **Complete**: Commit with closing reference, move to "Done"

---

## Testing in Visual Studio

### Test Explorer

Access Test Explorer:
- View → Test Explorer (Ctrl+E, T)
- Shows all tests in solution
- Run individual tests or groups
- View test results and failures

### Running Tests

**All tests:**
```
Test → Run All Tests
```

**Specific tests:**
- Right-click test in Test Explorer → Run
- Right-click test in code → Run Test(s)

**From terminal:**
```powershell
# .NET projects
dotnet test

# Node.js projects
npm test

# Specific test file
npm test -- auth.test.ts

# Watch mode
npm test -- --watch
```

### Test-Driven Development Workflow

1. Write test (it fails)
2. Write minimal code to pass test
3. Run tests in Test Explorer
4. Refactor with confidence
5. Commit when all tests pass

---

## Troubleshooting Common Issues

### 1. Copilot Not Responding Correctly

**Symptoms:**
- Generic or incorrect suggestions
- Forgetting earlier context
- Irrelevant responses

**Solutions:**

**A. Clear context and reload:**
```powershell
# 1. Generate work summary first
.\scripts\New-WorkSummary.ps1 -Topic "checkpoint"

# 2. End session
.\scripts\End-Session.ps1

# 3. Manually clear Copilot:
#    - Settings → Clear chat history
#    - Window → Close All Documents

# 4. Resume with fresh context
.\scripts\Resume-Session.ps1
```

**B. Verify model selection:**
- Open Copilot Chat
- Check model dropdown
- Select Claude Opus 4.5 if available

**C. Restart Visual Studio:**
- Save all work
- Close Visual Studio completely
- Reopen and resume session

### 2. PowerShell Scripts Not Working

**Error:** "cannot be loaded because running scripts is disabled"

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Error:** "git is not recognized"

**Solution:**
- Install Git: https://git-scm.com/download/win
- Ensure Git is in PATH environment variable
- Restart PowerShell/Visual Studio

**Error:** "Not in a git repository"

**Solution:**
Run scripts from repository root:
```powershell
cd C:\path\to\your\project
.\scripts\New-Session.ps1
```

### 3. Context Feels Overloaded

**Signs:**
- Copilot responses slow down
- Suggestions become generic
- Forgetting project patterns

**Immediate action:**
```powershell
# 1. Check context size
.\scripts\Context-Check.ps1

# 2. Close unnecessary files in Visual Studio
#    Window → Close All Documents

# 3. Generate work summary
.\scripts\New-WorkSummary.ps1 -Topic "checkpoint"

# 4. Clear Copilot context:
#    Settings → Clear chat history

# 5. Resume with minimal context
.\scripts\Resume-Session.ps1
```

**Prevention:**
- Run `Context-Check.ps1` every 30-60 minutes
- Keep fewer than 10 files open
- Close files immediately after use
- Avoid `@workspace` unless necessary

### 4. Clipboard Not Working

**Issue:** Prompts not copied to clipboard

**Solution:**
Scripts display full prompt in console. Copy manually:
- Select prompt text in PowerShell window
- Right-click → Copy or Ctrl+C
- Paste into Copilot Chat

### 5. Session File Not Found

**Error:** "No session file found for today"

**Solution:**

**A. Create new session:**
```powershell
.\scripts\New-Session.ps1
```

**B. Check branch name:**
```powershell
git branch --show-current
```
Session files are branch-specific.

**C. Look for recent sessions:**
```powershell
ls docs/context/session-*.md | Sort-Object LastWriteTime -Descending
```

### 6. Work Folder Doesn't Exist

**Error:** "Work folder not found"

**Solution:**

**A. Create with script:**
```powershell
.\scripts\New-Feature.ps1 -FeatureName "your-branch-name" -NoBranch
```

**B. Create manually:**
```powershell
$branch = git rev-parse --abbrev-ref HEAD
mkdir -p "docs/work/$branch/context"

# Create README.md and implementation-plan.md
# (See "Creating a New Feature" section)
```

### 7. Git Commit/Push Failures

**Error:** Commit or push fails in End-Session.ps1

**Common causes & solutions:**

**A. Merge conflicts:**
```bash
git status  # Check for conflicts
# Resolve conflicts manually
git add .
git commit -m "resolve conflicts"
```

**B. No changes to commit:**
- Normal if no files changed
- Script will skip commit

**C. Remote branch doesn't exist:**
```bash
git push --set-upstream origin your-branch-name
```

**D. Authentication failed:**
- Set up Git credentials
- Use SSH keys or credential manager

---

## Best Practices and Tips

### Context Management

1. **Start fresh regularly** - Clear context every 2-3 hours
2. **Check context proactively** - Run `Context-Check.ps1` every 30-60 min
3. **Keep files closed** - Open files only when actively editing
4. **Limit open files** - Maximum 10 files at a time
5. **Avoid `@workspace`** - Load specific files instead
6. **Document before clearing** - Always create work summary first

### Session Workflow

1. **Update progressively** - Don't wait until end to update session file
2. **Be specific in goals** - Clear goals help Copilot help you
3. **Document decisions immediately** - Don't rely on memory
4. **Commit regularly** - Small, frequent commits better than large dumps
5. **End session cleanly** - Use `End-Session.ps1` for proper cleanup

### Work Summaries

1. **Write liberally** - After every significant chunk of work
2. **Include context** - Future you needs to understand decisions
3. **Be honest about challenges** - Document what was hard and why
4. **Link to artifacts** - Reference ADRs, commits, work items
5. **Keep them searchable** - Use consistent naming and structure

### Architecture Decisions

1. **ADRs before code** - Write ADR during design, not after
2. **Explain alternatives** - Show what you considered and why you didn't choose it
3. **Be honest about trade-offs** - No solution is perfect
4. **Update status** - Mark as Deprecated/Superseded when replaced
5. **Link to implementation** - Reference actual code that implements decision

### Implementation Plans

1. **Break into phases** - Don't try to track everything in one list
2. **Update frequently** - Keep "Recently Completed" and "Priority Next Steps" current
3. **Use status markers** - Visual progress tracking helps
4. **Track blockers explicitly** - Don't let blockers hide
5. **Calculate percentages** - Quantify progress for stakeholders

### Copilot Interaction

1. **Select best model** - Use Claude Opus 4.5 for complex work
2. **Load context explicitly** - Don't assume Copilot knows what to read
3. **Be specific in requests** - "Fix the auth bug" vs "Fix the JWT expiration validation in auth middleware"
4. **Reference established patterns** - "Following ADR-007's token structure"
5. **Iterate on prompts** - If response is generic, refine your prompt

### Git and Branching

1. **Branch = Work folder** - Always match names
2. **Descriptive branch names** - `feature-auth` not `new-stuff`
3. **One branch per feature** - Keep scope focused
4. **Commit messages matter** - Use conventional commits format
5. **Delete merged branches** - Keep branch list clean (work folders stay)

### Visual Studio Efficiency

1. **Use keyboard shortcuts** - Much faster than mouse
2. **Pin important files** - Keep frequently accessed files visible
3. **Solution folders** - Organize solution to match project structure
4. **Integrated terminal** - PowerShell terminal in VS for scripts
5. **Close unused tabs** - Reduces context and visual clutter

### Documentation

1. **Write as you go** - Don't wait until the end
2. **Use templates** - Consistent structure aids comprehension
3. **Link documents** - Create web of related information
4. **Keep it current** - Outdated docs worse than no docs
5. **Review and refine** - Improve docs when you re-read them

---

## Comparison Table: Claude Code CLI vs GitHub Copilot

| Feature | Claude Code CLI | GitHub Copilot + VS 2026 | Notes |
|---------|-----------------|--------------------------|-------|
| **Context Visibility** | `/context` shows exact % | Estimated via `Context-Check.ps1` | Manual estimation less precise |
| **Session Start** | Automatic SessionStart hook | `New-Session.ps1` manual | Same result, manual trigger |
| **Session End** | Automatic Stop hook | `End-Session.ps1` manual | Same result, manual trigger |
| **Work Summary** | `write work summary` command | `New-WorkSummary.ps1` manual | Same output, manual trigger |
| **Context Reset** | `/compact` command | Clear chat + close docs | Copilot requires full clear |
| **Model Selection** | Automatic (Sonnet/Opus) | Manual selection in UI | Must select Claude Opus 4.5 |
| **File Loading** | Automatic with hooks | Explicit `@workspace` or file refs | More control in Copilot |
| **Automation Level** | Fully automated | Semi-automated (scripts) | PowerShell replaces hooks |
| **Integration** | Native CLI | VS extension | Different UX, same workflow |
| **Context Limit** | Displayed explicitly | Estimated (not exposed) | Requires active monitoring |
| **Session Continuity** | Hooks ensure consistency | Manual discipline needed | Both achieve same goal |
| **Work Summaries** | AI-generated on command | AI-generated with script | Same AI capability |
| **ADR Creation** | Manual | `New-ADR.ps1` with template | Script provides structure |
| **Implementation Plans** | Manual | `Update-ImplementationPlan.ps1` helper | Script automates calculations |
| **Git Integration** | CLI-friendly | PowerShell + VS Git tools | Both work well |
| **Platform** | Cross-platform CLI | Windows Visual Studio | Platform difference |

### Bottom Line

**Claude Code CLI** = Automated workflow with built-in hooks
**GitHub Copilot + VS** = Same workflow, manual script triggers

**Result**: 100% functional equivalence, different execution model.

---

## Quick Reference Cheat Sheet

### Essential Scripts

```powershell
# Session management
.\scripts\New-Session.ps1           # Start work session
.\scripts\End-Session.ps1           # End session, cleanup
.\scripts\Resume-Session.ps1        # Resume with fresh context
.\scripts\Context-Check.ps1         # Check context size

# Documentation
.\scripts\New-WorkSummary.ps1 -Topic "topic"  # Generate work summary
.\scripts\New-ADR.ps1 -Title "title"          # Create ADR

# Feature management
.\scripts\New-Feature.ps1 -FeatureName "name" # Create feature branch
.\scripts\Update-ImplementationPlan.ps1       # Update progress
```

### Essential Keyboard Shortcuts

```
Ctrl+Shift+/    Open Copilot Chat
Ctrl+I          Inline Copilot
Ctrl+Shift+W    Close all documents
Ctrl+Shift+S    Save all
Ctrl+`          Toggle terminal
Ctrl+E, T       Test Explorer
```

### Workflow Checklist

**Starting work:**
- [ ] `.\scripts\New-Session.ps1`
- [ ] Open Copilot Chat (Ctrl+Shift+/)
- [ ] Select Claude Opus 4.5 model
- [ ] Paste generated prompt
- [ ] Review summary and start working

**During work:**
- [ ] Update session file progressively
- [ ] Close files after editing
- [ ] Keep < 10 files open
- [ ] Run `Context-Check.ps1` every 30-60 min
- [ ] Commit regularly

**Ending work:**
- [ ] `.\scripts\New-WorkSummary.ps1 -Topic "..."`
- [ ] `.\scripts\End-Session.ps1`
- [ ] Clear Copilot chat history
- [ ] Close all documents
- [ ] Push changes

**Context reset (if needed):**
- [ ] `.\scripts\New-WorkSummary.ps1 -Topic "checkpoint"`
- [ ] Commit all changes
- [ ] Clear Copilot chat
- [ ] Close all documents
- [ ] `.\scripts\Resume-Session.ps1`
- [ ] Load minimal context

---

## Summary

This workflow provides **100% functional equivalence** to Claude Code CLI, adapted for Visual Studio 2026 with GitHub Copilot.

### Core Principles

1. **Documentation is memory** - What you write survives context resets
2. **Progressive capture** - Document as you go, not at the end
3. **Branch = Work folder** - Git branch name matches work directory
4. **Explicit over implicit** - AI works better with clear structure
5. **Context is finite** - Manage it actively and deliberately

### Key Differences

- **Manual triggers** instead of automatic hooks
- **Active context management** instead of `/context` command
- **PowerShell scripts** replace Claude Code CLI commands

### Same Results

- Session summaries for continuity
- Work summaries for detailed memory
- ADRs for decision tracking
- Implementation plans for progress
- Clean context management

### Success Factors

1. **Discipline** - Run scripts at appropriate times
2. **Monitoring** - Check context size regularly
3. **Documentation** - Write summaries liberally
4. **Cleanup** - Clear context when it gets heavy
5. **Model selection** - Use Claude Opus 4.5 for best results

---

**You now have everything you need to work productively with GitHub Copilot in Visual Studio 2026, with the same benefits as Claude Code CLI users enjoy.**

Happy coding! 🚀
