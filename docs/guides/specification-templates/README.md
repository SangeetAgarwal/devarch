# DDD Specification Templates for DevArch

These templates capture Domain-Driven Design constructs in a format optimized for agentic development. The DDD vocabulary is used directly — not taught — because the agent already understands aggregate roots, bounded contexts, invariants, domain events, and anticorruption layers. Every DDD term in the specification acts as a compressed implementation instruction.

## Two Approaches

### Approach 1: Single Specification

One `specification.md` at the project root contains the complete domain model — all bounded contexts, all aggregates, the full context map, all domain events.

```
your-project/
├── docs/
│   ├── specification.md          ← complete domain model
│   ├── context/
│   │   └── session-*.md
│   └── architecture/
│       └── adrs/
```

**Use when:**

- Small to medium projects with 1-2 bounded contexts
- Single developer or single agent working on the project
- Domain complexity is manageable in one document
- No need for parallel feature development

**Tradeoffs:** Faster to set up, fewer files to maintain, no extraction step. The agent reads the entire domain model on every task. This works until the domain grows large enough that the agent starts making mistakes at the boundaries — mixing up ubiquitous language between contexts, drifting into out-of-scope aggregates, or losing precision on cross-context contracts. When something breaks in production, you trace through the entire domain model to find the relevant rules.

**Example:** `examples/single-spec/specification.md`

### Approach 2: Master + Feature Specifications

A master `specification.md` contains the complete domain model. Each feature work folder contains its own `specification.md` extracted from the master — scoped to the relevant bounded context, aggregate, and behaviors for that unit of work.

The master and feature specs are identical in structure. The feature spec is a slice of the master, not a different format. It includes only the aggregates, invariants, events, and ACLs relevant to that feature, with explicit in-scope and out-of-scope markers.

```
your-project/
├── docs/
│   ├── specification.md          ← master (complete domain model)
│   ├── context/
│   │   └── session-*.md
│   ├── architecture/
│   │   └── adrs/
│   └── work/
│       ├── feature-sprint-management/
│       │   └── specification.md  ← extracted from master
│       ├── feature-backlog-management/
│       │   └── specification.md  ← extracted from master
│       └── feature-discussion-integration/
│           └── specification.md  ← extracted, cross-context
```

**Use when:**

- Complex projects with 3+ bounded contexts
- Multiple developers or agents working in parallel
- Features span different bounded contexts
- Cross-context integrations need explicit scoping
- Debugging and maintenance benefit from traceable specs

**Tradeoffs:** The agent's job is smaller on each task. It reads only the slice relevant to its current work, not the entire domain. This produces more accurate implementation — the agent is less likely to drift into out-of-scope aggregates or confuse ubiquitous language across contexts. The out-of-scope markers act as guardrails.

The bigger payoff comes in production. When something breaks, the feature spec tells you exactly which aggregate, which invariants, and which cross-context contracts were in play. You don't search the entire domain model — you open the feature spec that built the failing code and the answer is scoped right there.

The cost is human time. Extraction is manual work that forces you to make scope decisions, identify cross-context dependencies, and think about boundaries before the agent starts coding. You also maintain more files, and the master must stay in sync with feature specs as the domain evolves. This overhead is the investment; the accuracy and debuggability are the return.

**Example:** `examples/multi-spec/`

### Workflow for Multi-Spec Approach

1. Maintain the master spec through domain modeling sessions (Event Storming, domain expert conversations)
2. When starting a new feature, extract the relevant slice into the work folder's specification.md
3. The agent reads the feature spec and generates an implementation plan, surfacing gaps
4. Gaps are written into the feature spec first, then resolved by the human — same gap resolution flow as any DevArch specification
5. The agent implements within the scoped feature spec
6. Discoveries or refinements during implementation get folded back into the master spec
7. Session summaries reference DDD terms from the feature spec

The extraction step is human work. It forces decisions about scope, boundaries, and cross-context dependencies before the agent starts coding.

## Template Files

- `specification-template.md` — blank template for the master specification (works for both approaches)
- `feature-specification-template.md` — blank template for feature-level specifications (multi-spec approach only)

## Specification Structure

The template follows DDD's dependency order. Each section builds on what came before:

