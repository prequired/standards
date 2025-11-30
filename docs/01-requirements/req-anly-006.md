---
id: "REQ-ANLY-006"
title: "Team Utilization Reports"
domain: "Analytics"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-ANLY-006: Team Utilization Reports

## Description

The system shall report on team member utilization rates based on billable hours vs capacity.

## Rationale

Utilization tracking enables capacity planning, identifies overwork, and supports hiring decisions.

## Source

- **Stakeholder:** Operations Team, HR
- **Document:** Resource management requirements

## Fit Criterion (Measurement)

- Utilization calculated accurately
- Reports available by week/month
- Target utilization configurable

## Dependencies

- **Depends On:** REQ-PROJ-005 (time tracking), REQ-USER-001 (staff profiles)
- **Blocks:** None
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Billable hours per team member
2. Non-billable hours tracked
3. Capacity hours configurable
4. Utilization percentage calculation
5. Utilization by week/month
6. Team-wide utilization view
7. Individual utilization trends
8. Target utilization comparison
9. Availability forecasting
10. Workload distribution visualization

## Notes

- Requires accurate time tracking
- Consider 8-hour days, 40-hour weeks as default capacity
- Handle PTO/holidays in calculations

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
