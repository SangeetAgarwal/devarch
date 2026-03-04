# specification.md — Feature: Backlog Management

# Extracted from: docs/specification.md v0.1

# Bounded Context: Agile PM

## Scope

Implement the Product aggregate with backlog planning, reprioritization, and ProductOwner management. This feature covers BacklogItem lifecycle up to the point of Sprint commitment (handled by Sprint aggregate in feature-sprint-management).

## Ubiquitous Language

Product: a software product being developed using Scrum. NOT a commercial product or SKU.
ProductOwner: the person responsible for backlog prioritization. NOT a User or Role. References identity by tenantId + userId only.
BacklogItem: a unit of work delivering value. NOT a Task, Ticket, or Issue.
Task: a technical breakdown within a BacklogItem. Estimated in hours. Assigned to a TeamMember.
Story: value object capturing the user story narrative.
BusinessPriority: value object expressing relative importance (0.0-1.0).
BacklogItemStatus: value object tracking lifecycle (Planned | Committed | InProgress | Done | Removed).

## Aggregate: Product

Root: Product

Entities:
Product (aggregate root)
├── BacklogItem (entity)
│ story: Story (value object)
│ businessPriority: BusinessPriority (value object)
│ status: BacklogItemStatus (value object)
│ └── Task (entity)
│ estimation: Estimation (value object)
└── ProductOwner (value object — identity reference)

Behaviors (in scope):
planBacklogItem(story, priority) → publishes BacklogItemPlanned
changeProductOwner(newOwnerId) → publishes ProductOwnerChanged
reprioritizeBacklogItem(backlogItemId, newPriority) → enforces ProductOwner authority

Behaviors (out of scope — do not implement):
scheduleBacklogItemForRelease — covered by feature-release-management

Invariants:

- Only ProductOwner can change BacklogItem priority
- BacklogItem story cannot be modified while committed to active Sprint

## Value Objects

Story:
title: string
narrative: string (As a [role], I want [feature], so that [benefit])
Behaviors: isWellFormed()

BusinessPriority:
rating: decimal (0.0 - 1.0, higher = more important)
Behaviors: compareTo(other), isHigherThan(other)

BacklogItemStatus:
value: Planned | Committed | InProgress | Done | Removed
Behaviors: canTransitionTo(newStatus)

Estimation:
hours: integer
Behaviors: isOverEstimate(threshold), remaining(hoursWorked)

## Domain Events

### BacklogItemPlanned

Trigger: Command-driven
Published by: Product
Invariants enforced: none (planning always allowed)
Payload:
productId (string)
backlogItemId (string)
storyTitle (string)
businessPriority (decimal)
occurredOn (datetime)
Subscribers:
Collaboration — may create Discussion linked to BacklogItem

### ProductOwnerChanged

Trigger: Command-driven
Published by: Product
Invariants enforced: none
Payload:
productId (string)
previousOwnerId (string)
newOwnerId (string)
occurredOn (datetime)
Subscribers:
No external subscribers

## Outbound Ports

IProductRepository.FindById(productId)
IProductRepository.Save(product)

## Outbound Adapters

PostgresProductRepository implements IProductRepository
InMemoryProductRepository implements IProductRepository — testing

## Cross-Context References

References User identity by tenantId + userId for ProductOwner (Rule 3)
Consumes UserRoleAssigned event from Identity & Access to detect ProductOwner assignment
Publishes events consumed by: Collaboration context
Does not query: Collaboration or Identity & Access directly

## ACL: Identity & Access

Consumes: UserRoleAssigned event
Translation:
If roleName == "ProductOwner" → trigger changeProductOwner on relevant Product
User.userId → ProductOwner.ownerId (ID only)
Never imports: Credentials, Permissions, Role objects

## Gap Analysis

### Unresolved

1. BacklogItem sizing — should Product aggregate limit the number of BacklogItems? Performance concern at scale.
2. How does BacklogItem status update when Sprint commits/completes it? Product needs to subscribe to Sprint events — not yet specified in this feature.
3. Can a BacklogItem be removed after it has been committed to a Sprint?

### Domain Expert Questions

1. Can multiple BacklogItems share the same BusinessPriority rating, or must priorities be unique?
2. Is there a maximum number of Tasks per BacklogItem?

## Testing Requirements

Unit tests for invariants:

- plans BacklogItem with valid Story and BusinessPriority
- rejects reprioritization by non-ProductOwner
- rejects story modification on BacklogItem committed to active Sprint
- allows story modification on BacklogItem in Planned status

Unit tests for domain events:

- BacklogItemPlanned published with correct payload
- ProductOwnerChanged published with previous and new owner IDs

Unit tests for value objects:

- Story.isWellFormed() validates narrative format
- BusinessPriority comparison and ordering
- BacklogItemStatus valid transitions
- Estimation.remaining() calculation

## References

Master spec: docs/specification.md v0.1
Related features: feature-sprint-management (Sprint commits BacklogItems by ID)
Related features: feature-release-management (Release schedules Done BacklogItems)
