# The specification.md Convention

## Purpose

`specification.md` is the human-authored directive that tells the LLM what to build for a given feature or task. It captures your intent, constraints, and decisions **before** the LLM generates an implementation plan.

This fills a gap in the base DevArch workflow: without a specification, the LLM has only the folder name to work from, which is too thin a contract for complex work.

## Where It Lives

```
docs/work/{feature-name}/specification.md
```

Each feature work folder gets its own specification.

## What It Is (and What It Isn't)

| Document | Author | When Written | Purpose |
|---|---|---|---|
| `specification.md` | You (human) | Before work begins | Declares intent and constraints |
| `implementation-plan.md` | LLM | After reading specification | Breaks intent into actionable steps |
| `README.md` | You or LLM | After work is complete | Retrospective description of what's in the folder |
| ADRs | You | During review of implementation plan | Records decisions and rationale |

The specification is **not** a technical design doc. It's what you want, why you want it, and what the LLM should not assume. The LLM figures out the how.

## What to Include

### Required

- **Objective**: One or two sentences describing what this feature does and why it exists.
- **Scope**: What's in and what's out. Be explicit about boundaries.
- **Constraints**: Non-negotiable requirements — tech stack choices, compliance rules, performance targets, security requirements.
- **Key Decisions Already Made**: Anything you've already decided that the LLM should not second-guess.

### Optional (but recommended for complex features)

- **User Roles / Actors**: Who interacts with this feature and what they can do.
- **Business Rules**: Specific logic the LLM needs to implement correctly.
- **Dependencies**: Other systems, services, or features this depends on.
- **Out of Scope**: Explicitly list what this feature does NOT cover to prevent scope creep.
- **Acceptance Criteria**: How you'll know it's done.

## What NOT to Include

- Implementation details (that's the LLM's job in the implementation plan)
- Boilerplate project context (that's in CLAUDE.md via SummonAIKit scaffolding)
- Technology documentation (that's in skills)

The specification should be **lean**. The scaffolding from SummonAIKit + Context7 already provides project context, tech stack knowledge, and dependency-specific skills. The specification only needs to carry what's unique to this feature.

## Example

```markdown
# Feature: Add Two-Factor Authentication

## Objective
Add TOTP-based two-factor authentication for external users accessing the application portal.

## Scope
- TOTP via authenticator apps (Google Authenticator, Microsoft Authenticator, Authy)
- External users only; internal staff excluded for now
- Enrollment flow, verification flow, and recovery flow

## Out of Scope
- SMS-based OTP (deferred to future iteration)
- Internal user 2FA
- Hardware security keys

## Constraints
- Must integrate with existing identity server infrastructure
- Must comply with organizational security requirements
- Recovery flow must not bypass 2FA entirely — use backup codes generated at enrollment

## Key Decisions
- TOTP over email OTP: authenticator apps are more secure and don't depend on email availability
- Mandatory, not opt-in: all external users must enroll after a grace period
- Backup codes: 10 single-use codes generated at enrollment

## User Roles
- **External User**: Enrolls in 2FA, verifies on login, can regenerate backup codes
- **Admin**: Can reset a user's 2FA enrollment if they lose access

## Acceptance Criteria
- External user can enroll using any standard TOTP authenticator app
- Login requires TOTP code after password
- User can recover access using backup codes
- Admin can reset 2FA for a specific user
```

## How to Use It

1. Create the feature work folder: `docs/work/{feature-name}/`
2. Write `specification.md` in that folder
3. Prompt Claude Code:

   > "Read the specification at `docs/work/{feature-name}/specification.md` and generate an implementation plan. Identify any open questions or gaps."

4. Review the implementation plan, answer the open questions
5. Tell Claude Code to implement
6. Decisions made during review become ADRs

## Relationship to Other DevArch Components

- **CLAUDE.md** provides "who we are and what this project is" (via SummonAIKit)
- **Skills** provide "how to use our tech stack correctly" (via Context7)
- **specification.md** provides "what I want from this specific feature"
- **implementation-plan.md** provides "how the LLM will build it"
- **Session summaries** provide "where we left off"
- **ADRs** provide "why we decided what we decided"

Each document has a distinct job. The specification is the bridge between human intent and LLM execution.
