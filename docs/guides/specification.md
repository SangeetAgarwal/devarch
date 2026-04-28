# The specification.md Convention

## Purpose

`specification.md` is the human-authored directive that tells the LLM what to build for a given feature or task. It captures your intent, constraints, and decisions **before** the LLM generates an implementation plan.

In a typical product org, a PRD sits upstream of the specification — Product writes the PRD to capture intent for human stakeholders, and the specification restates that intent as the LLM-readable directive. The PRD doesn't go away; it feeds the spec. SpecFrame provides a PRD template at `specframe-prd-template.md` and a fillable questionnaire at `specification-questionnaire.md` whose completed form **is** the specification — useful when handing off to non-engineering stakeholders.

This fills a gap in the base SpecFrame workflow: without a specification, the LLM has only the folder name to work from, which is too thin a contract for complex work.

## Where It Lives

```
docs/work/{feature-name}/specification.md
```

Each feature work folder gets its own specification.

## What It Is (and What It Isn't)

| Document                 | Author      | When Written                         | Purpose                                           |
| ------------------------ | ----------- | ------------------------------------ | ------------------------------------------------- |
| `specification.md`       | You (human) | Before work begins                   | Declares intent and constraints                   |
| `implementation-plan.md` | LLM         | After reading specification          | Breaks intent into actionable steps               |
| `README.md`              | You or LLM  | After work is complete               | Retrospective description of what's in the folder |
| ADRs                     | You         | During review of implementation plan | Records decisions and rationale                   |

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
- **Data Model**: Tables, columns, types, constraints. For each column, be explicit about who sets the value:
  - **"Set by client"** — application code provides this value on insert
  - **"Set by database default"** — a DEFAULT clause handles it (e.g., `gen_random_uuid()`, `now()`)
  - **"Checked by RLS"** — Row Level Security validates the value but does not set it. The client must still provide it.
  - **"Set by trigger"** — a database trigger handles it (e.g., `updated_at`)

  > A common mistake: writing "Set by RLS" when you mean "set by client, checked by RLS." RLS only filters and validates — it never populates a field. If the spec says "Set by RLS," the LLM will skip setting the value in code, and the insert will fail. Be precise.

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

## Relationship to Other SpecFrame Components

- **CLAUDE.md** provides "who we are and what this project is" (via SummonAIKit)
- **Skills** provide "how to use our tech stack correctly" (via Context7)
- **PRD** (`specframe-prd-template.md`) captures "what we're building and why" for human stakeholders — sits upstream of the spec
- **specification.md** provides "what I want from this specific feature" — restates the PRD as an LLM-readable directive
- **specification-questionnaire.md** is a fillable form-style alternative whose completed output is the spec — useful when handing off to non-engineering stakeholders
- **implementation-plan.md** provides "how the LLM will build it"
- **Session summaries** provide "where we left off"
- **ADRs** provide "why we decided what we decided"

Each document has a distinct job. The specification is the bridge between human intent and LLM execution.

---

## External Setup

### What It Is

Some steps in your project require manual action outside of Claude Code — creating accounts, configuring third-party services, setting up OAuth providers, copying API keys, running SQL in a dashboard. The LLM can't do these. If they're not called out explicitly, the LLM will build code that depends on services that don't exist yet, and you'll discover it when nothing works.

### Where It Goes

Add an **External Setup** section to your specification listing every manual step, when it needs to happen, and what to do.

```markdown
## External Setup

Steps that require manual action outside of Claude Code.
Complete these before or during the relevant phase.

| Step                       | When              | What to Do                                                      |
| -------------------------- | ----------------- | --------------------------------------------------------------- |
| Create Supabase project    | Before Phase 1    | supabase.com → New Project → copy Project URL and anon key      |
| Configure OAuth providers  | Before Phase 2    | Supabase dashboard → Auth → Providers → enable Google, Facebook |
| Set redirect URLs          | Before Phase 2    | Supabase dashboard → Auth → URL Configuration                   |
| Add API keys to .env.local | Before Phase 1    | Copy Project URL and anon key from Supabase Settings → API      |
| Create database tables     | Before Phase 3    | Supabase SQL Editor → run schema SQL from implementation plan   |
| Set up hosting             | Before deployment | Vercel/Netlify → Import Git Repository → set env vars           |
```

### Why This Matters

The LLM builds code. It doesn't create external accounts, configure dashboards, or provision cloud services. Without this section, the implementation plan treats manual steps as checkboxes it can't actually complete — and blows past them silently. You discover the gap when the app fails to connect.

