---
id: "REQ-ANLY-002"
title: "Revenue Reports"
domain: "Analytics"
status: approved
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-ANLY-002: Revenue Reports

## Description

The system shall generate revenue reports showing income by period, client, project, and service type.

## Rationale

Revenue reporting is essential for financial planning, tax preparation, and business analysis.

## Source

- **Stakeholder:** Finance Team, Leadership
- **Document:** Financial reporting requirements

## Fit Criterion (Measurement)

- Reports generate in under 30 seconds
- Data matches accounting records
- Reports exportable to Excel/CSV

## Dependencies

- **Depends On:** REQ-BILL-001 (invoices), REQ-BILL-005 (payments)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0013: Analytics & Reporting](../03-decisions/adr-0013-analytics-reporting.md)

## Acceptance Criteria

1. Revenue by month/quarter/year
2. Revenue by client
3. Revenue by project
4. Revenue by service type
5. Comparison to previous periods
6. Invoiced vs collected views
7. Recurring vs one-time revenue
8. Revenue trend charts
9. Export to CSV/Excel
10. Scheduled report delivery (email)

## Notes

- Consider integration with accounting software for reconciliation
- MRR/ARR tracking for subscription revenue
- May need custom fiscal year support

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
