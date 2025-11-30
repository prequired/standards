---
id: "REQ-PROJ-001"
title: "Create and Manage Projects"
domain: "Project Management"
status: draft
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PROJ-001: Create and Manage Projects

## Description

The system shall provide functionality to create, view, edit, and archive projects, serving as the central organizing unit for client work.

## Rationale

Projects are the core entity around which all agency work revolves. They connect clients, tasks, billing, files, and communications.

## Source

- **Stakeholder:** Operations Team, Project Managers
- **Document:** Core platform requirements

## Fit Criterion (Measurement)

- Project creation completes in under 2 seconds
- All project data retrievable in under 500ms
- 100% of billable work is associated with a project

## Dependencies

- **Depends On:** REQ-USER-004 (client companies), REQ-AUTH-004 (RBAC)
- **Blocks:** REQ-PROJ-002 through REQ-PROJ-008, REQ-BILL-001, REQ-PORT-002
- **External:** None (or external PM tool via ADR)

## Satisfied By

- *ADR needed: Build custom vs integrate external PM tool*

## Acceptance Criteria

1. Staff can create new projects
2. Project includes: name, description, client, dates, budget
3. Projects have status (draft, active, on-hold, completed, cancelled)
4. Projects are assigned to a client organization
5. Staff members can be assigned to projects
6. Clients can be granted access to their projects
7. Projects can be duplicated as templates
8. Projects can be archived (hidden but retained)
9. Projects have unique identifiers/codes
10. Project dashboard shows all relevant information

## Notes

- Critical ADR decision: build custom or integrate with Asana/ClickUp/Monday
- If integrating, this becomes a sync/display requirement instead
- Consider project templates for common engagement types

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
