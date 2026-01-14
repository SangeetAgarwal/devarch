# Architecture Decision Records (ADRs)

A practical guide to documenting design decisions that your future self (and teammates) will thank you for.

## What is an ADR?

An Architecture Decision Record captures a significant design decision along with its context and consequences. It answers the question: **"Why did we do it this way?"**

ADRs are not:
- Design documents (those describe *what*, ADRs explain *why*)
- Meeting notes (those are ephemeral, ADRs are permanent)
- RFCs (those propose changes, ADRs record decisions already made)

## Why Bother?

**Without ADRs:**
- "Why is this code so weird?" → No one remembers
- "Can we change this?" → No one knows if it's load-bearing
- New team member: "This seems wrong" → Repeats a failed approach from 2 years ago

**With ADRs:**
- "Why is this code so weird?" → ADR-023 explains the constraint we were working around
- "Can we change this?" → ADR-023 lists the consequences; we can evaluate if they still apply
- New team member: Reads ADR-023, understands the tradeoff, proposes better solution

## When to Write an ADR

Write an ADR when you're making a decision that:

1. **Affects multiple components** — Not a single function, but system-wide patterns
2. **Is hard to reverse** — Schema changes, API contracts, framework choices
3. **Has tradeoffs** — You chose A over B for reasons that aren't obvious
4. **Will be questioned later** — If you can imagine someone asking "why?", write it down
5. **Involves external dependencies** — Library choices, service integrations

### Examples of ADR-Worthy Decisions

| Decision | Why It Needs an ADR |
|----------|---------------------|
| "Use PostgreSQL instead of MongoDB" | Affects all data access, hard to reverse |
| "Store prices in cents, not dollars" | Non-obvious, affects calculations everywhere |
| "Use JWT instead of sessions" | Security implications, architectural impact |
| "Single-table DynamoDB design" | Unusual pattern, needs explanation |
| "Monorepo instead of multiple repos" | Affects CI/CD, developer workflow |
| "No ORM, raw SQL only" | Controversial, needs justification |

### Examples That Don't Need ADRs

| Decision | Why Not |
|----------|---------|
| "Use camelCase for variables" | Style guide, not architecture |
| "Put tests in `__tests__` folder" | Convention, easily changed |
| "Use Prettier for formatting" | Tooling, not design |

## ADR Template

```markdown
# ADR-XXX: Title

## Status

Proposed | Accepted | Deprecated | Superseded by ADR-YYY

## Date

YYYY-MM-DD

## Context

What is the issue that we're seeing that is motivating this decision or change?

Describe:
- The problem or requirement
- Relevant constraints (technical, business, timeline)
- Forces at play (performance, maintainability, cost)

## Decision

What is the change that we're proposing and/or doing?

State the decision clearly and directly:
- "We will use X"
- "We will not do Y"
- "All Z must follow pattern W"

## Consequences

What becomes easier or more difficult to do because of this change?

### Positive
- Benefit 1
- Benefit 2

### Negative
- Drawback 1
- Drawback 2

### Neutral
- Side effect that's neither good nor bad

## Alternatives Considered

What other options did we evaluate?

### Option A: [Name]
- Pros: ...
- Cons: ...
- Why rejected: ...

### Option B: [Name]
- Pros: ...
- Cons: ...
- Why rejected: ...
```

## Real Examples

### Example 1: Database Choice

```markdown
# ADR-001: Use PostgreSQL for Primary Database

## Status
Accepted

## Date
2025-01-15

## Context

We need a database for our new application. Requirements:
- Strong consistency for financial transactions
- Complex queries with joins
- ACID compliance
- Team familiarity

We're a small team (3 developers) with PostgreSQL experience.
Expected data volume: ~10GB in year 1, ~100GB by year 3.

## Decision

We will use PostgreSQL as our primary database.

We will use Prisma as our ORM for type-safe database access.

## Consequences

### Positive
- Team already knows PostgreSQL; no learning curve
- Excellent tooling (pgAdmin, psql, etc.)
- Strong ecosystem for backups, replication
- Prisma provides type safety and migrations

### Negative
- Vertical scaling limits (acceptable for our scale)
- Self-managed or managed service cost
- Schema migrations require careful planning

### Neutral
- Need to set up connection pooling for serverless

## Alternatives Considered

### MongoDB
- Pros: Flexible schema, easy horizontal scaling
- Cons: Eventual consistency issues for financial data, team unfamiliar
- Rejected: Consistency requirements outweigh flexibility benefits

### DynamoDB
- Pros: Serverless, auto-scaling, AWS-native
- Cons: Complex query patterns, learning curve for single-table design
- Rejected: Our query patterns are relational; DynamoDB would require denormalization
```

### Example 2: API Design

