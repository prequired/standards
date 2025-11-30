---
id: "REQ-CMS-006"
title: "Draft/Publish Workflow"
domain: "Content Management"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-CMS-006: Draft/Publish Workflow

## Description

The system shall support a content workflow from draft through review to publication.

## Rationale

Workflow ensures content quality through review before public visibility, and prevents accidental publication.

## Source

- **Stakeholder:** Marketing Team
- **Document:** Content governance requirements

## Fit Criterion (Measurement)

- All content goes through defined workflow
- Published content is reviewed
- Draft content never visible publicly

## Dependencies

- **Depends On:** REQ-CMS-001 (blog posts), REQ-AUTH-004 (RBAC)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0003: CMS Approach](../03-decisions/adr-0003-cms-approach.md)

## Acceptance Criteria

1. Content states: draft, pending review, published, archived
2. Authors can save as draft
3. Authors can submit for review
4. Reviewers can approve or request changes
5. Approved content can be published
6. Published content can be unpublished
7. Role-based publish permissions
8. Workflow notifications
9. Review comments/feedback
10. Audit trail of state changes

## Notes

- Simple workflow for small team; complex for larger orgs
- Consider approval requirements per content type
- Start simple, add complexity as needed

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
