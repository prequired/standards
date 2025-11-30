---
id: "REQ-SEC-002"
title: "HTTPS Enforcement"
domain: "Security"
status: approved
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-SEC-002: HTTPS Enforcement

## Description

The system shall enforce HTTPS for all communications, redirecting HTTP to HTTPS and using secure cookies.

## Rationale

HTTPS protects data in transit from eavesdropping and tampering, and is required for modern web security.

## Source

- **Stakeholder:** Security Team
- **Document:** Transport security requirements

## Fit Criterion (Measurement)

- 100% of requests served over HTTPS
- Valid TLS certificate (A+ rating on SSL Labs)
- HSTS header enabled

## Dependencies

- **Depends On:** None (infrastructure prerequisite)
- **Blocks:** All web features
- **External:** SSL certificate, CDN/load balancer

## Satisfied By

- [ADR-0012: Security & Data Protection](../03-decisions/adr-0012-security-data-protection.md)

## Acceptance Criteria

1. Valid SSL/TLS certificate installed
2. HTTP requests redirect to HTTPS (301)
3. HSTS header with adequate max-age
4. Secure cookie flag enabled
5. TLS 1.2 minimum (TLS 1.3 preferred)
6. No mixed content warnings
7. Certificate auto-renewal configured
8. CAA DNS records configured
9. OCSP stapling enabled
10. Regular certificate monitoring

## Notes

- Use Let's Encrypt for free certificates
- CloudFlare or AWS ALB for TLS termination
- Test with SSL Labs for configuration

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
