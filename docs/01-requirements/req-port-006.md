---
id: "REQ-PORT-006"
title: "Feedback Submission"
domain: "Client Portal"
status: approved
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PORT-006: Feedback Submission

## Description

The system shall allow clients to submit feedback on deliverables and project work directly from the portal.

## Rationale

Structured feedback collection improves revision efficiency and maintains clear records of client input.

## Source

- **Stakeholder:** Project Managers, Clients
- **Document:** Collaboration requirements

## Fit Criterion (Measurement)

- Feedback submitted in context of deliverable
- Feedback clearly attributed and timestamped
- Revision requests trackable

## Dependencies

- **Depends On:** REQ-COMM-003 (comments), REQ-PORT-005 (files)
- **Blocks:** REQ-PORT-009 (approval workflow)
- **External:** None

## Satisfied By

- [ADR-0018: Client Portal Architecture](../03-decisions/adr-0018-client-portal-architecture.md)

## Acceptance Criteria

1. Comment on specific deliverables
2. Annotate images/PDFs (optional)
3. Request revisions with specifics
4. Track revision status
5. Approve deliverables
6. Feedback thread for back-and-forth
7. Attachment support in feedback
8. Staff notification of new feedback
9. Feedback history retained
10. Export feedback for records

## Notes

- Consider visual annotation tools (Marker.io style)
- Keep feedback connected to specific version
- Clear distinction between feedback and approval

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
