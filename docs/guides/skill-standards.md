# Skill-Building Standards

Condensed from Anthropic's "The Complete Guide to Building Skills for Claude" (January 2026). Full PDF available at `docs/references/The-Complete-Guide-to-Building-Skill-for-Claude.pdf`.

## What Is a Skill

A skill is a folder containing instructions that teaches Claude how to handle specific tasks or workflows. Instead of re-explaining preferences and domain expertise every conversation, you teach Claude once.

## Folder Structure

```
your-skill-name/
├── SKILL.md          # Required — main instruction file
├── scripts/          # Optional — executable code (Python, Bash, etc.)
├── references/       # Optional — documentation loaded as needed
└── assets/           # Optional — templates, fonts, icons
```

## Critical Rules

- **SKILL.md must be exactly `SKILL.md`** — case-sensitive, no variations
- **Folder name must be kebab-case** — `my-skill-name` not `MySkillName` or `my_skill_name`
- **No README.md inside the skill folder** — all documentation goes in SKILL.md or references/
- **No XML angle brackets (`< >`) in frontmatter** — security restriction
- **No "claude" or "anthropic" in skill name** — reserved

## YAML Frontmatter

The frontmatter is the most important part. It determines when Claude loads your skill.

### Minimal Required Format

```yaml
---
name: your-skill-name
description: What it does. Use when user asks to [specific phrases].
---
```

### Field Requirements

| Field           | Required | Rules                                                                      |
| --------------- | -------- | -------------------------------------------------------------------------- |
| `name`          | Yes      | kebab-case, no spaces/capitals, match folder name                          |
| `description`   | Yes      | Must include WHAT it does + WHEN to use it. Under 1024 chars. No XML tags. |
| `license`       | No       | MIT, Apache-2.0, etc.                                                      |
| `compatibility` | No       | Environment requirements (1-500 chars)                                     |
| `metadata`      | No       | Custom key-value pairs: author, version, mcp-server, etc.                  |

### Description Quality

The description is how Claude decides whether to load your skill. Get it right.

**Structure:** `[What it does]` + `[When to use it]` + `[Key capabilities]`

**Good:**

```yaml
description: Manages Linear project workflows including sprint planning,
  task creation, and status tracking. Use when user mentions "sprint",
  "Linear tasks", "project planning", or asks to "create tickets".
```

**Bad:**

```yaml
description: Helps with projects.
```

## Progressive Disclosure

Skills use three levels to minimize token usage:

1. **YAML frontmatter** — Always loaded in system prompt. Just enough for Claude to know when to use the skill.
2. **SKILL.md body** — Loaded when Claude thinks the skill is relevant. Full instructions.
3. **Linked files (references/, scripts/)** — Loaded only when needed during execution.

Keep SKILL.md under 5,000 words. Move detailed documentation to `references/`.

## Writing Instructions

### Recommended Structure

```markdown
---
name: your-skill
description: [What + When]
---

# Your Skill Name

## Instructions

## Step 1: [First Major Step]

Clear explanation of what happens.

## Examples

Example 1: [Common scenario]
User says: "[trigger phrase]"
Result: [Expected outcome]

## Troubleshooting

Error: [Common error message]
Cause: [Why it happens]
Solution: [How to fix]
```

### Best Practices

- Be specific and actionable — `Run python scripts/validate.py --input {filename}` not "validate the data"
- Put critical instructions at the top
- Include error handling for common failures
- Reference bundled resources clearly — `Consult references/api-patterns.md for rate limiting guidance`
- For critical validations, use scripts rather than language instructions — code is deterministic

## Common Patterns

### Pattern 1: Sequential Workflow Orchestration

Multi-step processes in a specific order with dependencies between steps and validation at each stage.

### Pattern 2: Multi-MCP Coordination

Workflows spanning multiple services with clear phase separation and data passing between MCPs.

### Pattern 3: Iterative Refinement

Output quality improves through generate → validate → fix → re-validate loops.

### Pattern 4: Context-Aware Tool Selection

Same outcome achieved through different tools depending on context (file type, size, destination).

### Pattern 5: Domain-Specific Intelligence

Specialized knowledge embedded in the skill beyond tool access — compliance rules, business logic, governance.

