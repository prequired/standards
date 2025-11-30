---
id: "REQ-PROJ-008"
title: "Project Activity Log"
domain: "Project Management"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PROJ-008: Project Activity Log

## Description

The system shall maintain an activity log for each project, recording significant events, changes, and updates.

## Rationale

Activity logs provide accountability, support debugging, and give stakeholders a timeline of project progress.

## Source

- **Stakeholder:** Project Managers, Operations Team
- **Document:** Audit and accountability requirements

## Fit Criterion (Measurement)

- All significant project events are logged
- Activity log loads in under 1 second
- Logs retained for 2 years minimum

## Dependencies

- **Depends On:** REQ-PROJ-001 (projects)
- **Blocks:** None
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Activity log shows recent project events
2. Events logged: status changes, assignments, comments, files
3. Each entry shows: action, user, timestamp
4. Activity log is filterable by event type
5. Activity log is searchable
6. Clients see relevant (non-sensitive) activity
7. Activity can be exported for reporting
8. Pagination for large activity lists

## Notes

- Use Spatie Activity Log package
- Consider real-time updates via websockets
- Balance detail vs noise in logged events

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
