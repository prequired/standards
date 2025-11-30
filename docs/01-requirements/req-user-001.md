---
id: "REQ-USER-001"
title: "Staff User Profiles"
domain: "User Management"
status: approved
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-USER-001: Staff User Profiles

## Description

The system shall maintain detailed profiles for agency staff members, including personal information, role assignments, and work-related attributes.

## Rationale

Staff profiles enable proper identification, communication, and assignment of work. They also support client-facing features like team introductions and project contact information.

## Source

- **Stakeholder:** Operations Team, HR
- **Document:** Internal operations requirements

## Fit Criterion (Measurement)

- 100% of staff users have complete profiles
- Profile updates reflect immediately across the platform
- Profile photos meet size/format requirements (validated on upload)

## Dependencies

- **Depends On:** REQ-AUTH-001 (authentication), REQ-AUTH-004 (RBAC)
- **Blocks:** REQ-PROJ-001 (project assignment)
- **External:** Media storage for profile photos

## Satisfied By

- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md)

## Acceptance Criteria

1. Staff profile includes: name, email, phone, title, bio
2. Profile photo can be uploaded or linked from social auth
3. Staff can edit their own profile
4. Admins can edit any staff profile
5. Profile displays assigned roles and permissions
6. Profile shows active project assignments
7. Profile can be marked as public (visible on marketing site)
8. Deactivated staff profiles are hidden but retained

## Notes

- Consider integration with HR systems for larger agencies
- Profile completeness indicator encourages full data entry

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
