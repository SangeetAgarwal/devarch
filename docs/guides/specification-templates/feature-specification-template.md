# specification.md — Feature: [Feature Name]

# Extracted from: docs/specification.md v[version]

# Bounded Context: [context name]

# Cross-Context Dependency: [upstream context, if any]

## Scope

[2-3 sentences: what this feature implements, which aggregate(s), which behaviors]

## Ubiquitous Language

[term]: [definition]. NOT [confusion].
[term]: [definition].

## Aggregate: [name]

Root: [aggregate root]

Entities:
[root] (aggregate root)
├── [child] (entity)
│ [attribute]: [Type] (value object)
└── [child] (value object)

Behaviors (in scope):
[method]([params]) → enforces [invariant], publishes [Event]
[method]([params]) → enforces [invariant], publishes [Event]

Behaviors (out of scope — do not implement):
[method] — covered by [other feature]

Invariants:

- [rule that must always be true]
- [rule that must always be true]

## Value Objects

[Name]:
[attribute]: [type]
Behaviors: [method](), [method]()

## Domain Events

### [EventNameInPastTense]

Trigger: [Command-driven | State-detected]
Published by: [aggregate root]
Invariants enforced: [which invariants]
Payload:
[field] ([type])
occurredOn (datetime)
Subscribers:
[Context] — [reaction]

## Outbound Ports

[IRepositoryName].FindById([id])
[IRepositoryName].Save([aggregate])

## Outbound Adapters

[Adapter] implements [IRepository] — [description]
[Adapter] implements [IRepository] — testing

## Cross-Context References

References [what] by [ID field] only (Rule 3)
Publishes events consumed by: [contexts]
Does not query: [contexts]

## ACL: [External Context] (include only if this feature has cross-context integration)

Consumes: [event or API]
Translation:
[external concept] → [local concept]
Never imports: [what to exclude]

## Gap Analysis

### Unresolved Design Decisions

1. [decision needed]

### Questions for Domain Experts

1. [question]

## Testing Requirements

Unit tests for invariants:

- [test case]
- [test case]

Unit tests for domain events:

- [test case]

Integration tests (if cross-context):

- [test case]

## References

Master spec: docs/specification.md v[version]
Related features: [feature-name] ([relationship])
