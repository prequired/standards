# Operations Documentation

**Last Updated:** 2025-11-29

---

## Overview

This directory contains runbooks and operational procedures for the Agency Platform.

## Documents

| Document | Description | Audience |
|----------|-------------|----------|
| [runbook-deployment.md](./runbook-deployment.md) | Deployment procedures and rollback | DevOps, Engineers |
| [runbook-incidents.md](./runbook-incidents.md) | Incident response procedures | On-call, All Engineers |
| [runbook-common-tasks.md](./runbook-common-tasks.md) | Daily operations (cache, queues, logs) | All Engineers |
| [data-management.md](./data-management.md) | Backups, migrations, and data lifecycle | DevOps, Engineers |

## Quick Reference

### Deployment Commands

```bash
# Enable maintenance
php artisan down --secret="bypass-token"

# Run migrations
php artisan migrate --force

# Clear caches
php artisan optimize:clear
php artisan optimize

# Restart workers
php artisan queue:restart

# Disable maintenance
php artisan up
```

### Incident Severity

| Level | Response | Examples |
|-------|----------|----------|
| SEV-1 | < 15 min | Outage, data loss |
| SEV-2 | < 1 hour | Major feature broken |
| SEV-3 | < 4 hours | Minor issues |
| SEV-4 | < 24 hours | Cosmetic |

### Health Check

```bash
curl https://agency-platform.com/api/health
```

### Emergency Contacts

| Role | Contact |
|------|---------|
| On-Call | PagerDuty |
| Tech Lead | Slack/Phone |
| DevOps | Slack |

## Infrastructure

Based on [ADR-0011](../03-decisions/adr-0011-infrastructure-hosting.md):

| Component | Provider |
|-----------|----------|
| Servers | DigitalOcean |
| Management | Laravel Forge |
| Database | Managed MySQL |
| Cache | Managed Redis |
| Files | DO Spaces |

## Monitoring

| Service | Purpose |
|---------|---------|
| Flare | Error tracking |
| Uptime Robot | Availability |
| Forge | Server metrics |

## Related Documentation

- [ADR-0011: Infrastructure](../03-decisions/adr-0011-infrastructure-hosting.md)
- [ADR-0016: Error Monitoring](../03-decisions/adr-0016-error-monitoring-logging.md)
- [Security Policies](../08-security/README.md)

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial operations documentation |
