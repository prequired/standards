---
id: "REQ-AUTH-003"
title: "Multi-Factor Authentication"
domain: "Authentication"
status: draft
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-AUTH-003: Multi-Factor Authentication

## Description

The system shall support multi-factor authentication (MFA) using time-based one-time passwords (TOTP) for enhanced account security.

## Rationale

Agency staff have access to sensitive client data and billing information. MFA significantly reduces the risk of account compromise from credential theft or phishing attacks.

## Source

- **Stakeholder:** Security Team, CTO
- **Document:** Security policy requirements

## Fit Criterion (Measurement)

- MFA verification completes in under 3 seconds
- 100% of staff accounts have MFA enabled (enforced policy)
- MFA is optional but encouraged for client accounts
- Backup codes are generated (8 codes minimum)
- Recovery flow exists for lost authenticator access

## Dependencies

- **Depends On:** REQ-AUTH-001 (base authentication)
- **Blocks:** None
- **External:** TOTP library (Google Authenticator compatible)

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Users can enable MFA from account settings
2. QR code displayed for authenticator app scanning
3. Manual entry code provided as alternative to QR
4. Setup requires verification of first TOTP code
5. Backup codes generated and displayed once
6. MFA prompt appears after password verification
7. "Trust this device" option available (30-day duration)
8. Admin can reset user MFA if locked out
9. MFA can be enforced per role (mandatory for staff)

## Notes

- Use Laravel Fortify for TOTP implementation
- Consider WebAuthn/passkeys as future enhancement
- SMS-based MFA explicitly excluded (SIM-swap vulnerability)

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
