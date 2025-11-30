---
id: "REQ-COMM-003"
title: "Project Comments/Feedback"
domain: "Communication"
status: draft
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-COMM-003: Project Comments/Feedback

## Description

The system shall provide commenting functionality within projects for asynchronous communication between staff and clients.

## Rationale

Project-level comments keep discussions contextual, reduce email threads, and create a searchable history of decisions and feedback.

## Source

- **Stakeholder:** Project Managers, Clients
- **Document:** Collaboration requirements

## Fit Criterion (Measurement)

- Comment submission in under 1 second
- Comments visible to authorized users only
- Full comment history searchable

## Dependencies

- **Depends On:** REQ-PROJ-001 (projects), REQ-AUTH-005 (client separation)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0019: Notification System](../03-decisions/adr-0019-notification-system.md)

## Acceptance Criteria

1. Comments can be added to projects
2. Comments can be added to specific tasks
3. Comments can be added to files/deliverables
4. Rich text formatting in comments
5. File attachments in comments
6. Comments are timestamped with author
7. Comment edit/delete (within time window)
8. Internal comments (staff-only) supported
9. Comment notifications to participants
10. Comment threads with replies

## Notes

- Consider approval/sign-off via comments
- Internal comments critical for staff coordination
- May integrate with or replace messaging (ADR)

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
