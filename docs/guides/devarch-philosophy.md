# DevArch Philosophy: Specification-Driven Development in the Agentic Era

## The Shift

For decades, the developer was the bottleneck. Code took time to write, so every methodology optimized for the human at the keyboard. TDD said: write the test first, because it forces you to think about behavior before implementation. The test was the design step. The code followed.

That made sense when humans wrote the code.

In agentic development, the LLM writes the code. It generates implementation in minutes — sometimes seconds. The human no longer needs a forcing function to think before coding, because the human isn't coding. The human is specifying.

The bottleneck has moved. Code is cheap. Confidence that the code does what you intended is expensive.

## Why Specifications Replace TDD's Forcing Function

TDD's core insight was never about tests. It was about design. Writing a test first forces you to answer: What should this do? What are the inputs? What are the valid outputs? What are the edge cases? You can't write a test without answering those questions.

A specification answers the same questions — at a higher level. Field-level validation rules, data model constraints, security policies, business rules, edge cases, explicit scope boundaries. Everything a test forces you to think about, the specification captures before the LLM generates a single line of code.

The difference:

|                       | TDD                             | Specification-Driven                              |
| --------------------- | ------------------------------- | ------------------------------------------------- |
| **Design happens at** | Test level (function/method)    | Specification level (feature/system)              |
| **Who implements**    | Human writes code to pass tests | LLM implements from specification                 |
| **Tests are**         | The design step                 | The verification step                             |
| **Entry point**       | Test → Code → Refactor          | Spec → Plan → Build → Test → Verify               |
| **Feedback loop**     | Red → Green → Refactor          | Spec → Build → Test → Gap → Update Spec → Re-test |

Both approaches converge on verified, correct code. They enter the loop at different points.

## The DevArch Flow

```
Domain Discovery → Specification → Implementation Plan → Gap Resolution
    → Refined Specification → Build → Tests → Specification Verification → Ship
```

Each step has a purpose:

**Domain Discovery** (optional — for complex domains)

Event storming and domain modeling surface the business language, boundaries, invariants, and policies before any technical decisions are made. For simple CRUD apps, skip this. For complex domains with multiple actors, bounded contexts, and intricate business rules, this is where you prevent the most expensive mistakes.

**Specification**

The human captures intent, constraints, decisions, and scope. Field-level detail. Validation rules. Data model with ownership (what sets each field — client, database default, trigger, checked by security policy). External setup steps. Explicit out of scope. This is the design step. Everything the LLM needs to generate precise code rather than generic code.

**Implementation Plan**

The LLM reads the specification and generates a phased plan. This is where gaps surface — decisions the specification didn't address.

**Gap Resolution**

The human reviews gaps, makes decisions, and updates the specification. Every decision is tagged _(gap)_ so you can track what was upfront vs surfaced during planning. Over time, the pattern of gaps reveals missing sections in your specification template.

**Refined Specification**

The specification is now complete — all decisions made, all gaps resolved. It becomes the acceptance criteria for the build.

**Build**

The LLM implements from the refined specification. The human reviews, directs, and makes architectural decisions the LLM can't make on its own. CLAUDE.md rules catch known problems (verify files after scaffolding, surface external setup steps, stop on ambiguity).

**Tests**

Three layers, each catching different classes of bugs:

- **Unit and integration tests** verify application logic with mocked external services. The app sends the right calls.
- **E2E data layer tests** verify real database constraints, security policies, triggers, and data shapes. The infrastructure enforces the rules.
- **Specification verification** walks the original spec feature by feature. The app does what was intended.

**Ship**

When all three layers pass, you have confidence. Not hope — confidence. The spec defined what correct looks like. The tests proved it. The E2E tests proved the infrastructure enforces it.

## Why Tests Come After the Build

TDD purists will object. Tests should come first. You're doing it backwards.

Here's why the objection doesn't apply:

**In TDD, the test is the only design artifact.** Without the test, the developer has no formal statement of what the code should do. The test forces design thinking. Remove it and you get cowboy coding.

