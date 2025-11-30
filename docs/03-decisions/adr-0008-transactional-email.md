---
id: "ADR-0008"
title: "Transactional Email Service Selection"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-INTG-002"
decision_makers: "Platform Team"
consulted: "Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0008: Transactional Email Service Selection

## Context and Problem Statement

[REQ-INTG-002](../01-requirements/req-intg-002.md) requires integration with an email service for transactional emails including notifications, password resets, invoice delivery, and system alerts.

Transactional emails are system-triggered (not marketing campaigns) and require high deliverability, fast delivery, and reliable tracking. These include:
- Password reset emails
- Invoice delivery
- Payment confirmations
- Project notifications
- Support ticket updates

## Decision Drivers

- **Deliverability:** Emails must reach inbox, not spam
- **Speed:** Transactional emails should deliver in seconds
- **Reliability:** Critical for password resets and payment confirmations
- **Laravel Integration:** Native Laravel mail driver support
- **Cost:** Predictable pricing at scale
- **Tracking:** Delivery status, bounces, opens for debugging

## Considered Options

1. **Option A:** Use application server SMTP (sendmail/postfix)
2. **Option B:** Amazon SES
3. **Option C:** Postmark
4. **Option D:** Resend
5. **Option E:** SendGrid

## Decision Outcome

**Chosen Option:** Option C - Postmark

**Justification:** Postmark specializes in transactional email with:
- Industry-leading deliverability (dedicated transactional IP pools)
- Sub-second delivery times
- Excellent Laravel integration (first-party driver)
- Transparent pricing ($1.25 per 1,000 emails)
- Delivery tracking and analytics
- Bounce/spam handling built-in

Postmark's focus on transactional (not marketing) email means better deliverability for critical system emails.

### Consequences

#### Positive

- Best-in-class deliverability for transactional emails
- Fast delivery (typically under 1 second)
- Laravel mail driver available
- Simple API and webhook support
- Dedicated IP addresses at scale
- Message streams for organization

#### Negative

- Not suitable for marketing email (different service: ADR-0007)
- Pay-per-email costs (though reasonable)
- Email content passes through third party
- Requires DNS configuration (SPF, DKIM)

#### Risks

- **Risk:** Service outage affects critical emails (password reset)
  - **Mitigation:** Postmark has excellent uptime history; can configure fallback driver
- **Risk:** Costs grow unexpectedly with email volume
  - **Mitigation:** Monitor usage; Postmark pricing is predictable and reasonable
- **Risk:** Email content privacy concerns
  - **Mitigation:** Postmark is GDPR compliant; review their security practices

## Validation

- **Metric 1:** 99%+ email deliverability rate
- **Metric 2:** Email delivery time under 10 seconds (95th percentile)
- **Metric 3:** Bounce rate under 2%
- **Metric 4:** Zero missed password reset emails

## Pros and Cons of the Options

### Option A: Server SMTP

**Pros:**
- No third-party costs
- Full control
- No API dependencies

**Cons:**
- Deliverability nightmare (shared IP reputation)
- Must manage bounce handling
- IP warming required
- Likely to hit spam filters
- No tracking/analytics

### Option B: Amazon SES

**Pros:**
- Very low cost ($0.10/1,000 emails)
- AWS integration
- High sending limits
- Reliable infrastructure

**Cons:**
- Requires reputation management
- Setup more complex
- Support is AWS-typical (minimal)
- Not specialized for transactional

### Option C: Postmark

**Pros:**
- Transactional email specialist
- Excellent deliverability
- Fast delivery
- Great Laravel support
- Good documentation

**Cons:**
- Higher cost than SES
- Transactional only (no marketing)
- Another vendor to manage

### Option D: Resend

**Pros:**
- Modern developer experience
- React email templates
- Simple API
- Growing platform

**Cons:**
- Newer company (less proven)
- Smaller scale history
- Fewer enterprise features

### Option E: SendGrid

**Pros:**
- Large scale capability
- Both transactional and marketing
- Good documentation

**Cons:**
- Deliverability varies (shared with marketing)
- Complex pricing tiers
- Support quality inconsistent
- UI has become bloated

## Implementation Notes

- Install Postmark Laravel driver: `composer require postmark/postmark-laravel`
- Configure in `.env`: `MAIL_MAILER=postmark`, `POSTMARK_TOKEN=xxx`
- Set up DNS records: SPF, DKIM (Postmark provides these)
- Configure sender signature in Postmark dashboard
- Create message streams: `notifications`, `invoices`, `auth`
- Set up webhook for bounce/spam handling
- Use Laravel Mailables with Postmark templates for consistency
- Configure fallback mailer for resilience

## Links

- [REQ-INTG-002](../01-requirements/req-intg-002.md) - Email Service Integration
- [REQ-COMM-002](../01-requirements/req-comm-002.md) - Email Notifications
- [REQ-AUTH-007](../01-requirements/req-auth-007.md) - Password Reset Flow
- [REQ-BILL-004](../01-requirements/req-bill-004.md) - Invoice PDF Generation
- [ADR-0007](./adr-0007-email-marketing.md) - Email Marketing (separate service)
- [Postmark Laravel Documentation](https://postmarkapp.com/developer/integration/official-libraries#laravel)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