External Setup makes the human's responsibilities explicit. The LLM builds against services that already exist, not services it assumes someone will set up later.

### Common External Setup Steps

These come up frequently. Check whether your project needs them:

| Category                 | Examples                                                                                            |
| ------------------------ | --------------------------------------------------------------------------------------------------- |
| **Database/Backend**     | Create project (Supabase, Firebase, PlanetScale), run schema SQL, configure RLS                     |
| **Authentication**       | Register OAuth apps (Google, Facebook, GitHub), set client IDs and secrets, configure redirect URLs |
| **API Keys**             | Copy keys to .env.local, set secrets in hosting provider                                            |
| **Hosting**              | Create project (Vercel, Netlify, AWS), configure domain, set environment variables                  |
| **Third-party services** | Email (SendGrid, Resend), storage (S3, Cloudflare R2), monitoring (Sentry)                          |
| **DNS**                  | Point domain to hosting provider, configure SSL                                                     |

---

## Gap Resolution

### What It Is

When the LLM generates an implementation plan from your specification, it will identify gaps — decisions the specification didn't address. These are things like field length limits, pagination strategy, hosting choice, error handling approach, time zone behavior, and other details that only surface when someone (or something) tries to turn intent into a concrete plan.

This is expected and valuable. A specification that covers every detail upfront is unrealistic. The gap identification step is where the LLM earns its keep — it reads your intent and asks the questions you didn't think to answer.

### When It Happens

```
Write specification (human)
    → Generate implementation plan (LLM)
        → LLM surfaces gaps
            → Resolve gaps (human)          ← this step
                → Update specification with decisions (human)
                    → Build
```

Gap resolution happens after the implementation plan is generated and before building starts. It is not optional — unresolved gaps become assumptions the LLM makes silently during implementation.

### How to Do It

1. **Read the gaps section of the implementation plan.** The LLM will typically list them in a table with the gap, its impact, and a recommendation.

2. **For each gap, do one of three things:**
   - **Accept the LLM's recommendation.** If it makes sense, approve it.
   - **Override with your own decision.** If you disagree, state what you want instead.
   - **Defer to a later version.** If it's not relevant to v1, add it to Out of Scope.

3. **Update the specification.** Add every resolved gap to the **Decisions** section of your specification. This is the critical step. If decisions only live in a chat transcript or in the implementation plan's "Decisions Made" section, they will be lost.

### What Goes in the Specification vs. an ADR

Not every gap needs an ADR. Use this rule of thumb:

| Gap Type                         | Where It Goes                        | Example                                                        |
| -------------------------------- | ------------------------------------ | -------------------------------------------------------------- |
| Minor implementation detail      | Specification → Decisions section    | Field length limits, pagination count, inline validation style |
| Technology or framework choice   | Specification → Stack section        | Tailwind CSS, React Hook Form, Vercel                          |
| Significant architectural choice | ADR + reference in specification     | Auth strategy, database design, caching approach               |
| Scope decision                   | Specification → Out of Scope section | "Skip tests for v1", "No offline support"                      |

### Example

**Specification before gap resolution:**

```markdown
## Decisions

1. Welcome back state: Show participant name and entry count after login.
2. Remember last section: Default to last-used section on next visit.
3. Branding: "Mindful Aware by Dr. Vinita Agarwal"
```

**LLM surfaces gaps:**

| Gap                 | Recommendation                                 |
| ------------------- | ---------------------------------------------- |
| Field length limits | 5000 chars for textareas, 200 for text fields  |
| Pagination          | Load more button, 20 entries per page          |
| Hosting             | Vercel — free tier, easy Vite deployment       |
| Testing             | Unit tests for validation, manual E2E for auth |

**Specification after gap resolution:**

```markdown
## Decisions

1. Welcome back state: Show participant name and entry count after login.
2. Remember last section: Default to last-used section on next visit.
3. Branding: "Mindful Aware by Dr. Vinita Agarwal"
4. Field length limits: 5000 characters for textareas, 200 characters for text inputs. _(gap)_
5. Pagination: "Load More" button, 20 entries per page. _(gap)_
6. Hosting: Vercel. _(gap)_
7. Styling: Tailwind CSS. _(gap)_
8. Form library: React Hook Form. _(gap)_
9. Post-save behavior: Toast notification + form reset. Stay on form for fast entry. _(gap)_
10. Time zones: Store local time as entered. Document limitation. _(gap)_
11. Landing page description: "Track your mindfulness practice for class." _(gap)_
12. Entry count display: Combined with breakdown — "12 entries (8 Breath, 4 Life)." _(gap)_
13. Skip tests for v1. _(gap)_
14. Database migrations via Supabase dashboard for v1. _(gap)_
```

