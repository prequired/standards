---
id: "REQ-PROJ-002"
title: "Project Status Tracking"
domain: "Project Management"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PROJ-002: Project Status Tracking

## Description

The system shall track and display project status, progress, and health indicators for both staff and client visibility.

## Rationale

Transparent status tracking builds client trust, enables proactive management, and provides data for operational improvements.

## Source

- **Stakeholder:** Project Managers, Clients
- **Document:** Client experience requirements

## Fit Criterion (Measurement)

- Status updates reflect in under 1 second
- Status visible on client portal dashboard
- Historical status changes are logged

## Dependencies

- **Depends On:** REQ-PROJ-001 (project management)
- **Blocks:** REQ-PORT-002 (client project visibility)
- **External:** None

## Satisfied By

- [ADR-0001: Project Management Tool](../03-decisions/adr-0001-project-management-tool.md)

## Acceptance Criteria

1. Projects have defined status values
2. Status can be updated by authorized staff
3. Status changes are timestamped and attributed
4. Status history is viewable
5. Visual indicators (colors, icons) represent status
6. Clients see appropriate status in portal
7. Optional: percentage complete indicator
8. Optional: health indicator (on-track, at-risk, blocked)
9. Status change triggers notifications

## Notes

- Status workflow may differ by project type
- Consider client-friendly vs internal status values

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
