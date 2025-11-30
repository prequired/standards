---
id: "REQ-USER-003"
title: "Team/Organization Management"
domain: "User Management"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-USER-003: Team/Organization Management

## Description

The system shall support organizing staff into teams for project assignment, reporting, and permission management.

## Rationale

Teams enable efficient assignment of work, reporting structures, and department-based access controls. Supports agencies with multiple service lines or departments.

## Source

- **Stakeholder:** Operations Team
- **Document:** Organizational structure requirements

## Fit Criterion (Measurement)

- Staff can be assigned to multiple teams
- Team membership changes take effect immediately
- Reports can filter by team

## Dependencies

- **Depends On:** REQ-USER-001 (staff profiles)
- **Blocks:** None (optional feature)
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Admins can create teams
2. Teams have name and description
3. Teams can have a team lead assigned
4. Staff can belong to multiple teams
5. Projects can be assigned to teams
6. Team-based permission policies supported
7. Team dashboard shows members and active projects
8. Teams can be archived (not deleted)

## Notes

- Start simple; complex org hierarchies are Phase 2
- Consider integration with project management tools

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
