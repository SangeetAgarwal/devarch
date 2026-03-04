# specification.md — Scrum Project Management Software

# ============================================

# PROJECT

# ============================================

Project: Scrum Project Management Software
Version: 0.1
Status: Discovery
Last Updated: 2026-03-03

# ============================================

# PROBLEM SPACE

# ============================================

## Domain Overview

A collaborative Scrum-based project management platform. Teams use it to plan work, manage sprints, track backlog items, and collaborate through discussions. The platform must support the full Scrum lifecycle while keeping identity management and team collaboration as separate concerns.

## Subdomains

### Core Domain: Agile Project Management

Description: The Scrum planning and execution engine — backlog management, sprint planning, release tracking. This is the product's differentiator.
Domain Experts: Scrum Masters, Product Owners, Agile Coaches.

### Supporting Subdomain: Collaboration

Description: Discussions, forums, shared calendars, and notifications that support team communication during Scrum activities.
Domain Experts: Team leads, UX researchers.

### Generic Subdomain: Identity & Access

Description: User authentication, role management, permissions. Solved problem.
Solution: Custom implementation using standard OIDC/OAuth2 patterns.

# ============================================

# SOLUTION SPACE

# ============================================

## Bounded Context: Agile PM

Subdomain: Agile Project Management (Core Domain)
Architecture: Ports and Adapters

### Ubiquitous Language

Product: a software product being developed using Scrum. NOT a commercial product or SKU.
ProductOwner: the person responsible for backlog prioritization. NOT a User or Role. References identity by ID only.
BacklogItem: a unit of work delivering value. NOT a Task, Ticket, or Issue.
Sprint: a time-boxed iteration for completing committed BacklogItems. NOT a Milestone.
Release: a versioned collection of completed work that is shipped.
TeamMember: a person contributing to the Product. NOT a User. References identity by ID only.
Task: a technical breakdown within a BacklogItem. Estimated in hours.
BusinessPriority: value object expressing relative importance.

### Aggregate: Product

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

Behaviors:
planBacklogItem(story, priority) → publishes BacklogItemPlanned
scheduleBacklogItemForRelease(backlogItemId, releaseId) → enforces item is Done
changeProductOwner(newOwnerId) → publishes ProductOwnerChanged
reprioritizeBacklogItem(backlogItemId, newPriority) → enforces ProductOwner authority

Invariants:

- BacklogItem cannot be scheduled for Release unless status is Done
- Only ProductOwner can change BacklogItem priority
- BacklogItem story cannot be modified while committed to active Sprint

### Aggregate: Sprint

Root: Sprint

Entities:
Sprint (aggregate root)
├── CommittedBacklogItem (value object — reference by backlogItemId)
└── SprintDuration (value object)

Behaviors:
commitBacklogItem(backlogItemId) → enforces capacity and active status, publishes BacklogItemCommitted
uncommitBacklogItem(backlogItemId) → enforces sprint active, publishes BacklogItemUncommitted
completeBacklogItem(backlogItemId) → enforces item committed, publishes BacklogItemDone
closeSprint() → enforces all items resolved, publishes SprintClosed

Invariants:

- BacklogItem can only be committed to one Sprint at a time
- Cannot commit to Sprint not in Active status
- Sprint cannot close while committed items remain in progress
- SprintDuration cannot change after activation

### Aggregate: Release

Root: Release

Entities:
Release (aggregate root)
└── ScheduledBacklogItem (value object — reference by backlogItemId)

Behaviors:
scheduleItem(backlogItemId) → enforces item Done, publishes ReleaseItemScheduled
unscheduleItem(backlogItemId) → publishes ReleaseItemUnscheduled
ship() → enforces has scheduled items, publishes ReleaseShipped

Invariants:

- Only Done BacklogItems can be scheduled
- Cannot ship Release with no scheduled items

### Value Objects

Story: title (string), narrative (string). Behaviors: isWellFormed()
BusinessPriority: rating (decimal 0.0-1.0). Behaviors: compareTo(), isHigherThan()
BacklogItemStatus: value (Planned | Committed | InProgress | Done | Removed). Behaviors: canTransitionTo()
Estimation: hours (integer). Behaviors: isOverEstimate(), remaining()
SprintDuration: startDate (date), endDate (date). Behaviors: contains(), isActive(), totalDays()

### Ports

Inbound:
IAgilePMService.PlanBacklogItem(productId, story, priority)
IAgilePMService.CommitBacklogItemToSprint(sprintId, backlogItemId)
IAgilePMService.CompleteBacklogItem(sprintId, backlogItemId)
IAgilePMService.CloseSprint(sprintId)
IAgilePMService.ScheduleRelease(releaseId, backlogItemId)
IAgilePMService.ShipRelease(releaseId)

