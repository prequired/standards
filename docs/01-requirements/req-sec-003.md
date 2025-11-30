---
id: "REQ-SEC-003"
title: "CSRF Protection"
domain: "Security"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-SEC-003: CSRF Protection

## Description

The system shall protect against Cross-Site Request Forgery attacks on all state-changing operations.

## Rationale

CSRF protection prevents attackers from tricking authenticated users into performing unintended actions.

## Source

- **Stakeholder:** Security Team
- **Document:** OWASP Top 10 compliance

## Fit Criterion (Measurement)

- 100% of POST/PUT/DELETE requests validate CSRF token
- CSRF attacks blocked with 419 response
- No bypass vulnerabilities

## Dependencies

- **Depends On:** REQ-AUTH-006 (sessions)
- **Blocks:** None
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. CSRF middleware enabled globally
2. CSRF token included in all forms
3. CSRF token validated on submission
4. SameSite cookie attribute set
5. API routes use token authentication instead
6. AJAX requests include CSRF header
7. Token regeneration on authentication
8. Clear error message on CSRF failure
9. No exclusions without security review
10. Penetration testing validates protection

## Notes

- Laravel includes CSRF protection by default
- Ensure SameSite=Lax or Strict on cookies
- Document any intentional exclusions

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
