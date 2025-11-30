---
id: "REQ-PORT-007"
title: "Support Ticket Creation"
domain: "Client Portal"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PORT-007: Support Ticket Creation

## Description

The system shall allow clients to create support tickets for issues, questions, and requests.

## Rationale

Structured support tickets ensure issues are tracked, assigned, and resolved systematically.

## Source

- **Stakeholder:** Support Team, Clients
- **Document:** Client support requirements

## Fit Criterion (Measurement)

- Tickets created in under 2 minutes
- All tickets receive response within SLA
- Ticket resolution tracked

## Dependencies

- **Depends On:** REQ-AUTH-001 (authentication)
- **Blocks:** None
- **External:** None (or integration with Help Scout/Zendesk)

## Satisfied By

- *ADR needed: Build custom vs integrate Help Scout/Zendesk*

## Acceptance Criteria

1. Create new support ticket
2. Select category/type
3. Priority indication
4. Description and attachments
5. Ticket confirmation with number
6. Track ticket status
7. Reply to ticket updates
8. View ticket history
9. Close or reopen ticket
10. Satisfaction rating on close

## Notes

- Strong candidate for "buy" decision
- Help Scout provides excellent client-facing experience
- If building, keep it simple

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
