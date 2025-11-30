---
id: "REQ-PROJ-006"
title: "Project Templates"
domain: "Project Management"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PROJ-006: Project Templates

## Description

The system shall support project templates that can be used to quickly create new projects with pre-defined structure, tasks, and milestones.

## Rationale

Templates standardize project setup, ensure consistency across engagements, and reduce administrative overhead for common project types.

## Source

- **Stakeholder:** Project Managers, Operations Team
- **Document:** Operational efficiency requirements

## Fit Criterion (Measurement)

- Project creation from template completes in under 5 seconds
- 80% of projects created using templates
- Templates reduce project setup time by 75%

## Dependencies

- **Depends On:** REQ-PROJ-001 (projects), REQ-PROJ-003 (tasks), REQ-PROJ-004 (milestones)
- **Blocks:** None
- **External:** None

## Satisfied By

- *To be linked after ADR creation*

## Acceptance Criteria

1. Admins can create project templates
2. Templates include standard tasks and milestones
3. Templates have default duration/timeline
4. Templates can specify default team assignments
5. New projects can be created from template
6. Template application adjusts dates automatically
7. Templates can be versioned
8. Templates categorized by project type
9. Existing project can be saved as template

## Notes

- Common templates: Website, Branding, Retainer, Audit
- Consider template inheritance for variations

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
