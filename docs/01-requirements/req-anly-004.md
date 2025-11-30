---
id: "REQ-ANLY-004"
title: "Client Activity Reports"
domain: "Analytics"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-ANLY-004: Client Activity Reports

## Description

The system shall track and report on client engagement and activity within the portal.

## Rationale

Understanding client engagement helps identify at-risk relationships and opportunities for upselling.

## Source

- **Stakeholder:** Account Management
- **Document:** Client success requirements

## Fit Criterion (Measurement)

- Activity tracked for all client actions
- Reports available per client
- Inactive client alerts generated

## Dependencies

- **Depends On:** REQ-PORT-001 (portal), REQ-SEC-005 (audit logging)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0013: Analytics & Reporting](../03-decisions/adr-0013-analytics-reporting.md)

## Acceptance Criteria

1. Track portal logins per client
2. Track file downloads
3. Track invoice views/payments
4. Track feedback submissions
5. Last activity date per client
6. Engagement score calculation
7. Inactive client alerts
8. Activity timeline per client
9. Aggregate activity reports
10. Client health scoring

## Notes

- Use for proactive client outreach
- Consider privacy implications
- May integrate with CRM for relationship management

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
