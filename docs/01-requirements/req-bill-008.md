---
id: "REQ-BILL-008"
title: "Tax Calculation"
domain: "Billing"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-BILL-008: Tax Calculation

## Description

The system shall calculate applicable taxes on invoices based on client location and service type.

## Rationale

Accurate tax calculation ensures legal compliance and reduces manual accounting corrections.

## Source

- **Stakeholder:** Finance Team, Legal
- **Document:** Tax compliance requirements

## Fit Criterion (Measurement)

- Tax rates accurate per jurisdiction
- Tax calculation automatic on invoice
- Tax reports exportable for filing

## Dependencies

- **Depends On:** REQ-BILL-001 (invoices), REQ-USER-004 (client addresses)
- **Blocks:** None
- **External:** Tax calculation service (Stripe Tax, TaxJar)

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Automatic tax rate lookup by location
2. Multiple tax rates per invoice (state, local)
3. Tax-exempt status per client
4. Tax displayed as line item on invoice
5. Tax reports by period, jurisdiction
6. Digital services tax handling (EU VAT)
7. Tax settings configurable per jurisdiction
8. Override tax for special cases
9. Tax ID/VAT number on invoices
10. Nexus determination for US sales tax

## Notes

- Stripe Tax recommended for automatic calculation
- Complexity varies: US sales tax vs EU VAT
- Consider tax advisor input on requirements

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
