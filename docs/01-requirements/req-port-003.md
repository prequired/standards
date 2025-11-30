---
id: "REQ-PORT-003"
title: "Invoice Viewing"
domain: "Client Portal"
status: draft
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PORT-003: Invoice Viewing

## Description

The system shall allow clients to view all their invoices, including details and payment status.

## Rationale

Self-service invoice access reduces support requests and empowers clients to manage their account.

## Source

- **Stakeholder:** Finance Team, Clients
- **Document:** Client self-service requirements

## Fit Criterion (Measurement)

- All client invoices accessible
- Invoice details complete and accurate
- PDF download available

## Dependencies

- **Depends On:** REQ-BILL-001 (invoices), REQ-AUTH-005 (separation)
- **Blocks:** REQ-PORT-004 (payment)
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. List all invoices for client
2. Invoice status (pending, paid, overdue)
3. Invoice date and due date
4. Invoice amount and balance due
5. View invoice details
6. Download PDF invoice
7. Filter by status, date range
8. Payment history per invoice
9. Outstanding balance summary
10. Invoice dispute/question button

## Notes

- Clients should only see their own invoices
- Include payment link for unpaid invoices
- Show payment terms and late fee policy

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
