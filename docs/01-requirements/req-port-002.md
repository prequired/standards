---
id: "REQ-PORT-002"
title: "Project Status Visibility"
domain: "Client Portal"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PORT-002: Project Status Visibility

## Description

The system shall display project status and progress to clients for all their authorized projects.

## Rationale

Transparent project visibility reduces client anxiety, decreases status update requests, and builds trust.

## Source

- **Stakeholder:** Clients, Account Management
- **Document:** Client communication requirements

## Fit Criterion (Measurement)

- Clients can view all their projects
- Status updates visible in real-time
- Clients report feeling informed

## Dependencies

- **Depends On:** REQ-PROJ-001 (projects), REQ-PROJ-002 (status), REQ-AUTH-005 (separation)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0018: Client Portal Architecture](../03-decisions/adr-0018-client-portal-architecture.md)

## Acceptance Criteria

1. List of client's projects
2. Project status clearly displayed
3. Progress indicator or percentage
4. Milestone status and dates
5. Current phase description
6. Next steps information
7. Timeline view (optional)
8. Project detail page access
9. Filter by status (active, completed)
10. Search projects

## Notes

- Show appropriate level of detail (not internal tasks)
- Consider Gantt chart for timeline visualization
- Hide internal/sensitive project notes

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
