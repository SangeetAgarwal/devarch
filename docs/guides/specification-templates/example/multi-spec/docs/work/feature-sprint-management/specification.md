# specification.md — Feature: Sprint Management

# Extracted from: docs/specification.md v0.1

# Bounded Context: Agile PM

## Scope

Implement the Sprint aggregate with commit, complete, uncommit, and close behaviors. This is the core Sprint lifecycle within the Agile PM Bounded Context.

## Ubiquitous Language

Sprint: a time-boxed iteration for completing committed BacklogItems. NOT a Milestone.
BacklogItem: a unit of work delivering value. NOT a Task, Ticket, or Issue. Referenced by ID only from Sprint — lives in Product aggregate.
CommittedBacklogItem: a value object inside Sprint representing a BacklogItem committed to this Sprint. Holds backlogItemId reference only.
TeamMember: a person contributing to the Product. NOT a User. References identity by ID only.
SprintDuration: value object representing the time boundary of the Sprint.

## Aggregate: Sprint

Root: Sprint

Entities:
Sprint (aggregate root)
├── CommittedBacklogItem (value object — reference by backlogItemId)
└── SprintDuration (value object)

Behaviors (in scope):
commitBacklogItem(backlogItemId) → enforces capacity and active status, publishes BacklogItemCommitted
uncommitBacklogItem(backlogItemId) → enforces sprint active, publishes BacklogItemUncommitted
completeBacklogItem(backlogItemId) → enforces item committed, publishes BacklogItemDone
closeSprint() → enforces all items resolved, publishes SprintClosed

Behaviors (out of scope — do not implement):
None — this feature covers the full Sprint lifecycle

Invariants:

- BacklogItem can only be committed to one Sprint at a time
- Cannot commit to Sprint not in Active status
- Sprint cannot close while committed items remain in progress
- SprintDuration cannot change after activation

## Value Objects

SprintDuration:
startDate: date
endDate: date
Behaviors: contains(date), isActive(), totalDays()

CommittedBacklogItem:
backlogItemId: string
committedOn: datetime
status: Committed | InProgress | Done

## Domain Events

### BacklogItemCommitted

Trigger: Command-driven
Published by: Sprint
Invariants enforced: sprint active, item not committed elsewhere
Payload:
sprintId (string)
backlogItemId (string)
productId (string)
occurredOn (datetime)
Subscribers:
Collaboration — may notify Participants

### BacklogItemUncommitted

Trigger: Command-driven
Published by: Sprint
Invariants enforced: sprint active, item was committed
Payload:
sprintId (string)
backlogItemId (string)
productId (string)
occurredOn (datetime)
Subscribers:
Collaboration — may notify Participants

### BacklogItemDone

Trigger: Command-driven
Published by: Sprint
Invariants enforced: item was committed to this sprint
Payload:
sprintId (string)
backlogItemId (string)
productId (string)
occurredOn (datetime)
Subscribers:
Collaboration — may close related Discussion

### SprintClosed

Trigger: Command-driven
Published by: Sprint
Invariants enforced: all committed items resolved
Payload:
sprintId (string)
productId (string)
totalCommitted (integer)
totalCompleted (integer)
occurredOn (datetime)
Subscribers:
Collaboration — may schedule retrospective CalendarEntry

## Outbound Ports

ISprintRepository.FindById(sprintId)
ISprintRepository.Save(sprint)

## Outbound Adapters

PostgresSprintRepository implements ISprintRepository
InMemorySprintRepository implements ISprintRepository — testing

## Cross-Context References

References BacklogItem by backlogItemId only (Rule 3)
References Product by productId only (Rule 3)
Publishes events consumed by: Collaboration context
Does not query: Identity & Access directly

## Gap Analysis

### Unresolved

1. How is "BacklogItem can only be committed to one Sprint at a time" enforced? Sprint doesn't own BacklogItem — requires cross-aggregate check or domain service.
2. Sprint capacity — is there a maximum number of committed items? If so, who sets it?
3. What happens to uncommitted items when Sprint closes? Auto-remove or block close?

### Domain Expert Questions

1. Can a Sprint be reopened after closing?
2. Is there a minimum Sprint duration?

## Testing Requirements

Unit tests for invariants:

- commits item to active sprint
- rejects commit to inactive sprint
- rejects commit of already-committed item
- completes committed item
- rejects completion of uncommitted item
- closes sprint when all items resolved
- rejects close when items still in progress
- rejects SprintDuration change after activation

Unit tests for domain events:

- BacklogItemCommitted published on successful commit
- BacklogItemDone published on successful completion
- SprintClosed published with correct counts
- No events published when invariant violated

## References

Master spec: docs/specification.md v0.1
Related features: feature-backlog-management (Product aggregate, source of BacklogItems)