The specification now contains every decision — both the ones you made upfront and the ones surfaced during planning. One document, complete record.

### Tagging Gap Decisions

Mark decisions that came from gap resolution with `*(gap)*` at the end. This is lightweight and doesn't affect the spec's usefulness, but over time it reveals patterns — if the same gaps keep surfacing across projects, your specification template is missing sections.

```markdown
## Decisions

1. Welcome back state: Show participant name and entry count after login.
2. Remember last section: Default to last-used section on next visit.
3. Branding: "Mindful Aware by Dr. Vinita Agarwal"
4. Field length limits: 5000 characters for textareas, 200 characters for text inputs. _(gap)_
5. Pagination: "Load More" button, 20 entries per page. _(gap)_
6. Hosting: Vercel. _(gap)_
```

After a few projects, review which decisions keep showing up as gaps. Add those as standard sections in your specification template so they're answered upfront next time.

### Why This Matters

Six months from now, someone looks at the project and asks: "Why Vercel? Why 20 entries per page? Why no tests?" If those decisions are in the specification, the answer is right there. If they're buried in a chat transcript, they're gone.

The specification is the single source of truth. Gap resolution keeps it that way.

### When Gaps Span Phases

The gap resolution above is intra-phase: one gap, one spec, one plan, one resume point. After two or three feature phases ship, a different kind of gap appears — drift across multiple prior specs, where each spec is internally coherent but together they produce an incoherent system. No single spec is wrong; the gap belongs to none of them individually.

This is an inter-phase gap, addressed by a **Gap Sweep**, not by editing one prior spec ad hoc. A Gap Sweep is a deliberate phase whose work is:

- inventory every cross-phase finding from verification, observations, and post-deploy use
- decide each one (resolve in this sweep, defer, or reject as not-a-gap)
- edit the affected prior-phase specs in place, tagged inline with the sweep's phase letter
- generate an implementation plan that sequences the spec edits and any code changes
- execute one step per CLI session, same rhythm as a feature phase

Same gap-resolution discipline. Broader scope. Folder name follows the pattern `v<version>-<trigger>-gap-sweep` (e.g., `v1-2c-gap-sweep`, `v1-pre-launch-gap-sweep`) so the kind and trigger of the phase are visible in the CLAUDE.md phase table.

See `specframe-gap-sweep.md` for the full mechanics and `specframe-gap-sweep-template.md` for the inventory artifact.

---

## Verification

### What It Is

Code is cheap. The LLM generates it in minutes. Verification — knowing the code does what you intended — is expensive. The specification isn't just input to the LLM. It's the acceptance criteria. After the build, the specification becomes the checklist you verify against.

### When It Happens

After the build is complete and before you ship:

```
Specification → Implementation Plan → Build → Verify against specification → Ship
```

### Two Layers of Verification

**Layer 1: Tests**

Tests prove the code works correctly. Focus on logic that can break silently:

| Category       | What to Test                                     | Why                         |
| -------------- | ------------------------------------------------ | --------------------------- |
| Validation     | Range checks, required fields, format rules      | Silent data corruption      |
| Calculations   | Derived values, formatting                       | User sees wrong information |
| Business rules | State transitions, time ordering, access control | Core domain integrity       |
| Auth guards    | Protected routes, session handling               | Security                    |

Tests are living documentation. A new developer reads the test suite and knows what the app does, not just how it's structured.

**Layer 2: Specification Verification**

After tests pass, walk the specification feature by feature and verify the implementation satisfies each requirement. This can be manual (for small apps) or automated (for larger systems):

```markdown
| Spec Requirement                          | Status | Notes                      |
| ----------------------------------------- | ------ | -------------------------- |
| Landing page shows title and subtitle     | ✅     |                            |
| Social login with Google                  | ✅     |                            |
| History shows reverse chronological order | ✅     |                            |
| Edit and delete from detail view          | ✅     |                            |
| Confirm before delete                     | ❌     | Missing — added to backlog |
```

The specification is the source of truth for what "done" means. If it's in the spec and not in the app, it's not done.

### Why This Matters

In a world where code can be recreated instantly, confidence is the bottleneck. Teams that ship fastest aren't generating the most code — they're the ones with specifications they trust and tests that verify them. The specification defines what correct looks like. The tests prove it.
