# Security Documentation

**Last Updated:** 2025-11-29

---

## Overview

This directory contains security policies, guidelines, and compliance documentation.

## Documents

| Document | Description |
|----------|-------------|
| [security-policies.md](./security-policies.md) | Comprehensive security policies and controls |

## Quick Reference

### Authentication

| Setting | Value |
|---------|-------|
| Password length | 12+ characters |
| MFA | Required for admins |
| Session timeout | 30 minutes idle |
| API tokens | 30-day expiry |

### Data Protection

| Data State | Method |
|------------|--------|
| At rest | AES-256 |
| In transit | TLS 1.3 |
| Passwords | Bcrypt |

### Access Levels

| Role | Access |
|------|--------|
| Super Admin | Full |
| Admin | User/settings management |
| Manager | Projects/billing |
| Staff | Assigned projects |
| Client | Own portal only |

### Security Checklist

- [ ] Input validation on all endpoints
- [ ] Output escaping in templates
- [ ] CSRF tokens on forms
- [ ] Authorization checks
- [ ] No secrets in code
- [ ] Dependency scanning enabled

### Incident Response

1. Detect → 2. Contain → 3. Eradicate → 4. Recover → 5. Learn

## Compliance

| Standard | Status |
|----------|--------|
| GDPR | Compliant |
| PCI-DSS | Via Stripe |
| SOC 2 | In progress |

## Related Documentation

- [ADR-0012: Security](../03-decisions/adr-0012-security-data-protection.md)
- [Incident Runbook](../07-operations/runbook-incidents.md)
- [Development Standards](../04-development/dev-standards.md)

---

## Change Log

| Date | Change |
|------|--------|
| 2025-11-29 | Initial security documentation |
