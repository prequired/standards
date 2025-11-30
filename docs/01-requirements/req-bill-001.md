---
id: "REQ-BILL-001"
title: "Invoice Generation"
domain: "Billing"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-BILL-001: Invoice Generation

## Description

The system shall support creation and management of invoices for client billing, including line items, taxes, and discounts.

## Rationale

Invoicing is essential for agency cash flow. Integrated invoicing reduces manual effort and connects billing to project work.

## Source

- **Stakeholder:** Finance Team
- **Document:** Financial operations requirements

## Fit Criterion (Measurement)

- Invoice generation in under 5 seconds
- Invoice accuracy: 100% (correct calculations)
- Invoice number sequence maintained

## Dependencies

- **Depends On:** REQ-USER-004 (client companies), REQ-PROJ-001 (projects)
- **Blocks:** REQ-BILL-002 (payments), REQ-BILL-004 (PDF), REQ-PORT-003 (client invoice view)
- **External:** None (or integration with accounting software)

## Satisfied By

- *ADR needed: Build custom vs integrate Stripe Invoicing/FreshBooks*

## Acceptance Criteria

1. Create invoices linked to client/project
2. Add line items with description, quantity, rate
3. Calculate subtotals, taxes, totals automatically
4. Support discounts (percentage or fixed)
5. Invoice numbering (configurable format)
6. Invoice status (draft, sent, viewed, paid, overdue)
7. Due date with configurable payment terms
8. Multiple tax rates supported
9. Invoice notes/terms field
10. Invoice duplication for recurring

## Notes

- Consider Stripe Invoicing for tight payment integration
- May need integration with QuickBooks/Xero for accounting

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
