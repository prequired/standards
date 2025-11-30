---
id: "REQ-MKTG-009"
title: "Team Page"
domain: "Marketing"
status: draft
priority: low
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-MKTG-009: Team Page

## Description

The system shall provide a team page showcasing agency staff and leadership.

## Rationale

Team pages humanize the agency, build trust, and help clients know who they'll work with.

## Source

- **Stakeholder:** Marketing Team
- **Document:** Brand building requirements

## Fit Criterion (Measurement)

- Team page shows current staff
- Staff marked as "public" appear on page
- Page updates when staff changes

## Dependencies

- **Depends On:** REQ-USER-001 (staff profiles)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0017: Marketing Site Architecture](../03-decisions/adr-0017-marketing-site-architecture.md)

## Acceptance Criteria

1. Display team members with photos
2. Include name, title, bio
3. Social links (LinkedIn, Twitter)
4. Filter/group by department
5. Link to blog posts by author
6. Leadership highlighted separately
7. Fun facts or personality elements
8. Hiring/careers callout
9. Sync with staff profile data
10. Control visibility per staff member

## Notes

- Connect to internal staff profiles
- Only show staff marked as "public"
- Consider fun team photo or culture section

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
