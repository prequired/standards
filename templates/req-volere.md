---
id: REQ-{DOMAIN}-{SEQUENCE}
title: {Brief requirement title}
domain: {Business domain (e.g., Authentication, Data, Payments)}
status: draft
priority: {critical | high | medium | low}
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: {Name or Team}
---

# REQ-{DOMAIN}-{SEQUENCE}: {Requirement Title}

## Description

A clear, unambiguous statement of what the system must do or what quality it must possess. Use active voice and measurable language.

**Example:**
"The system shall authenticate administrative users using multi-factor authentication (MFA) before granting access to the admin panel."

## Rationale

Explain why this requirement exists. Link to business objectives, regulatory constraints, or user needs.

**Example:**
"Administrative accounts have elevated privileges. MFA reduces the risk of credential compromise by requiring possession of a secondary authentication factor (e.g., TOTP device)."

## Source

Identify the origin of the requirement.

- **Stakeholder:** Name or role (e.g., "VP of Engineering", "Security Compliance Team")
- **Document:** Reference to business case, RFP, or regulation (e.g., "SOC 2 Type II Audit Requirements")

## Fit Criterion (Measurement)

Define how to objectively verify that this requirement has been satisfied. Use quantifiable metrics where possible.

**Example:**
- "100% of login attempts to `/admin/*` routes must enforce MFA verification."
- "MFA enrollment rate for admin users reaches 100% within 30 days of deployment."
- "Average MFA verification time is under 3 seconds (95th percentile)."

## Dependencies

List other requirements or external constraints that affect this requirement.

**Example:**
- **Depends On:** `REQ-AUTH-100` (User authentication infrastructure must be operational)
- **Blocks:** `REQ-AUDIT-201` (Audit logging cannot track admin actions without authentication)
- **External:** Integration with TOTP library (e.g., `pragmarx/google2fa`)

## Satisfied By

Link to architectural decisions or implementation artifacts that fulfill this requirement.

**Example:**
- [ADR-0008](../docs/03-decisions/adr-0008.md) - Selection of TOTP-based MFA Provider
- [ARCH-USER-SERVICE](../docs/02-architecture/arch-user-service.md) - Section 5.2 (Authentication Module)

## Acceptance Criteria

Specific, testable conditions that must be met for this requirement to be accepted by the product owner.

**Example:**
1. Admin users see MFA enrollment prompt on first login.
2. QR code for TOTP enrollment is displayed and scannable.
3. Invalid TOTP codes are rejected with clear error message.
4. Backup codes are generated and securely stored.
5. Session is established only after successful MFA verification.

## Notes

Additional context, edge cases, or assumptions.

**Example:**
- "SMS-based MFA is explicitly excluded due to SIM-swapping vulnerability (see ADR-0007)."
- "Grace period of 7 days allowed for MFA enrollment before enforcement."

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| YYYY-MM-DD | {Author}     | Initial draft                |
| YYYY-MM-DD | {Reviewer}   | Added fit criterion metrics  |
