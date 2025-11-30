---
id: "REQ-USER-004"
title: "Client Company Accounts"
domain: "User Management"
status: draft
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-USER-004: Client Company Accounts

## Description

The system shall support client organizations as distinct entities, allowing multiple client users and projects to be associated with a single company account.

## Rationale

B2B agencies work with companies, not individuals. Company accounts enable proper billing, project grouping, and multi-user access for client organizations.

## Source

- **Stakeholder:** Account Management, Finance Team
- **Document:** Client management requirements

## Fit Criterion (Measurement)

- 100% of clients are associated with a company account
- 100% of projects are associated with a company account
- Company billing information is complete for all active clients

## Dependencies

- **Depends On:** REQ-AUTH-001 (authentication)
- **Blocks:** REQ-USER-002 (client profiles), REQ-BILL-001 (invoicing)
- **External:** None

## Satisfied By

- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md)

## Acceptance Criteria

1. Company account includes: name, address, billing info
2. Company can have multiple associated client users
3. Company can have multiple associated projects
4. Primary contact designated for communications
5. Billing contact can differ from primary contact
6. Company has status (prospect, active, inactive, churned)
7. Company-level notes and history visible to staff
8. Company logo can be uploaded
9. Staff can view all companies in directory

## Notes

- This is the core "tenant" concept for multi-tenancy
- Consider CRM integration (HubSpot, Salesforce) in future

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
