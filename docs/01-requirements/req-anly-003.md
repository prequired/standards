---
id: "REQ-ANLY-003"
title: "Project Profitability Analysis"
domain: "Analytics"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-ANLY-003: Project Profitability Analysis

## Description

The system shall track and report on project profitability by comparing revenue to time/costs invested.

## Rationale

Understanding project profitability enables better pricing, scope management, and resource allocation.

## Source

- **Stakeholder:** Operations Team, Leadership
- **Document:** Profitability tracking requirements

## Fit Criterion (Measurement)

- Profitability calculated for 100% of billable projects
- Real-time updates as time is logged
- Alerts for projects trending unprofitable

## Dependencies

- **Depends On:** REQ-PROJ-001 (projects), REQ-PROJ-005 (time tracking), REQ-BILL-001 (invoices)
- **Blocks:** None
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Calculate revenue per project
2. Calculate time cost per project
3. Calculate profit margin per project
4. Compare actual vs estimated hours
5. Profitability by project type
6. Profitability by client
7. Identify most/least profitable projects
8. Trend analysis over time
9. Alert for over-budget projects
10. Factor in team member cost rates

## Notes

- Requires time tracking (REQ-PROJ-005) for accurate data
- Consider blended vs individual cost rates
- May be sensitive - restrict access appropriately

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
