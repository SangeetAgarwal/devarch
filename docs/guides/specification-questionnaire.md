# Feature Specification Questionnaire

For Product or Business stakeholders to articulate a capability or feature for AI-assisted implementation.

Fill in each section. The completed document **is** the specification — engineering will use it to generate an implementation plan with the LLM. Italics under each question are examples to prompt the right shape of answer; replace them with your own content.

If you're stuck on a question, write what you know and tag it `_(needs decision)_`. Don't leave fields blank — engineering needs to distinguish "intentionally undecided" from "accidentally missing."

---

## Header

- **Feature name**:
- **Author**:
- **Date**:
- **Source PRD** (link or reference):
- **Related event-storming output** (if applicable):

---

## 1. Objective — What and Why (REQUIRED)

> In one or two sentences: What does this feature do, and why does it exist?
>
> _Example: "Allow external users to enroll in TOTP-based two-factor authentication so we meet the security commitments in the upcoming compliance review."_

**Your answer:**

---

## 2. Scope — What's Included (REQUIRED)

> What is part of this feature? List the user-visible behaviors, the surfaces it touches, and the workflows it covers.
>
> _Example:_
>
> - _TOTP enrollment flow_
> - _TOTP verification on login_
> - _Backup-code recovery flow_
> - _External users only (not internal staff)_

**Your answer:**

---

## 3. Out of Scope — What's Explicitly Excluded (REQUIRED)

> What might someone reasonably _expect_ this feature to include — but that we are deliberately NOT building right now?
>
> This is the most important section for AI-assisted implementation. Without it, the LLM drifts into related-but-uncommitted work.
>
> _Example:_
>
> - _SMS-based OTP (deferred to v2)_
> - _Internal user 2FA_
> - _Hardware security keys_
> - _Admin override workflows beyond simple reset_

**Your answer:**

---

## 4. Constraints — What Can't Be Negotiated (REQUIRED)

> What requirements are non-negotiable? Stack choices, compliance rules, performance targets, security policies, accessibility requirements.
>
> _Example:_
>
> - _Must integrate with the existing identity server_
> - _Must comply with SOC 2 Type II controls_
> - _Recovery flow must NOT bypass 2FA — backup codes only_
> - _Must work without JavaScript (progressive enhancement)_

**Your answer:**

---

## 5. Key Decisions Already Made (REQUIRED)

> What decisions have you already made that the LLM (or engineering) should not second-guess? Include the rationale where it's not obvious — future readers six months from now will thank you.
>
> _Example:_
>
> - _TOTP over email OTP — authenticator apps are more secure and don't depend on email availability_
> - _Mandatory, not opt-in — all external users must enroll after a 30-day grace period_
> - _10 backup codes generated at enrollment_

**Your answer:**

---

## 6. Acceptance Criteria — How We Know It's Done (REQUIRED)

> What must be true for this feature to be considered complete? Write these as observable behaviors, not internal mechanics.
>
> _Example:_
>
> - _External user can enroll using any standard TOTP authenticator app (Google, Microsoft, Authy)_
> - _Login requires a valid TOTP code after password_
> - _User can recover access using backup codes_
> - _Admin can reset 2FA enrollment for a specific user_

**Your answer:**

---

## 7. User Roles / Actors (OPTIONAL — recommended for non-trivial features)

> Who interacts with this feature, and what can each role do?
>
> _Example:_
>
> - _External User: enrolls, verifies on login, regenerates backup codes_
> - _Admin: resets a user's 2FA enrollment if they lose access_

**Your answer:**

---

## 8. Business Rules (OPTIONAL — recommended)

> What specific logic must the implementation follow? State transitions, time-based behaviors, access control rules, calculation rules.
>
> _Example:_
>
> - _Backup code is single-use — must be invalidated after consumption_
> - _TOTP window: 30-second drift tolerance allowed_
> - _After 5 failed verifications, lock the session for 15 minutes_

**Your answer:**

---

## 9. Data Model (OPTIONAL — required if the feature persists data)

> For each field this feature touches, **who sets the value?** Be precise — this is one of the most common sources of silent bugs in AI-assisted implementation.
>
> Categories:
>
> - **Set by client** — application code provides this on insert
> - **Set by DB default** — a DEFAULT clause handles it (e.g., `gen_random_uuid()`, `now()`)
> - **Checked by RLS** — Row Level Security validates the value but does NOT set it; the client must still provide it
> - **Set by trigger** — a database trigger handles it (e.g., `updated_at`)
>
> A common mistake is writing "Set by RLS" when you mean "set by client, checked by RLS." RLS only filters and validates — it never populates a field. If the spec says "Set by RLS," the LLM will skip setting the value in code, and the insert will fail.
>
> _Example:_
>
> - _user_id (uuid, set by client)_
> - _enrolled_at (timestamp, set by DB default = now())_
> - _backup_codes (jsonb array, set by client at enrollment)_
> - _updated_at (timestamp, set by trigger)_

**Your answer:**

---

## 10. Dependencies (OPTIONAL)

> What other systems, services, or features does this depend on?
>
> _Example:_
>
> - _Existing identity server (auth.example.com)_
> - _Email service for backup-code delivery_
> - _Audit logging service_

**Your answer:**

---

## 11. External Setup (OPTIONAL — required if any manual prerequisites exist)

> What needs to be done **outside of code** before this feature can work? Account creation, OAuth configuration, API keys, DNS, third-party integrations. The LLM cannot perform these steps; if they're missing, the build will silently fail.

| Step | When | What to do |
| ---- | ---- | ---------- |
|      |      |            |
|      |      |            |

---

## 12. Notes / Additional Context (OPTIONAL)

> Anything else engineering should know that doesn't fit the structured sections — historical context, prior attempts, related work, organizational constraints, stakeholder politics that affect the work.

**Your answer:**

---

## Submission

When this is filled in, hand it to engineering. Engineering will:

1. Convert it to the canonical `specification.md` format (section names match this questionnaire)
2. Generate an implementation plan with the LLM
3. Surface **gaps** — decisions that weren't explicit in your answers (field length limits, pagination strategy, error-handling style, time-zone behavior, etc.)
4. Loop back to Product for gap resolution
5. Implement against the resolved spec

**Expect gaps.** They're a feature of the process, not a bug. Every gap surfaces at _planning time_ — before code is written — which is the cheapest place to resolve them. A specification that closes every detail upfront is unrealistic; the LLM's job is to ask the questions you didn't think to answer.

---

## See Also

- `specframe-prd-template.md` — fillable PRD template; the PRD is upstream of this questionnaire
- `specification.md` — the underlying convention this questionnaire produces, with a complete TOTP worked example
- `specframe-for-product.md` — broader Product-facing context: where the spec sits relative to the PRD and event storming
- `specframe-philosophy.md` — why specifications carry this rigor in agentic development
