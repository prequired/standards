---
id: "REQ-USER-005"
title: "User Invitation System"
domain: "User Management"
status: draft
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-USER-005: User Invitation System

## Description

The system shall allow administrators and authorized users to invite new users via email, with role and organization pre-assignment.

## Rationale

Controlled user creation via invitations ensures proper onboarding, role assignment, and prevents unauthorized account creation.

## Source

- **Stakeholder:** Operations Team
- **Document:** User management requirements

## Fit Criterion (Measurement)

- Invitation emails delivered within 30 seconds
- Invitation links expire after 7 days
- 80% of invitations are accepted within 48 hours
- Pending invitations are visible in admin dashboard

## Dependencies

- **Depends On:** REQ-AUTH-001 (authentication), REQ-INTG-002 (email service)
- **Blocks:** None
- **External:** Email delivery service

## Satisfied By

- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md)

## Acceptance Criteria

1. Admins can invite new staff users
2. Staff can invite new client users (to their projects)
3. Invitation specifies role and organization
4. Invitation email contains secure registration link
5. Accepting invitation creates account with pre-set role
6. Expired invitations can be resent
7. Pending invitations can be revoked
8. Bulk invitation via CSV upload supported
9. Invitation includes optional personal message

## Notes

- Consider auto-invitation when adding client to project
- Track invitation conversion rates for funnel analysis

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