Outbound:
IProductRepository.FindById(productId) / .Save(product)
ISprintRepository.FindById(sprintId) / .Save(sprint)
IReleaseRepository.FindById(releaseId) / .Save(release)

Adapters:
PostgresProductRepository, PostgresSprintRepository, PostgresReleaseRepository
InMemory variants for testing

---

## Bounded Context: Collaboration

Subdomain: Collaboration (Supporting)
Architecture: Ports and Adapters

### Ubiquitous Language

Discussion: a threaded conversation, often linked to a BacklogItem. NOT a Comment or Chat.
Post: a single contribution to a Discussion. NOT a Message.
Participant: a person in Discussions. NOT a User or TeamMember. References identity by ID only.
Forum: a collection of Discussions. NOT a Channel.
Calendar: a shared team schedule.
CalendarEntry: a time-bound event. NOT a Meeting.

### Aggregate: Discussion

Root: Discussion

Entities:
Discussion (aggregate root)
├── Post (entity)
│ content: PostContent (value object)
│ author: Participant (value object — identity reference)
└── DiscussionStatus (value object)

Behaviors:
startDiscussion(topic, author) → publishes DiscussionStarted
addPost(author, content) → enforces discussion open, publishes PostAdded
closeDiscussion() → publishes DiscussionClosed
reopenDiscussion() → enforces was closed, publishes DiscussionReopened

Invariants:

- Cannot add Posts to closed Discussion
- Only initiator or moderator can close Discussion

### Aggregate: Calendar

Root: Calendar

Entities:
Calendar (aggregate root)
└── CalendarEntry (entity)
timeSpan: DateTimeRange (value object)

Behaviors:
scheduleEntry(description, timeSpan) → publishes CalendarEntryScheduled
cancelEntry(entryId) → publishes CalendarEntryCanceled
rescheduleEntry(entryId, newTimeSpan) → publishes CalendarEntryRescheduled

Invariants:

- CalendarEntries must not overlap (pending domain expert confirmation)

### Value Objects

PostContent: body (string). Behaviors: isNotEmpty(), wordCount()
DateTimeRange: start (datetime), end (datetime). Behaviors: contains(), overlaps(), durationMinutes()

### Ports

Inbound:
ICollaborationService.StartDiscussion(forumId, topic, authorId)
ICollaborationService.AddPost(discussionId, authorId, content)
ICollaborationService.CloseDiscussion(discussionId)
ICollaborationService.ScheduleCalendarEntry(calendarId, description, timeSpan)

Outbound:
IDiscussionRepository.FindById(discussionId) / .Save(discussion)
ICalendarRepository.FindById(calendarId) / .Save(calendar)

Adapters:
PostgresDiscussionRepository, PostgresCalendarRepository
InMemory variants for testing

---

## Bounded Context: Identity & Access

Subdomain: Identity & Access (Generic)
Architecture: Layered (CRUD — generic subdomain)

### Ubiquitous Language

User: a person with login credentials. NOT a TeamMember or Participant.
Role: a named permission set. NOT a Scrum role like ProductOwner.
Tenant: organizational boundary for multi-tenancy.
Permission: a capability granted through a Role.

### Aggregate: Tenant

Root: Tenant

Entities:
Tenant (aggregate root)
├── User (entity)
│ credentials: Credentials (value object)
│ contactInfo: ContactInfo (value object)
└── Role (entity)
└── Permission (value object)

Behaviors:
registerUser(username, credentials, contactInfo) → enforces unique username, publishes UserRegistered
assignRoleToUser(userId, roleId) → enforces role exists, publishes UserRoleAssigned
deactivateUser(userId) → publishes UserDeactivated
createRole(name, permissions) → enforces unique role name

Invariants:

- Username unique within Tenant
- Role name unique within Tenant
- Deactivated User cannot be assigned new Roles

### Value Objects

Credentials: username (string), passwordHash (string). Behaviors: matches()
ContactInfo: email (string), phone (string, optional). Behaviors: isValid()

### Ports

Inbound:
IIdentityService.RegisterUser(tenantId, username, credentials, contactInfo)
IIdentityService.AuthenticateUser(tenantId, username, password)
IIdentityService.AssignRole(tenantId, userId, roleId)
IIdentityService.DeactivateUser(tenantId, userId)

Outbound:
ITenantRepository.FindById(tenantId) / .Save(tenant)

Adapters:
PostgresTenantRepository
InMemoryTenantRepository — testing

# ============================================

# CONTEXT MAP

# ============================================

Identity & Access → Agile PM: CUSTOMER-SUPPLIER
Upstream: Identity & Access
Downstream: Agile PM
Integration: REST (Open Host Service)
Notes: Agile PM translates User → TeamMember/ProductOwner (ID only)

