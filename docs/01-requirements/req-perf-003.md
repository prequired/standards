---
id: "REQ-PERF-003"
title: "99.9% Uptime"
domain: "Performance"
status: draft
priority: high
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-PERF-003: 99.9% Uptime

## Description

The system shall maintain 99.9% availability (approximately 8.76 hours downtime per year maximum).

## Rationale

High availability ensures clients can access the portal and staff can work without interruption.

## Source

- **Stakeholder:** Operations Team, Clients
- **Document:** Service Level Agreement

## Fit Criterion (Measurement)

- 99.9% uptime measured monthly
- Planned maintenance windows excluded
- Unplanned downtime under 44 minutes/month

## Dependencies

- **Depends On:** REQ-SEC-007 (backups), REQ-INTG-003 (infrastructure)
- **Blocks:** None
- **External:** Cloud infrastructure (AWS)

## Satisfied By

- [ADR-0011: Infrastructure & Hosting](../03-decisions/adr-0011-infrastructure-hosting.md)

## Acceptance Criteria

1. Multi-AZ database deployment
2. Auto-scaling application tier
3. Load balancer health checks
4. Automated failover for database
5. Zero-downtime deployments
6. Uptime monitoring (external)
7. Status page for incidents
8. On-call incident response
9. Disaster recovery tested
10. SLA tracking and reporting

## Notes

- Use managed services (RDS, ECS) for reliability
- Blue-green deployments for zero downtime
- Consider higher SLA (99.95%) for premium clients

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
