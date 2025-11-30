---
id: "REQ-COMM-007"
title: "SMS Notifications"
domain: "Communication"
status: draft
priority: low
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-COMM-007: SMS Notifications

## Description

The system shall support SMS notifications for urgent alerts and time-sensitive communications.

## Rationale

SMS provides a high-visibility channel for critical alerts that require immediate attention, even when users aren't at their computer.

## Source

- **Stakeholder:** Operations Team
- **Document:** Critical communications requirements

## Fit Criterion (Measurement)

- SMS delivery within 30 seconds
- SMS reserved for critical/urgent only
- Opt-in required for SMS (compliance)

## Dependencies

- **Depends On:** REQ-USER-001 (phone numbers), REQ-COMM-006 (preferences)
- **Blocks:** None
- **External:** Twilio or similar SMS provider

## Satisfied By

- [ADR-0004: Messaging/Chat](../03-decisions/adr-0004-messaging-chat.md)

## Acceptance Criteria

1. Users can add phone number to profile
2. Phone number verification via SMS code
3. SMS opt-in explicit and required
4. SMS used only for critical alerts
5. Example: invoice payment reminders, outage alerts
6. SMS includes short action link
7. STOP to unsubscribe supported
8. SMS delivery status tracked
9. Rate limiting to prevent abuse
10. Admin can trigger SMS for critical broadcasts

## Notes

- Consider Phase 2 or later implementation
- Twilio recommended for reliability
- Cost consideration: SMS charges per message

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