## Testing

### Three Areas to Test

1. **Triggering** — Does the skill load on relevant queries? Does it stay quiet on unrelated ones?
2. **Functional** — Does it produce correct outputs? Do API calls succeed? Are edge cases handled?
3. **Performance** — Does the skill reduce back-and-forth, tool calls, and tokens vs. working without it?

### Quick Debugging

- **Skill doesn't trigger:** Description too vague. Add specific trigger phrases.
- **Triggers too often:** Add negative triggers. Be more specific about scope.
- **Instructions not followed:** Instructions too verbose or buried. Put critical items at top. Move detail to references/.
- **Slow or degraded:** Too much content loaded. Use progressive disclosure. Keep SKILL.md lean.

Ask Claude: "When would you use the [skill name] skill?" — Claude will quote the description back, revealing what's missing.

## Integration with SpecArch Workflow

In this SpecArch fork, skills are generated in two ways:

1. **Auto-generated by SummonAIKit + Context7** — Scans repo dependencies and generates technology-specific skills with current documentation. These are loaded via the `skill-instructions-hook.sh` hook on every prompt.

2. **Manually created for custom workflows** — Use the `skill-creator` skill in Claude Code or build from the template at `docs/guides/skill-template/SKILL.md`.

When creating skills as part of a SpecArch project, follow these standards to ensure consistency and compatibility.

## Walkthrough: Building a Skill from Scratch

This example walks through creating a skill for implementing TOTP-based two-factor authentication. It demonstrates the thought process, not just the output.

### Step 1: Identify the Use Case

Ask yourself: what task do I keep explaining to Claude repeatedly?

For 2FA, every time you start a session you'd need to tell Claude:

- Use TOTP, not SMS
- Generate backup codes at enrollment
- Follow the enrollment → verification → recovery flow
- Apply security best practices for token validation

That repetition is the signal that a skill would help.

### Step 2: Create the Folder

```
.claude/skills/
└── totp-two-factor-auth/
    └── SKILL.md
```

Folder name is kebab-case, matches the skill name.

### Step 3: Write the Frontmatter

This is what Claude sees at all times. It decides whether to load the full skill based on this alone.

```yaml
---
name: totp-two-factor-auth
description: Implements TOTP-based two-factor authentication with enrollment, verification, and recovery flows. Use when user mentions "2FA", "two-factor", "TOTP", "authenticator app", "MFA", or "backup codes". Do NOT use for OAuth flows, SSO configuration, or password reset.
metadata:
  author: Your Name
  version: 1.0.0
---
```

Notice:

- **Trigger phrases**: "2FA", "two-factor", "TOTP", "authenticator app", "MFA", "backup codes"
- **Negative triggers**: "Do NOT use for OAuth flows, SSO configuration, or password reset" — prevents over-triggering on general auth topics

### Step 4: Write the Instructions

This is what Claude reads when it decides the skill is relevant.

