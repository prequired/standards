---
id: "REQ-COMM-005"
title: "@Mentions in Comments"
domain: "Communication"
status: draft
priority: low
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-COMM-005: @Mentions in Comments

## Description

The system shall support @mentioning users in comments to notify and direct attention to specific people.

## Rationale

@mentions provide a lightweight way to involve specific team members in conversations, reducing notification noise for others.

## Source

- **Stakeholder:** Project Teams
- **Document:** Collaboration requirements

## Fit Criterion (Measurement)

- Mentioned users receive notification within 5 seconds
- Mention autocomplete shows in under 500ms
- 100% of mentions trigger notifications

## Dependencies

- **Depends On:** REQ-COMM-003 (comments), REQ-COMM-001 (notifications)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0019: Notification System](../03-decisions/adr-0019-notification-system.md)

## Acceptance Criteria

1. Typing @ triggers user autocomplete
2. Autocomplete shows relevant users (project members)
3. Selected user is linked in comment
4. Mentioned user receives notification
5. Mention notification links to comment
6. Multiple mentions per comment supported
7. @channel or @all mention for group notifications
8. Mentions work in all comment contexts

## Notes

- Consider Phase 2 implementation
- Similar UX to Slack, GitHub mentions
- May require rich text editor integration

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