```
1. Problem Space          ← Subdomains (what the business does)
2. Solution Space         ← Bounded Contexts, Aggregates, Invariants
3. Context Map            ← Relationships between contexts
4. Domain Events          ← Facts published by aggregates
5. Anticorruption Layers  ← Translation between contexts
6. Event Infrastructure   ← Technical delivery mechanism
7. Gap Analysis           ← What we don't know yet
8. Implementation Phases  ← Delivery order
```

Each section depends on the ones above it. Domain Events can't be defined without aggregates. The Context Map can't be drawn without Bounded Contexts. Aggregates can't be designed without understanding the Subdomains.

## Case Study: Scrum Project Management Software (from Vernon's _DDD Distilled_)

The examples are based on the Scrum project management application from Vaughn Vernon's _Domain-Driven Design Distilled_ (Addison-Wesley, 2016). Vernon uses this platform as a running example throughout the book to illustrate strategic and tactical DDD patterns across multiple Bounded Contexts.

The domain model — Product, BacklogItem, Sprint, Discussion, and the three Bounded Contexts (Agile PM, Collaboration, Identity & Access) — originates from Vernon's work. The specification format, DevArch integration, feature-level extraction pattern, and agentic development workflow are original contributions.

We chose this example for these templates because:

- **Recognized domain.** Anyone studying DDD encounters this example. It provides a familiar reference point for understanding how the specification template maps to DDD concepts.
- **Multi-context complexity.** Three Bounded Contexts with distinct Ubiquitous Languages, cross-context identity translation (User vs TeamMember vs Participant), Domain Events cascading between contexts, and ACL translations — the same patterns found in real enterprise systems.
- **Learning bridge.** Developers reading Vernon's book can see how the concepts they're learning translate directly into actionable specifications that agents consume.

For deeper treatment of the patterns demonstrated here, see:

- _Domain-Driven Design Distilled_ by Vaughn Vernon (Addison-Wesley, 2016) — the source material
- _Implementing Domain-Driven Design_ by Vaughn Vernon (Addison-Wesley, 2013) — comprehensive implementation guidance
- _Domain-Driven Design: Tackling Complexity in the Heart of Software_ by Eric Evans (Addison-Wesley, 2003) — the foundational text

## Key Principles

**Use DDD vocabulary, don't teach it.** The agent knows what an aggregate root is. Just say `Root: Product` and list its behaviors and invariants. No explanatory paragraphs.

**Every field is a design decision.** Nothing in the template is filler. When you write an invariant, you're deciding what rule the aggregate enforces. When you mark something as a value object, you're deciding it's immutable with no identity. When you list a subscriber, you're defining a cross-context contract.

**Feature specs reference the master, never redefine.** If the Ubiquitous Language evolves, update the master first, then update affected feature specs. The master is the authority.

**Gap analysis is as important as the model.** Explicitly documenting what you don't know prevents the agent from improvising on unresolved decisions. An unanswered question in the gap analysis is safer than a wrong assumption in the code.

## DDD Vocabulary Reference (for spec authors, not agents)

When filling in the template, these terms are your toolkit:

| Term                | What it means in the spec                                                   |
| ------------------- | --------------------------------------------------------------------------- |
| **Aggregate Root**  | Single entry point. All operations go through it. Loads and saves as unit.  |
| **Entity**          | Has unique identity. Tracked over time. Mutable through controlled methods. |
| **Value Object**    | No identity. Immutable. Defined by attributes. Replace, don't update.       |
| **Invariant**       | Business rule always enforced by the aggregate. Never bypassed.             |
| **Domain Event**    | Past-tense fact. Something that already happened. Published by aggregate.   |
| **Bounded Context** | One model, one language. Everything inside shares vocabulary.               |
| **ACL**             | Translation layer protecting one context's language from another's.         |
| **Port**            | Interface defining what the domain needs (outbound) or exposes (inbound).   |
| **Adapter**         | Concrete implementation of a port. Swappable.                               |

The agent already knows all of this. You don't explain these in the spec — you use them.

## Files

```
specification-template.md              ← blank master template
feature-specification-template.md      ← blank feature template (multi-spec only)

examples/
  single-spec/
    specification.md                   ← complete spec, one file

  multi-spec/
    docs/
      specification.md                 ← master spec, source of truth
      work/
        feature-sprint-management/
          specification.md             ← extracted: Sprint aggregate scope
        feature-backlog-management/
          specification.md             ← extracted: Product aggregate scope
        feature-discussion-integration/
          specification.md             ← extracted: cross-context scope
```
