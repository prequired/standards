---
id: "REQ-INTG-002"
title: "Email Service Integration"
domain: "Integrations"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-INTG-002: Email Service Integration

## Description

The system shall integrate with a transactional email service for reliable delivery of system emails.

## Rationale

Dedicated email service ensures high deliverability, proper authentication (SPF/DKIM), and delivery analytics.

## Source

- **Stakeholder:** Operations Team
- **Document:** Email infrastructure requirements

## Fit Criterion (Measurement)

- Email delivery rate > 99%
- Delivery within 30 seconds
- Bounce and complaint handling automated

## Dependencies

- **Depends On:** None
- **Blocks:** REQ-COMM-002 (email notifications), REQ-AUTH-007 (password reset)
- **External:** Email service provider

## Satisfied By

- [ADR-0008: Transactional Email](../03-decisions/adr-0008-transactional-email.md)

## Acceptance Criteria

1. API integration with email provider
2. Email templates support (MJML/HTML)
3. SPF and DKIM configured for domain
4. Bounce handling and list cleanup
5. Delivery and open tracking
6. Failed delivery retries
7. Webhook for delivery events
8. Test email functionality
9. Email logs viewable in admin
10. Separate streams for transactional vs marketing

## Notes

- Postmark recommended for transactional (best deliverability)
- SendGrid or ConvertKit for marketing emails
- Never use default PHP mail()

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