```markdown
---
name: totp-two-factor-auth
description: Implements TOTP-based two-factor authentication with enrollment,
  verification, and recovery flows. Use when user mentions "2FA", "two-factor",
  "TOTP", "authenticator app", "MFA", or "backup codes". Do NOT use for OAuth
  flows, SSO configuration, or password reset.
metadata:
  author: Your Name
  version: 1.0.0
---

# TOTP Two-Factor Authentication

## Core Requirements

- Use TOTP (RFC 6238) with 30-second time steps and 6-digit codes
- Support standard authenticator apps (Google Authenticator, Microsoft Authenticator, Authy)
- Generate 10 single-use backup codes at enrollment
- Never log or expose TOTP secrets in plaintext after initial QR code display

## Enrollment Flow

1. User initiates 2FA setup from account settings
2. Generate a random TOTP secret (minimum 160 bits)
3. Display QR code encoding the otpauth:// URI
4. Display the secret as a manual entry fallback
5. Require user to enter a valid TOTP code to confirm enrollment
6. Generate and display 10 backup codes — instruct user to save them
7. Store the secret (encrypted at rest) and mark 2FA as enabled

CRITICAL: Do not mark 2FA as enabled until the user confirms with a valid code.
This prevents lockout from failed QR scans.

## Verification Flow

1. User completes primary authentication (username + password)
2. Prompt for TOTP code
3. Validate code against the stored secret
4. Accept current time step and one step before/after (clock skew tolerance)
5. On success, complete login
6. On failure, allow retry (max 5 attempts, then temporary lockout)

## Recovery Flow

1. User selects "Can't access authenticator" at TOTP prompt
2. Prompt for a backup code
3. Validate against stored backup codes
4. On success, mark that backup code as used (single-use)
5. Complete login and prompt user to re-enroll or generate new backup codes
6. If no backup codes remain, direct user to contact an administrator

## Admin Capabilities

- Admin can reset a user's 2FA enrollment (removes secret, clears backup codes)
- Admin reset requires the user to re-enroll on next login
- Log all admin 2FA resets for audit trail

## Security Considerations

- Rate-limit TOTP verification attempts (5 per minute per user)
- Store TOTP secrets encrypted, not hashed (they must be readable for validation)
- Backup codes should be hashed (they are compared, not regenerated)
- Never accept a TOTP code that was already used in the current time step (replay prevention)

## Examples

### Example 1: User enrolls in 2FA

User says: "Add two-factor authentication to the user settings page"

Actions:

1. Create enrollment endpoint/page
2. Generate TOTP secret and QR code
3. Build confirmation step requiring a valid code
4. Generate and display backup codes
5. Store encrypted secret and hashed backup codes

Result: User can scan QR code with authenticator app and confirm enrollment.

### Example 2: User logs in with 2FA

User says: "Add the TOTP verification step to the login flow"

Actions:

1. After password verification, redirect to TOTP prompt
2. Validate submitted code against stored secret
3. Handle success, failure, and lockout cases

Result: Login requires both password and TOTP code.

## Troubleshooting

### Error: QR code not scanning

Cause: otpauth:// URI format incorrect
Solution: Verify URI follows format: otpauth://totp/{issuer}:{account}?secret={base32}&issuer={issuer}&digits=6&period=30

### Error: Valid codes rejected

Cause: Server clock drift exceeding tolerance
Solution: Accept codes from time steps T-1, T, and T+1. Verify server NTP sync.

### Error: User locked out after enrollment

Cause: 2FA marked as enabled before user confirmed with a valid code
Solution: Only enable 2FA after successful code verification during enrollment.
```

### Step 5: Test It

In Claude Code, ask questions that should and should not trigger it:

**Should trigger:**

- "Add 2FA to the login flow"
- "Generate backup codes for account recovery"
- "Implement TOTP verification"

**Should NOT trigger:**

- "Set up OAuth with Google"
- "Configure the SSO redirect"
- "Reset password flow"

If it triggers on the wrong things, tighten the description's negative triggers. If it doesn't trigger when it should, add more trigger phrases.

### Step 6: Iterate

After using the skill in a real session:

- Did Claude follow the enrollment flow correctly? If not, make those instructions more explicit.
- Did it miss security considerations? Add them.
- Did it handle edge cases? Add troubleshooting entries.

Skills are living documents. Update them as you learn what Claude gets wrong.

### Key Takeaway

A skill is just **your expertise written down once** so Claude applies it every time. The 2FA skill above captures decisions you'd otherwise repeat in every session: TOTP over SMS, backup codes at enrollment, encrypted secrets, rate limiting. Write it once, Claude follows it always.

## Checklist

### Before You Start

- [ ] Identified 2-3 concrete use cases
- [ ] Planned folder structure

### During Development

- [ ] Folder named in kebab-case
- [ ] SKILL.md file exists (exact spelling)
- [ ] YAML frontmatter has `---` delimiters
- [ ] `name` field: kebab-case, no spaces, no capitals
- [ ] `description` includes WHAT and WHEN
- [ ] No XML tags (`< >`) anywhere
- [ ] Instructions are clear and actionable
- [ ] Error handling included
- [ ] Examples provided

### After Creation

- [ ] Test triggering on obvious tasks
- [ ] Test triggering on paraphrased requests
- [ ] Verify doesn't trigger on unrelated topics
- [ ] Iterate on description based on under/over-triggering
