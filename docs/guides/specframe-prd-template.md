# Product Requirements Document Template (SpecFrame Variant)

For Product to articulate what we're building and why, before engineering produces the SpecFrame specification.

A PRD captures product intent for human stakeholders. It's written in product language. The conventional requirements process doesn't change in agentic development — a well-written PRD still does the work, regardless of whether the downstream implementation is human-driven or LLM-driven. The PRD remains; the SpecFrame specification is what's added downstream as the LLM-readable directive.

This template is fillable. Italics under each section are examples to prompt the right shape of answer; replace them with your own content.

---

## Header

- **Feature / Capability name**:
- **Author**:
- **Date**:
- **Status**: _(Draft | In Review | Approved | Implementing | Shipped)_
- **Stakeholders**: _(product, engineering, design, business)_
- **Related event-storming output**: _(if applicable)_

---

## 1. Problem & Opportunity

> What user or business problem are we solving? Why now?
>
> _Example: "External users complain that our platform doesn't meet their organization's security requirements, and we have a SOC 2 audit in Q3 that requires multi-factor authentication for all external access."_

**Your answer:**

---

## 2. Background & Context

> What's changed that makes this important now? What's the history? What have we learned?
>
> _Example: "We deferred 2FA in the v1 launch because we prioritized time-to-market. Three of our top 10 customers have raised this in QBRs, and our SOC 2 auditor flagged it as a Q3 finding. Internal users already have SSO; this is specifically about external users."_

**Your answer:**

---

## 3. Target Users / Personas

> Who is affected? Be specific — roles, segments, geographies if relevant.
>
> _Example:_
>
> - _External users (clinicians and admins at customer organizations)_
> - _Customer admins who manage their org's users_
> - _Our internal support team who'll handle 2FA-related support tickets_

**Your answer:**

---

## 4. Goals & Success Metrics

> What does success look like, measurably? What will we track?
>
> _Example:_
>
> - _95% of active external users enrolled within 60 days of rollout_
> - _Less than 2% increase in support tickets attributable to 2FA in the first month_
> - _Clean SOC 2 audit finding closure_

**Your answer:**

---

## 5. Non-Goals

> What we are explicitly NOT solving in this iteration? (This becomes the spec's "Out of Scope.")
>
> _Example:_
>
> - _SMS-based OTP_
> - _Internal user 2FA (already handled by SSO)_
> - _Hardware security keys_
> - _Self-service admin tooling beyond simple reset_

**Your answer:**

---

## 6. User Stories / Scenarios

> What are users actually trying to do? Frame as scenarios, not screens.
>
> _Example:_
>
> - _"As an external user, I enroll my authenticator app at first login after the grace period starts."_
> - _"As an external user who lost my phone, I can recover access using a backup code."_
> - _"As a customer admin, I can reset 2FA for a user in my org who's locked out."_

**Your answer:**

---

## 7. Functional Requirements

> What must the feature do? High-level — engineering will translate to specific behaviors.
>
> _Example:_
>
> - _Enrollment flow using TOTP authenticator apps_
> - _Verification at login after password_
> - _Recovery via backup codes_
> - _Admin reset capability for customer admins_

**Your answer:**

---

## 8. Non-Functional Requirements / Constraints

> What are the non-negotiables? Compliance, performance, accessibility, security, integration with existing systems.
>
> _Example:_
>
> - _Must integrate with existing identity server (no new auth backend)_
> - _Must comply with SOC 2 Type II controls_
> - _Recovery must NOT bypass 2FA_
> - _Must be accessible (WCAG 2.1 AA)_

**Your answer:**

---

## 9. Dependencies & Risks

> What does this depend on? What could go wrong?
>
> _Example:_
>
> - _Dependency: identity server team needs to deploy v2.4 first (in flight, ETA 2 weeks)_
> - _Risk: backup-code recovery flow is the lowest-friction abuse vector — needs careful rate limiting_
> - _Risk: rollout during compliance audit window — coordinate with security team_

**Your answer:**

---

## 10. Open Questions

> What are we still figuring out? These are the questions we need answers to before engineering can spec confidently.
>
> _Example:_
>
> - _Do we enforce 2FA before the 30-day grace period for new signups?_
> - _What's the policy for users whose org doesn't allow personal device use?_
> - _Do we want an opt-out path for low-risk roles, or universal enforcement?_

**Your answer:**

---

## 11. Stakeholders & Approvals

> Who needs to sign off before we start building?
>
> _Example:_
>
> - _Product: [name]_
> - _Engineering lead: [name]_
> - _Security: [name]_
> - _Design: [name]_
> - _Compliance: [name]_

**Your answer:**

---

## Handoff to Engineering

When this PRD is approved, engineering will produce the specification using `specification-questionnaire.md` (or `specification.md` directly). The spec restates this PRD as an LLM-readable directive — same intent, additional rigor (Out of Scope, External Setup, decisions tagged with provenance, data-model precision about who sets each field).

The PRD remains the source of product intent. The spec is the directive engineering hands to the LLM. Both stay in the artifact set; neither replaces the other.

---

## See Also

- `specframe-for-product.md` — broader Product-facing context: where the PRD sits relative to the spec and event storming
- `specification-questionnaire.md` — the questionnaire engineering fills out (after the PRD) to produce the spec
- `specification.md` — the underlying spec convention with worked TOTP example
- `specframe-philosophy.md` — why specifications carry additional rigor in agentic development
