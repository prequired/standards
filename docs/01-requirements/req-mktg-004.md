---
id: "REQ-MKTG-004"
title: "Contact Form"
domain: "Marketing"
status: approved
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-MKTG-004: Contact Form

## Description

The system shall provide a contact form for general inquiries from website visitors.

## Rationale

Contact forms capture visitor inquiries when they're ready to reach out, feeding the sales pipeline.

## Source

- **Stakeholder:** Sales Team
- **Document:** Lead generation requirements

## Fit Criterion (Measurement)

- Form submission succeeds 99%+ of time
- Submissions delivered within 30 seconds
- Spam rate under 1%

## Dependencies

- **Depends On:** REQ-INTG-002 (email), REQ-COMM-002 (email notifications)
- **Blocks:** None
- **External:** Email service, spam protection

## Satisfied By

- [ADR-0017: Marketing Site Architecture](../03-decisions/adr-0017-marketing-site-architecture.md)

## Acceptance Criteria

1. Fields: name, email, phone (optional), message
2. Form validation with clear errors
3. Honeypot spam protection
4. reCAPTCHA for additional protection
5. Confirmation message on submit
6. Email notification to sales team
7. Auto-response email to submitter
8. Submissions stored in database
9. Submission dashboard in admin
10. GDPR consent checkbox

## Notes

- Keep form fields minimal to reduce friction
- Consider progressive form for more info
- Integrate with CRM if available

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
