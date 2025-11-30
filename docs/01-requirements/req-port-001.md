---
id: "REQ-PORT-001"
title: "Client Dashboard"
domain: "Client Portal"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PORT-001: Client Dashboard

## Description

The system shall provide a personalized dashboard for clients upon login, showing relevant projects, invoices, and actions.

## Rationale

The dashboard is the client's home base, providing quick access to their most important information and required actions.

## Source

- **Stakeholder:** Account Management, Clients
- **Document:** Client experience requirements

## Fit Criterion (Measurement)

- Dashboard loads in under 2 seconds
- Key information visible without scrolling
- Actions clearly prioritized

## Dependencies

- **Depends On:** REQ-AUTH-001 (authentication), REQ-AUTH-005 (client separation)
- **Blocks:** None
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Welcome message with client name
2. Active projects summary
3. Recent project activity
4. Pending invoices alert
5. Upcoming milestones
6. Quick action buttons
7. Unread messages indicator
8. Recent files/deliverables
9. Announcement/news banner (optional)
10. Customizable widget layout (future)

## Notes

- Keep dashboard clean and focused
- Prioritize actionable items
- Consider client feedback for dashboard content

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
