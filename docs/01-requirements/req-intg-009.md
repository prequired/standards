---
id: "REQ-INTG-009"
title: "CRM Integration"
domain: "Integrations"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-INTG-009: CRM Integration

## Description

The system shall integrate with CRM platforms (HubSpot, Salesforce) for lead and client relationship management.

## Rationale

CRM integration unifies sales pipeline, client history, and project data for better relationship management.

## Source

- **Stakeholder:** Sales Team, Account Management
- **Document:** Sales process requirements

## Fit Criterion (Measurement)

- Client data synced between systems
- Lead conversion tracked
- Sync latency under 15 minutes

## Dependencies

- **Depends On:** REQ-USER-004 (client companies)
- **Blocks:** None
- **External:** HubSpot or Salesforce API

## Satisfied By

- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md) - Native client management via Filament
- **Note:** External CRM integration is Phase 2. Initial release provides built-in client management per ADR-0010.

## Acceptance Criteria

1. Connect CRM via OAuth
2. Sync client/company records
3. Sync contact records
4. Push deal/opportunity updates
5. Pull lead information
6. Activity logging to CRM
7. Two-way sync for updates
8. Field mapping configuration
9. Sync status monitoring
10. Manual sync trigger

## Notes

- HubSpot recommended for smaller agencies
- Consider if built-in client management suffices
- May be Phase 2 depending on sales process maturity

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
