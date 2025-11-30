---
id: "REQ-BILL-006"
title: "Automated Invoice Reminders"
domain: "Billing"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-BILL-006: Automated Invoice Reminders

## Description

The system shall send automated reminder emails for unpaid invoices based on configurable schedules.

## Rationale

Automated reminders improve collection rates by prompting clients before and after due dates without manual follow-up.

## Source

- **Stakeholder:** Finance Team
- **Document:** Collections process requirements

## Fit Criterion (Measurement)

- Reminders sent on schedule
- Reminder reduces average days-to-pay
- Reminder emails not marked as spam

## Dependencies

- **Depends On:** REQ-BILL-001 (invoices), REQ-COMM-002 (email)
- **Blocks:** None
- **External:** Email service

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Configure reminder schedule (e.g., 3 days before, day of, 7 days after)
2. Reminder emails professionally worded
3. Reminder includes payment link
4. Reminders stop when invoice paid
5. Escalating urgency in message tone
6. Skip reminder for specific invoices
7. Reminder history logged
8. Staff notified of persistently overdue
9. Customizable reminder templates
10. Batch reminder for multiple overdue

## Notes

- Typically: 3 days before, due date, 7 days after, 14 days after
- Final reminder should mention potential actions

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
