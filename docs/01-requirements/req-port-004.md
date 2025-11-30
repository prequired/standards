---
id: "REQ-PORT-004"
title: "Payment from Portal"
domain: "Client Portal"
status: approved
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PORT-004: Payment from Portal

## Description

The system shall allow clients to pay invoices directly from the portal using online payment methods.

## Rationale

Portal payment is convenient for clients and accelerates cash collection for the agency.

## Source

- **Stakeholder:** Finance Team, Clients
- **Document:** Payment convenience requirements

## Fit Criterion (Measurement)

- Payment completion rate > 95%
- Payment confirms within 10 seconds
- Payment reduces days-sales-outstanding

## Dependencies

- **Depends On:** REQ-PORT-003 (invoice viewing), REQ-BILL-002 (payments), REQ-INTG-001 (Stripe)
- **Blocks:** None
- **External:** Stripe

## Satisfied By

- [ADR-0018: Client Portal Architecture](../03-decisions/adr-0018-client-portal-architecture.md)

## Acceptance Criteria

1. Pay button on unpaid invoices
2. Secure payment form (Stripe Elements)
3. Credit card and ACH options
4. Save payment method for future
5. One-click payment with saved method
6. Payment confirmation screen
7. Email receipt sent immediately
8. Invoice status updates to paid
9. Partial payment (if enabled)
10. Payment error handling with retry

## Notes

- Use Stripe Elements for PCI compliance
- Consider Apple Pay/Google Pay for mobile
- Auto-pay option for subscriptions

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
