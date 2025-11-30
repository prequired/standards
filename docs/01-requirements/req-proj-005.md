---
id: "REQ-PROJ-005"
title: "Time Tracking"
domain: "Project Management"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PROJ-005: Time Tracking

## Description

The system shall support time tracking against projects and tasks for billing, reporting, and resource management.

## Rationale

Accurate time tracking enables hourly billing, profitability analysis, and estimation improvements for future projects.

## Source

- **Stakeholder:** Finance Team, Project Managers
- **Document:** Billing and operations requirements

## Fit Criterion (Measurement)

- Time entries can be created in under 5 seconds
- Time data is accurate to the minute
- Weekly timesheet completion rate > 95%

## Dependencies

- **Depends On:** REQ-PROJ-001 (projects), REQ-PROJ-003 (tasks)
- **Blocks:** REQ-BILL-001 (time-based invoicing)
- **External:** None (custom build per ADR-0006)

## Satisfied By

- [ADR-0006: Time Tracking](../03-decisions/adr-0006-time-tracking.md)

## Acceptance Criteria

1. Staff can log time against projects
2. Time entries include: duration, date, description
3. Time can be linked to specific tasks
4. Timer functionality for real-time tracking
5. Manual time entry for past work
6. Weekly timesheet view
7. Time entries marked as billable/non-billable
8. Billable rate configurable per project/user
9. Time reports by project, user, date range
10. Time approval workflow (optional)

## Notes

- Strong candidate for "buy" decision (Toggl, Harvest)
- Consider integration over build for mature tracking
- Mobile app support important for on-the-go tracking

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
