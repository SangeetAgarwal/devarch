# specification.md — DDD Specification Template for DevArch

# ============================================

# PROJECT

# ============================================

Project: [project name]
Version: [semver]
Status: [Discovery | Active Development | Maintenance]
Last Updated: [date]

# ============================================

# PROBLEM SPACE

# ============================================

## Domain Overview

[2-3 sentences describing what the business does and the core problem being solved]

## Subdomains

### Core Domain: [name]

Description: [why this is the competitive differentiator]
Domain Experts: [roles or names]

### Supporting Subdomain: [name]

Description: [what it supports and why it's custom]
Domain Experts: [roles or names]

### Generic Subdomain: [name]

Description: [solved problem, buy or use off-the-shelf]
Solution: [technology or vendor]

[Repeat Supporting/Generic as needed]

# ============================================

# SOLUTION SPACE

# ============================================

## Bounded Context: [name]

Subdomain: [which subdomain — must be 1:1]
Architecture: [Ports and Adapters | CQRS | Layered | CRUD]

### Ubiquitous Language

[term]: [precise definition]. NOT [common confusion].
[term]: [precise definition]. NOT [common confusion].
[term]: [precise definition].

### Aggregate: [name]

Root: [aggregate root entity name]

Entities:
[root] (aggregate root)
└── [child] (entity)
├── [child] (entity)
│ [attribute]: [Type] (value object)
├── [child] (entity)
└── [child] (value object)

Behaviors:
[method]([params]) → enforces [invariant], publishes [Event]
[method]([params]) → enforces [invariant], publishes [Event]

Invariants:

- [rule that must always be true]
- [rule that must always be true]

### Value Objects

[Name]:
[attribute]: [type]
[attribute]: [type]
Behaviors: [method](), [method]()

### Inbound Ports

[IServiceName].[Method]([params])

### Outbound Ports

[IRepositoryName].FindById([id])
[IRepositoryName].Save([aggregate])

### Outbound Adapters

[AdapterName] implements [IRepositoryName] — [description]
[AdapterName] implements [IRepositoryName] — [description]

[Repeat Bounded Context section for each context]

# ============================================

# CONTEXT MAP

# ============================================

## Relationships

[ContextA] → [ContextB]: [PARTNERSHIP | CUSTOMER-SUPPLIER | CONFORMIST | ACL | OPEN HOST SERVICE | PUBLISHED LANGUAGE | SEPARATE WAYS | BIG BALL OF MUD]
Upstream: [context]
Downstream: [context]
Integration: [REST | Messaging | RPC]
Notes: [description]

# ============================================

# DOMAIN EVENTS

# ============================================

## Events from [Context Name]

### [EventNameInPastTense]

Trigger: [Command-driven | State-detected]
Command: [CommandName(params)] — omit if state-detected
Published by: [aggregate root | system process]
Invariants enforced: [which invariants must pass]
Payload:
[field] ([type])
[field] ([type])
occurredOn (datetime)
Subscribers:
[Context] — [reaction in its own language]

# ============================================

# ANTICORRUPTION LAYERS

# ============================================

## [Context] ACL → [External System]

Reads: [objects/fields]
Writes: [objects/fields]
Never touches: [objects/fields]
Assembles: [aggregate] from [external objects]

# ============================================

# EVENT INFRASTRUCTURE

# ============================================

Event Store: [technology]
Message Bus: [technology]
Idempotency: [strategy]
Dead Letter: [strategy]

# ============================================

# GAP ANALYSIS

# ============================================

## Unresolved Design Decisions

1. [decision needed]

## Questions for Domain Experts

1. [question]

## Not Yet Specified

1. [area deferred]

# ============================================

# IMPLEMENTATION PHASES

# ============================================

## Phase 1: [name]

- [deliverable]

## Phase 2: [name]

- [deliverable]
