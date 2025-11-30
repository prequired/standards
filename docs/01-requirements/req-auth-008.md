---
id: "REQ-AUTH-008"
title: "Magic Link Authentication"
domain: "Authentication"
status: draft
priority: low
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-AUTH-008: Magic Link Authentication

## Description

The system shall optionally support passwordless authentication via magic links sent to the user's email.

## Rationale

Magic links provide a frictionless login experience, especially for infrequent users (clients) who may not remember passwords. Reduces support burden for password resets.

## Source

- **Stakeholder:** UX Team
- **Document:** User experience improvement initiative

## Fit Criterion (Measurement)

- Magic link email delivered within 30 seconds
- Magic link tokens expire after 15 minutes
- Magic links are single-use
- 90% of magic link logins complete successfully

## Dependencies

- **Depends On:** REQ-AUTH-001 (base authentication), REQ-INTG-002 (email service)
- **Blocks:** None
- **External:** Email delivery service

## Satisfied By

- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md)
- [ADR-0012: Security & Data Protection](../03-decisions/adr-0012-security-data-protection.md)

## Acceptance Criteria

1. "Email me a login link" option on login page
2. User enters email address
3. Magic link email sent with secure token
4. Clicking link authenticates user immediately
5. Token is invalidated after use
6. Expired tokens show clear error with retry option
7. Option can be disabled per-user or globally
8. Works alongside password authentication (not replacement)

## Notes

- Consider for Phase 2 implementation
- May be especially useful for client portal access
- Evaluate security trade-offs vs password authentication

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
