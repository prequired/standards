---
id: "REQ-PERF-004"
title: "CDN for Static Assets"
domain: "Performance"
status: draft
priority: medium
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PERF-004: CDN for Static Assets

## Description

The system shall serve static assets (images, CSS, JS) via Content Delivery Network for global performance.

## Rationale

CDN distribution reduces latency for global users and offloads traffic from application servers.

## Source

- **Stakeholder:** Operations Team
- **Document:** Infrastructure requirements

## Fit Criterion (Measurement)

- Static asset load time under 500ms globally
- CDN cache hit rate over 90%
- Reduced origin server load

## Dependencies

- **Depends On:** REQ-INTG-003 (S3)
- **Blocks:** REQ-PERF-001 (page load)
- **External:** CDN provider (CloudFront, Cloudflare)

## Satisfied By

- [ADR-0015: File Storage & CDN](../03-decisions/adr-0015-file-storage-cdn.md)

## Acceptance Criteria

1. CDN configured for static assets
2. Asset versioning for cache busting
3. Appropriate cache headers set
4. Gzip/Brotli compression enabled
5. Image optimization at edge
6. SSL/TLS on CDN
7. Custom domain for assets
8. CDN analytics and monitoring
9. Cache invalidation process
10. Fallback to origin on CDN failure

## Notes

- CloudFront pairs well with S3
- Cloudflare provides additional security benefits
- Consider full-page caching for marketing site

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
