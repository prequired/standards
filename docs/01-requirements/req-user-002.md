---
id: "REQ-USER-002"
title: "Client User Profiles"
domain: "User Management"
status: approved
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-USER-002: Client User Profiles

## Description

The system shall maintain profiles for client users, including contact information and association with their client organization.

## Rationale

Client profiles enable personalized portal experiences, targeted communications, and proper access scoping to their organization's projects and data.

## Source

- **Stakeholder:** Account Management Team
- **Document:** Client relationship requirements

## Fit Criterion (Measurement)

- 100% of client users are associated with a client organization
- Client profiles include minimum required fields (name, email)
- Profile changes are logged for audit purposes

## Dependencies

- **Depends On:** REQ-AUTH-001 (authentication), REQ-USER-004 (client organizations)
- **Blocks:** REQ-PORT-001 (client portal)
- **External:** None

## Satisfied By

- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md)

## Acceptance Criteria

1. Client profile includes: name, email, phone, title
2. Client is associated with exactly one organization
3. Clients can edit their own profile
4. Agency staff can edit client profiles
5. Multiple clients can belong to same organization
6. Client profile shows accessible projects
7. Client can set notification preferences
8. Inactive clients can be deactivated (retain data)

## Notes

- Consider "primary contact" designation per organization
- Client profile is simpler than staff profile (less fields)

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
