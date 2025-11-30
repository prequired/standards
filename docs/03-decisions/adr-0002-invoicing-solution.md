---
id: "ADR-0002"
title: "Invoicing Solution Selection"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-BILL-001, REQ-BILL-004"
decision_makers: "Platform Team"
consulted: "Finance, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0002: Invoicing Solution Selection

## Context and Problem Statement

[REQ-BILL-001](../01-requirements/req-bill-001.md) requires invoice generation with line items, taxes, discounts, and multiple currencies. [REQ-BILL-004](../01-requirements/req-bill-004.md) requires professional PDF invoice generation with branding.

The platform must generate invoices that integrate with time tracking, project deliverables, and Stripe payments. Invoices must be viewable in the client portal and downloadable as PDFs.

## Decision Drivers

- **Integration:** Must pull data from projects, time entries, and subscriptions automatically
- **PDF Quality:** Professional, branded invoices matching agency identity
- **Payment Integration:** Direct link to Stripe checkout (REQ-INTG-001)
- **Tax Handling:** Support for multiple tax rates and jurisdictions (REQ-BILL-008)
- **Recurring Invoices:** Support subscription billing (REQ-BILL-003)
- **Compliance:** Must meet accounting/legal requirements for invoices

## Considered Options

1. **Option A:** Build custom invoicing with Laravel + PDF generation
2. **Option B:** Stripe Invoicing (native Stripe feature)
3. **Option C:** Integrate FreshBooks
4. **Option D:** Integrate QuickBooks Online
5. **Option E:** Use Laravel Cashier + custom invoice templates

## Decision Outcome

**Chosen Option:** Option E - Laravel Cashier + Custom Invoice Templates

**Justification:** Laravel Cashier already provides Stripe integration for subscriptions and one-time payments. By extending Cashier with custom invoice templates (using DomPDF or Browsershot), we get:
- Native Stripe payment integration (already required by REQ-INTG-001)
- Full control over invoice design and branding
- Direct database access for line items from projects/time tracking
- No additional SaaS costs beyond Stripe fees
- Subscription management included via Cashier

### Consequences

#### Positive

- Unified codebase: invoicing logic lives with project/time data
- Cashier handles Stripe webhooks, subscription lifecycle, payment methods
- Full customization of invoice appearance and workflow
- No per-invoice or per-customer fees beyond Stripe processing
- Invoice data available for custom reporting (REQ-ANLY-003)

#### Negative

- Must build PDF generation (DomPDF or Browsershot)
- Tax calculation logic must be implemented (or use tax API)
- No built-in accounting features (journal entries, reconciliation)
- Requires manual handling of invoice numbering, due dates, reminders

#### Risks

- **Risk:** Invoice PDF rendering inconsistencies across browsers/systems
  - **Mitigation:** Use Browsershot (headless Chrome) for consistent PDF output
- **Risk:** Tax calculation complexity for international clients
  - **Mitigation:** Integrate tax calculation service (TaxJar, Avalara) if needed; start with simple rates
- **Risk:** Accounting sync may require additional work
  - **Mitigation:** Export invoices in format compatible with accounting software (ADR-0006)

## Validation

- **Metric 1:** Invoice PDF generated in under 3 seconds
- **Metric 2:** Zero invoice numbering collisions (unique sequential IDs)
- **Metric 3:** Payment success rate matches Stripe dashboard (no integration errors)
- **Metric 4:** Client invoice view to payment completion under 60 seconds

## Pros and Cons of the Options

### Option A: Build Custom (No Cashier)

**Pros:**
- Maximum flexibility
- No dependencies

**Cons:**
- Must implement Stripe integration from scratch
- Subscription lifecycle management is complex
- Reinventing well-solved problems

### Option B: Stripe Invoicing

**Pros:**
- Native Stripe integration
- Professional invoice templates
- Automatic payment reminders
- Tax calculation (Stripe Tax)

**Cons:**
- Limited customization of invoice appearance
- Invoice data lives in Stripe, not local database
- 0.4-0.5% additional fee per invoice
- Cannot easily add custom line items from projects

### Option C: FreshBooks Integration

**Pros:**
- Full accounting suite (expenses, reports)
- Professional invoices
- Time tracking included

**Cons:**
- Per-user pricing ($15-55/month)
- Requires API sync for project data
- Duplicate data management
- Overkill if only invoicing needed

### Option D: QuickBooks Online

**Pros:**
- Industry-standard accounting
- Bank reconciliation
- Tax preparation features

**Cons:**
- Complex integration (Intuit API)
- Per-company pricing ($30-200/month)
- Accounting-focused, not agency-focused
- Steep learning curve for non-accountants

### Option E: Laravel Cashier + Custom Templates

**Pros:**
- Stripe integration included
- Subscription management built-in
- Full control over invoice design
- No additional costs

**Cons:**
- PDF generation must be built
- Tax logic must be implemented
- No accounting features

## Implementation Notes

- Install `laravel/cashier` for Stripe integration
- Use `barryvdh/laravel-dompdf` or `spatie/browsershot` for PDF generation
- Create `Invoice` model with relationships to `Project`, `TimeEntry`, `Subscription`
- Implement sequential invoice numbering with prefix (INV-2025-0001)
- Store invoice line items in `invoice_items` table for flexibility
- Create Blade templates for invoice PDF and email versions
- Use Stripe webhooks for payment status updates (Cashier handles this)

## Links

- [REQ-BILL-001](../01-requirements/req-bill-001.md) - Invoice Generation
- [REQ-BILL-004](../01-requirements/req-bill-004.md) - Invoice PDF Generation
- [REQ-INTG-001](../01-requirements/req-intg-001.md) - Stripe Payment Integration
- [REQ-BILL-003](../01-requirements/req-bill-003.md) - Subscription Management
- [Laravel Cashier Documentation](https://laravel.com/docs/billing)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
