---
id: "REQ-BILL-007"
title: "Multiple Payment Methods"
domain: "Billing"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-BILL-007: Multiple Payment Methods

## Description

The system shall support multiple payment methods including credit cards, ACH bank transfers, and digital wallets.

## Rationale

Different clients prefer different payment methods. Supporting multiple options increases payment convenience and success rates.

## Source

- **Stakeholder:** Finance Team, Clients
- **Document:** Payment flexibility requirements

## Fit Criterion (Measurement)

- At least 3 payment methods supported
- ACH reduces processing fees by 2%+
- Payment method selection clear in UI

## Dependencies

- **Depends On:** REQ-BILL-002 (payment processing), REQ-INTG-001 (Stripe)
- **Blocks:** None
- **External:** Stripe (supports all methods)

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Credit/debit card payments (Visa, MC, Amex)
2. ACH bank transfer (US)
3. Apple Pay / Google Pay
4. Clients can save payment methods
5. Default payment method for subscriptions
6. Clear display of available methods
7. Method-specific processing times communicated
8. Failed payment retry with alternate method
9. Wire transfer instructions for large invoices
10. International payment support considerations

## Notes

- ACH has lower fees but slower (3-5 days)
- Wire transfer for invoices over threshold (e.g., $10k)
- Consider regional methods (SEPA for EU)

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
