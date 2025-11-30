---
id: "REQ-ANLY-001"
title: "Staff Dashboard with KPIs"
domain: "Analytics"
status: draft
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-ANLY-001: Staff Dashboard with KPIs

## Description

The system shall provide a dashboard for agency staff showing key performance indicators and operational metrics.

## Rationale

Visibility into business metrics enables data-driven decisions, early problem detection, and performance tracking.

## Source

- **Stakeholder:** Operations Team, Leadership
- **Document:** Business intelligence requirements

## Fit Criterion (Measurement)

- Dashboard loads in under 3 seconds
- KPIs update at least daily
- Data is accurate within 24 hours

## Dependencies

- **Depends On:** REQ-PROJ-001 (projects), REQ-BILL-001 (invoices)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0013: Analytics & Reporting](../03-decisions/adr-0013-analytics-reporting.md)

## Acceptance Criteria

1. Dashboard shows active project count
2. Dashboard shows revenue metrics (MTD, YTD)
3. Dashboard shows outstanding invoices total
4. Dashboard shows project health overview
5. Dashboard shows team utilization (if time tracking)
6. Charts and visualizations for trends
7. Configurable date range filters
8. Role-based dashboard views
9. Widget customization (optional)
10. Mobile-responsive dashboard

## Notes

- Consider different dashboards for different roles
- Start with essential metrics, expand based on feedback
- May use Filament dashboard components

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
