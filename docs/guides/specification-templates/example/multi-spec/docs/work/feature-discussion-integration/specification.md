# specification.md — Feature: Discussion Integration with Agile PM

# Extracted from: docs/specification.md v0.1

# Bounded Context: Collaboration

# Cross-Context Dependency: Agile PM (upstream)

## Scope

Implement the Discussion aggregate and its integration with Agile PM Domain Events. When a BacklogItemPlanned event is received from the Agile PM context, a Discussion is automatically created and linked to the BacklogItem. When SprintClosed is received, a retrospective CalendarEntry is scheduled. When BacklogItemDone is received, the linked Discussion is closed.

## Ubiquitous Language

Discussion: a threaded conversation, often linked to a BacklogItem. NOT a Comment or Chat.
Post: a single contribution to a Discussion. NOT a Message.
Participant: a person in Discussions. NOT a User or TeamMember. References identity by ID only.
Forum: a collection of Discussions. NOT a Channel.
Calendar: a shared team schedule.
CalendarEntry: a time-bound event. NOT a Meeting.

## Aggregate: Discussion

Root: Discussion

Entities:
Discussion (aggregate root)
├── Post (entity)
│ content: PostContent (value object)
│ author: Participant (value object — identity reference)
└── DiscussionStatus (value object)

Behaviors (in scope):
startDiscussion(topic, author) → publishes DiscussionStarted
addPost(author, content) → enforces discussion open, publishes PostAdded
closeDiscussion() → publishes DiscussionClosed
reopenDiscussion() → enforces was closed, publishes DiscussionReopened

Invariants:

- Cannot add Posts to closed Discussion
- Only initiator or moderator can close Discussion

## Aggregate: Calendar

Root: Calendar

Entities:
Calendar (aggregate root)
└── CalendarEntry (entity)
timeSpan: DateTimeRange (value object)

Behaviors (in scope):
scheduleEntry(description, timeSpan) → publishes CalendarEntryScheduled

Invariants:

- CalendarEntries must not overlap (pending domain expert confirmation)

## Value Objects

PostContent: body (string). Behaviors: isNotEmpty(), wordCount()
DateTimeRange: start (datetime), end (datetime). Behaviors: contains(), overlaps(), durationMinutes()

## ACL: Agile PM Events

This is the critical cross-context integration. Collaboration subscribes to Agile PM Domain Events and translates them into Collaboration language.

### BacklogItemPlanned → Discussion

Subscribed event: BacklogItemPlanned from Agile PM
Translation:
BacklogItemPlanned.backlogItemId → Discussion.linkedBacklogItemId
BacklogItemPlanned.storyTitle → Discussion.topic (prefixed "Backlog: ")
System acts as author (automated Discussion creation)
Action: Call Discussion.startDiscussion() with translated data

### SprintClosed → CalendarEntry

Subscribed event: SprintClosed from Agile PM
Translation:
SprintClosed.sprintId → CalendarEntry description ("Sprint Retrospective: " + sprintId)
CalendarEntry scheduled for configurable offset after SprintClosed.occurredOn
Action: Call Calendar.scheduleEntry() with translated data

### BacklogItemDone → Discussion close

Subscribed event: BacklogItemDone from Agile PM
Translation:
BacklogItemDone.backlogItemId → find Discussion with matching linkedBacklogItemId
Action: Call Discussion.closeDiscussion() on linked Discussion (if exists)

Never queries Agile PM directly. All information comes through events.

## Domain Events

### DiscussionStarted

Trigger: Command-driven (or reactive to BacklogItemPlanned)
Published by: Discussion
Payload:
discussionId (string)
forumId (string)
topic (string)
authorId (string)
linkedBacklogItemId (string, nullable)
occurredOn (datetime)
Subscribers: none external

### PostAdded

Trigger: Command-driven
Published by: Discussion
Invariants enforced: discussion is open
Payload:
discussionId (string)
postId (string)
authorId (string)
occurredOn (datetime)
Subscribers: none external

### CalendarEntryScheduled

Trigger: Reactive to SprintClosed
Published by: Calendar
Payload:
calendarId (string)
entryId (string)
description (string)
scheduledDate (datetime)
occurredOn (datetime)
Subscribers: none external

## Outbound Ports

IDiscussionRepository.FindById(discussionId)
IDiscussionRepository.FindByLinkedBacklogItemId(backlogItemId)
IDiscussionRepository.Save(discussion)
ICalendarRepository.FindById(calendarId)
ICalendarRepository.Save(calendar)

## Outbound Adapters

PostgresDiscussionRepository implements IDiscussionRepository
PostgresCalendarRepository implements ICalendarRepository
InMemory variants for testing

## ACL: Identity & Access

Consumes: UserRegistered event
Translation:
User.userId → Participant.participantId (ID only)
User.username → Participant.displayName
Never imports: Credentials, Permissions, Role objects

## Cross-Context References

Subscribes to events from: Agile PM context (BacklogItemPlanned, SprintClosed, BacklogItemDone)
Subscribes to events from: Identity & Access context (UserRegistered)
Does not query either context directly. Events only.
References BacklogItem by linkedBacklogItemId (Rule 3)
References User by participantId (Rule 3)

## Gap Analysis

### Unresolved

1. Auto-close Discussion on BacklogItemDone — should this be automatic or should a Participant confirm? Auto-close may disrupt active conversations.
2. What if BacklogItemPlanned fires but no Forum exists yet? Create Forum on demand or require pre-existing Forum?
3. Retrospective CalendarEntry scheduling — what is the configurable offset? Same day? Next business day?

### Domain Expert Questions

1. Can a Discussion be linked to multiple BacklogItems, or strictly one?
2. Should auto-created Discussions have a different status or marker than manually created ones?
3. CalendarEntry overlap invariant — confirmed or not?

## Testing Requirements

Unit tests for Discussion invariants:

- adds Post to open Discussion
- rejects Post on closed Discussion
- closes Discussion
- reopens closed Discussion
- rejects close by non-initiator/non-moderator

Unit tests for Calendar invariants:

- schedules CalendarEntry
- rejects overlapping entries (if invariant confirmed)

Integration tests for cross-context events:

- BacklogItemPlanned → creates linked Discussion with correct topic
- SprintClosed → schedules retrospective CalendarEntry
- BacklogItemDone → closes linked Discussion
- Duplicate event handling — idempotency check
- Missing linkedBacklogItemId handled gracefully

## References

Master spec: docs/specification.md v0.1
Upstream dependency: feature-backlog-management (publishes BacklogItemPlanned)
Upstream dependency: feature-sprint-management (publishes SprintClosed, BacklogItemDone)
