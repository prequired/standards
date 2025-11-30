---
id: "REQ-AUTH-005"
title: "Client vs Staff Permission Separation"
domain: "Authentication"
status: approved
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-AUTH-005: Client vs Staff Permission Separation

## Description

The system shall enforce strict separation between client and staff user types, ensuring clients can only access their own data and designated portal features.

## Rationale

Clients must never access internal agency operations, other clients' data, or administrative functions. This separation is fundamental to the multi-tenant security model.

## Source

- **Stakeholder:** CTO, Legal Team
- **Document:** Data privacy and security policy

## Fit Criterion (Measurement)

- 0% of client requests can access other clients' data
- 0% of client requests can access staff-only features
- Penetration testing confirms isolation (quarterly)
- All cross-tenant access attempts are logged and alerted

## Dependencies

- **Depends On:** REQ-AUTH-004 (RBAC)
- **Blocks:** REQ-PORT-001 (Client Portal)
- **External:** None

## Satisfied By

- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md)
- [ADR-0012: Security & Data Protection](../03-decisions/adr-0012-security-data-protection.md)

## Acceptance Criteria

1. Client users are associated with a client organization
2. Clients can only view projects assigned to their organization
3. Clients cannot access staff dashboard or admin features
4. Clients cannot view other clients' data (invoices, projects, files)
5. Staff can switch context to view as specific client (impersonation)
6. Impersonation is logged with staff user ID
7. URL manipulation cannot bypass client isolation
8. API endpoints enforce client scoping on all queries

## Notes

- Implement using global query scopes in Eloquent
- Consider Laravel's built-in authorization policies
- Add automated tests for cross-tenant access attempts

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
