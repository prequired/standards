---
id: "REQ-COMM-004"
title: "Direct Messaging (Staff-Client)"
domain: "Communication"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-COMM-004: Direct Messaging (Staff-Client)

## Description

The system shall provide direct messaging functionality for private communication between staff and clients outside of project context.

## Rationale

Not all communication fits within project comments. Direct messaging handles account questions, relationship management, and ad-hoc requests.

## Source

- **Stakeholder:** Account Managers, Clients
- **Document:** Client experience requirements

## Fit Criterion (Measurement)

- Message delivery in under 2 seconds
- Message history retained for 2 years
- Read receipts available

## Dependencies

- **Depends On:** REQ-AUTH-001 (authentication), REQ-AUTH-005 (client separation)
- **Blocks:** None
- **External:** None (or integration with Intercom/Crisp)

## Satisfied By

- *ADR needed: Build custom vs integrate Intercom/Crisp/HelpScout*

## Acceptance Criteria

1. Staff can message any client
2. Clients can message assigned staff
3. Conversation threads organized by participant
4. Real-time message delivery
5. Unread message indicators
6. File attachments in messages
7. Message search functionality
8. Conversation archive/close
9. Message history accessible to admins
10. Mobile-friendly messaging interface

## Notes

- Consider integrating existing tool (Intercom, Crisp) instead of building
- May overlap with support tickets - clarify boundaries
- Consider canned responses for common queries

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