Identity & Access → Collaboration: CUSTOMER-SUPPLIER
Upstream: Identity & Access
Downstream: Collaboration
Integration: REST (Open Host Service)
Notes: Collaboration translates User → Participant (ID only)

Agile PM → Collaboration: CUSTOMER-SUPPLIER
Upstream: Agile PM
Downstream: Collaboration
Integration: Messaging (Domain Events)
Notes: BacklogItemPlanned may trigger Discussion creation. SprintClosed may trigger retrospective CalendarEntry.

## Cross-Context Identity

Same person, different models, different contexts:
Identity & Access: User (credentials, roles)
Agile PM: TeamMember (sprint work), ProductOwner (backlog authority)
Collaboration: Participant (discussion activity)
All reference by tenantId + userId. Rule 3 — ID only.

# ============================================

# DOMAIN EVENTS

# ============================================

## From Agile PM

BacklogItemPlanned { productId, backlogItemId, storyTitle, businessPriority, occurredOn }
Trigger: Command. Subscribers: Collaboration (may create Discussion)

BacklogItemCommitted { sprintId, backlogItemId, productId, occurredOn }
Trigger: Command. Invariants: sprint active, item available. Subscribers: Collaboration

BacklogItemDone { sprintId, backlogItemId, productId, occurredOn }
Trigger: Command. Invariants: item committed. Subscribers: Collaboration

SprintClosed { sprintId, productId, totalCommitted, totalCompleted, occurredOn }
Trigger: Command. Invariants: all items resolved. Subscribers: Collaboration (retrospective)

ReleaseShipped { releaseId, productId, version, itemCount, occurredOn }
Trigger: Command. Invariants: has items. Subscribers: Collaboration (announcement)

## From Collaboration

DiscussionStarted { discussionId, forumId, topic, authorId, linkedBacklogItemId, occurredOn }
Trigger: Command. Subscribers: none external

PostAdded { discussionId, postId, authorId, occurredOn }
Trigger: Command. Invariants: discussion open. Subscribers: none external

## From Identity & Access

UserRegistered { tenantId, userId, username, email, occurredOn }
Trigger: Command. Invariants: unique username. Subscribers: Agile PM, Collaboration (provision references)

UserRoleAssigned { tenantId, userId, roleName, occurredOn }
Trigger: Command. Subscribers: Agile PM (ProductOwner assignment if role matches)

UserDeactivated { tenantId, userId, occurredOn }
Trigger: Command. Subscribers: Agile PM (deactivate TeamMember), Collaboration (deactivate Participant)

# ============================================

# ACLs

# ============================================

Agile PM ACL → Identity & Access:
User.userId → TeamMember.memberId (ID only)
User.username → TeamMember.displayName
User.role("ProductOwner") → ProductOwner assignment
Never imports: Credentials, Permissions, Role objects

Collaboration ACL → Identity & Access:
User.userId → Participant.participantId (ID only)
User.username → Participant.displayName
Never imports: Credentials, Permissions, Role objects

Collaboration ACL → Agile PM:
BacklogItemPlanned.backlogItemId → Discussion.linkedBacklogItemId
BacklogItemPlanned.storyTitle → Discussion.topic
SprintClosed → CalendarEntry for retrospective
Never queries Agile PM directly. Events only.

# ============================================

# EVENT INFRASTRUCTURE

# ============================================

Event Store: Co-transactional with aggregate state (PostgreSQL)
Message Bus: [TBD — RabbitMQ or similar]
Relay: Background process polls for unpublished events
Idempotency: Subscribers track processed eventIds
Dead Letter: Failed events after 3 retries

# ============================================

# GAP ANALYSIS

# ============================================

## Unresolved

1. Event Sourcing for Sprint aggregate?
2. BacklogItem as own aggregate vs inside Product? (sizing concern)
3. Multi-tenancy: separate schemas or row-level filtering?
4. Auto-create Discussions on BacklogItemPlanned, or opt-in?

## Domain Expert Questions

1. Can BacklogItems carry over between Sprints?
2. Sprint duration limits (min/max)?
3. Can a Release span multiple Products?
4. Reopen closed Discussions?
5. What happens to in-progress Tasks when User deactivated?

## Deferred

1. UI/UX
2. Reporting (velocity, burndown)
3. Notifications
4. Search
5. Import/Export

# ============================================

# PHASES

# ============================================

Phase 1: Core Agile PM — Product, Sprint, BacklogItem aggregates + tests
Phase 2: Identity & Access — Tenant aggregate, REST API, Agile PM ACL
Phase 3: Collaboration — Discussion, Calendar, event subscriptions from Agile PM
Phase 4: Release Management — Release aggregate, cross-aggregate coordination
Phase 5: Event Infrastructure — Event Store, relay, dead letter, monitoring