```markdown
# ADR-007: Store Monetary Values as Integers (Cents)

## Status
Accepted

## Date
2025-02-01

## Context

We're building a financial application that handles money.
Floating-point arithmetic causes precision errors:

```javascript
0.1 + 0.2 === 0.30000000000000004  // true, but wrong
```

We need a representation that:
- Avoids floating-point errors
- Works across languages (JS, Python, database)
- Is simple to understand and debug

## Decision

We will store all monetary values as integers representing cents.

- $10.00 → 1000
- $0.01 → 1
- $123.45 → 12345

Display formatting happens only at the UI layer.

All APIs accept and return cents as integers.

## Consequences

### Positive
- No floating-point precision issues
- Integer arithmetic is exact
- Easy to validate (must be positive integer)
- Consistent across all languages and storage

### Negative
- Must remember to convert for display
- Off-by-100x bugs if someone forgets the format
- Need helper functions for formatting

### Neutral
- Database column type: INTEGER or BIGINT (not DECIMAL)

## Alternatives Considered

### Use Decimal/Numeric Types
- Pros: More intuitive, database handles precision
- Cons: JavaScript has no native Decimal; serialization is inconsistent
- Rejected: Cross-language consistency is more important

### Use String Representation
- Pros: Exact representation, no precision loss
- Cons: Can't do arithmetic without parsing, validation is harder
- Rejected: Too cumbersome for calculations
```

### Example 3: Deprecating a Decision

```markdown
# ADR-012: Use REST API for All Endpoints

## Status
Superseded by ADR-034

## Date
2025-03-15

## Context

We needed to choose an API style for our backend.

## Decision

We will use REST for all API endpoints.

## Consequences

[Original consequences here]

---

**Update 2025-08-01:** This ADR has been superseded by ADR-034.

We found that:
1. Real-time features required WebSockets anyway
2. Mobile clients needed to batch requests (REST was chatty)
3. GraphQL solved both problems

See ADR-034 for the migration plan to GraphQL.
```

## Organizing ADRs

### File Structure

```
docs/
└── architecture/
    └── adrs/
        ├── README.md           # Index of all ADRs
        ├── adr-001-database.md
        ├── adr-002-api-style.md
        ├── adr-003-auth.md
        └── ...
```

### Numbering

Use sequential numbers: ADR-001, ADR-002, etc.

- **Don't reuse numbers** — Even if an ADR is deprecated, keep its number
- **Don't renumber** — References to "ADR-023" should always mean the same thing
- **Gaps are okay** — If ADR-015 was never written, skip to ADR-016

### Index File (README.md)

Maintain an index for discoverability:

```markdown
# Architecture Decision Records

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [001](adr-001-database.md) | Use PostgreSQL | Accepted | 2025-01-15 |
| [002](adr-002-api-style.md) | REST API Style | Superseded | 2025-03-15 |
| [003](adr-003-auth.md) | JWT Authentication | Accepted | 2025-04-01 |

## By Category

### Data Storage
- ADR-001: PostgreSQL
- ADR-008: Redis for Caching
- ADR-015: S3 for File Storage

### API Design
- ADR-002: REST API (superseded)
- ADR-034: GraphQL Migration

### Security
- ADR-003: JWT Authentication
- ADR-019: Rate Limiting Strategy
```

## ADR Workflow

### 1. Propose

When facing a significant decision:

1. Create a new ADR file with status "Proposed"
2. Fill in Context and Alternatives
3. Draft your recommended Decision
4. Share with team for feedback

### 2. Discuss

- Review in PR, Slack, or meeting
- Update Alternatives based on feedback
- Refine Consequences section

### 3. Accept

- Change status to "Accepted"
- Merge the ADR
- Reference in implementation PRs: "Implements ADR-023"

### 4. Revisit (When Necessary)

When circumstances change:

- **If decision still holds:** Add a note confirming it's still valid
- **If decision needs updating:** Create new ADR that supersedes the old one
- **Never delete ADRs** — They're historical records

## Tips for Good ADRs

### Do

- **Write them before or during implementation** — Not months later
- **Be specific** — "Use PostgreSQL 15" not "use a relational database"
- **Include the date** — Context changes over time
- **Link to relevant resources** — Benchmarks, blog posts, documentation
- **Capture the alternatives** — Future you will wonder "why not X?"

### Don't

- **Don't be too verbose** — 1-2 pages is ideal
- **Don't include implementation details** — That's for code/docs
- **Don't require consensus** — ADRs record decisions, not debates
- **Don't skip the consequences** — This is the most valuable section
- **Don't wait for perfection** — A rough ADR beats no ADR

## Working with Claude

Claude can help you write ADRs:

**Drafting:**
> "Help me write an ADR for choosing between WebSockets and Server-Sent Events for real-time updates. Our requirements are: [list requirements]. We're leaning toward SSE because [reasons]."

**Reviewing:**
> "Review this ADR draft. Does it clearly explain the decision? Are there alternatives I'm missing? Is the consequences section complete?"

**Finding decisions:**
> "Based on these requirements [list them], what are the main architectural options? What are the tradeoffs of each?"

**Retrospective:**
> "We chose X six months ago. Here's what we've learned [describe experience]. Should we write a new ADR to supersede the original decision?"

## Quick Reference

### When to Write
- Choosing technologies (database, framework, language)
- Defining patterns (API style, error handling, logging)
- Making tradeoffs (performance vs. simplicity)
- Setting constraints (no ORM, microservices, etc.)

### Minimum Viable ADR
```markdown
# ADR-XXX: [Title]

## Status
Accepted

## Context
[2-3 sentences on the problem]

## Decision
[1-2 sentences on what we're doing]

## Consequences
[3-5 bullet points on impact]
```

### Status Values
- **Proposed** — Under discussion
- **Accepted** — Decision made, implementing
- **Deprecated** — No longer relevant (but kept for history)
- **Superseded** — Replaced by a newer ADR

---

*ADRs are cheap to write and expensive to not have. When in doubt, write one.*
