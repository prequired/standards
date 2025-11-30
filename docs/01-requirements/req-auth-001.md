---
id: "REQ-AUTH-001"
title: "User Authentication (Email/Password)"
domain: "Authentication"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-AUTH-001: User Authentication (Email/Password)

## Description

The system shall authenticate users using email address and password credentials before granting access to protected resources.

## Rationale

Email/password authentication is the standard baseline authentication method expected by all users. It provides a familiar, accessible entry point for both agency staff and clients.

## Source

- **Stakeholder:** Platform Team
- **Document:** Core platform security requirements

## Fit Criterion (Measurement)

- 100% of protected routes require successful authentication
- Login form submission to dashboard access completes in under 2 seconds
- Failed login attempts are logged with IP address and timestamp
- Account lockout triggers after 5 consecutive failed attempts within 15 minutes

## Dependencies

- **Depends On:** None (foundational requirement)
- **Blocks:** REQ-AUTH-003 (MFA), REQ-AUTH-004 (RBAC), REQ-PORT-001 (Client Dashboard)
- **External:** Email service for verification emails

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Users can register with email and password
2. Email verification is required before first login
3. Users can log in with verified email and correct password
4. Invalid credentials display generic error message (security)
5. Successful login creates authenticated session
6. Session persists across browser tabs
7. "Remember me" option extends session duration

## Notes

- Recommend using Laravel Breeze or Jetstream for implementation
- Password requirements: minimum 8 characters, mixed case, numbers
- Consider implementing breach detection (HaveIBeenPwned API)

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
