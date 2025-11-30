---
id: "REQ-MKTG-007"
title: "Testimonials Display"
domain: "Marketing"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-MKTG-007: Testimonials Display

## Description

The system shall display client testimonials across the marketing site for social proof.

## Rationale

Testimonials build trust and credibility by showing real client satisfaction.

## Source

- **Stakeholder:** Marketing Team
- **Document:** Social proof requirements

## Fit Criterion (Measurement)

- Testimonials on homepage and service pages
- Testimonials include client details (name, company)
- Fresh testimonials added regularly

## Dependencies

- **Depends On:** REQ-CMS-008 (content management)
- **Blocks:** None
- **External:** None

## Satisfied By

- [ADR-0017: Marketing Site Architecture](../03-decisions/adr-0017-marketing-site-architecture.md)

## Acceptance Criteria

1. Create/manage testimonials in CMS
2. Testimonial includes: quote, name, title, company
3. Optional client photo or logo
4. Optional rating (5-star)
5. Link to case study (if available)
6. Display on relevant pages
7. Carousel/slider for multiple testimonials
8. Random or featured testimonial display
9. Video testimonials support
10. Service-specific testimonial filtering

## Notes

- Request testimonials systematically after project completion
- Consider video testimonials for higher impact
- Display on pages relevant to testimonial topic

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