**In DevArch, the specification is the design artifact.** The human has already done the design thinking — in the spec. Validation rules are explicit. Data constraints are explicit. Security policies are explicit. Edge cases are explicit. The LLM reads the spec and implements. The spec did what the test does in TDD: force the human to think before code exists.

Writing tests before the build in agentic development means writing tests against code that doesn't exist yet, in a codebase the LLM hasn't scaffolded yet, with component structures the LLM hasn't decided yet. You'd be guessing at implementation details. That's the opposite of what TDD intended.

Instead:

1. Specification captures design intent (replaces TDD's forcing function)
2. LLM implements from specification
3. Tests verify the implementation matches the specification
4. Failures feed back into the specification (same loop as TDD, different entry point)

The feedback loop is intact. The entry point shifted from test to specification. The forcing function shifted from code-level tests to system-level specifications.

## Why This Works with DDD and Event Storming

Domain-Driven Design and event storming are inherently specification-level activities. You're not designing tests — you're discovering domains, boundaries, invariants, and policies. These naturally produce specifications, not test cases.

The flow from event storm to specification to implementation to tests is the natural order when the domain is complex:

1. **Event storm** — discover what happens in the domain (domain events, commands, actors, policies)
2. **Domain model** — structure what you discovered (aggregates, bounded contexts, value objects, invariants)
3. **Specification** — scope what to build (which slice of the domain, which features, which constraints)
4. **Build** — LLM implements the scoped slice
5. **Test** — verify the implementation honors the domain model and specification

Tests at the end verify that the domain's invariants are enforced, not that you thought about them. You thought about them during the event storm and captured them in the specification. Tests confirm the LLM respected what you specified.

## The Self-Improving Loop

Every project reveals gaps in the methodology:

| Problem Encountered                                               | Convention Added                                       |
| ----------------------------------------------------------------- | ------------------------------------------------------ |
| LLM said "feature complete" without configuring external services | External Setup convention + CLAUDE.md completion rules |
| Gap decisions lost in chat history                                | Gap Resolution convention with _(gap)_ tags            |
| Config files lost during scaffolding                              | CLAUDE.md rule: verify files after operations          |
| "Set by RLS" misread — LLM skipped setting user_id                | Field ownership guidance in specification              |
| Feature added without updating spec                               | CLAUDE.md rule: update spec before/alongside code      |
| Mocked tests passed but database rejected inserts                 | E2E data layer testing convention                      |

Each convention prevents a class of problems across all future projects. The specification template grows. The CLAUDE.md rules accumulate. The methodology improves with every build.

This is not self-healing. DevArch doesn't catch problems at runtime. It prevents problems you've seen before through accumulated conventions. Institutional memory, encoded in documents, enforced by LLM rules.

## What DevArch Is Not

**Not TDD.** Tests verify — they don't drive design. The specification drives design.

**Not agent-driven governance.** No autonomous agents auditing your code. Structured documents keep the human in the governance seat. The LLM implements, the human governs.

**Not framework-specific.** The methodology works with React, ASP.NET, Python, or anything else. Specifications, gap resolution, external setup, and verification are universal.

**Not a replacement for domain expertise.** The LLM can generate code, but it can't decide where bounded context boundaries go, what invariants matter, or what security policies to enforce. Those decisions require someone who understands the domain. DevArch is a workflow for capturing and transmitting that expertise to the LLM.

## The Core Claim

In agentic development, the specification is the highest-leverage artifact. It is simultaneously:

- **Input** — the LLM reads it to generate implementation
- **Design** — the human captures intent, constraints, and decisions before code exists
- **Acceptance criteria** — after the build, the spec defines what "done" means
- **Living documentation** — gap resolution and spec-sync keep it current as the project evolves

Everything else — implementation plans, CLAUDE.md rules, tests, verification checklists — serves the specification. The specification is the single source of truth. The methodology exists to keep it that way.
