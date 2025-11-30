---
id: "REQ-COMM-006"
title: "Notification Preferences"
domain: "Communication"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-COMM-006: Notification Preferences

## Description

The system shall allow users to configure their notification preferences by channel (email, in-app) and event type.

## Rationale

Users have different notification needs. Configurable preferences reduce noise and increase engagement with important notifications.

## Source

- **Stakeholder:** UX Team
- **Document:** User experience requirements

## Fit Criterion (Measurement)

- Preference changes take effect immediately
- Preferences granular to event type level
- Mandatory notifications cannot be disabled

## Dependencies

- **Depends On:** REQ-COMM-001 (in-app), REQ-COMM-002 (email), REQ-USER-007 (preferences)
- **Blocks:** None
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Preferences accessible in user settings
2. Toggle per notification type
3. Toggle per channel (email, in-app, push)
4. Digest option (daily summary vs instant)
5. Quiet hours configuration
6. Project-specific notification settings
7. Sensible defaults for new users
8. Some notifications mandatory (security, billing)
9. Test notification to verify settings
10. Preference reset to defaults option

## Notes

- Matrix UI: rows = event types, columns = channels
- Consider notification categories for simpler UX
- GDPR/CAN-SPAM compliance for marketing notifications

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
