---
id: SEC-COMP
title: Compliance and SLA Matrix
version: 1.0.0
status: active
owner: Compliance Team
last_updated: 2025-11-29
classification: internal
---

# Compliance and SLA Matrix

Regulatory compliance status and service level commitments for the Agency Platform.

---

## Compliance Overview

| Regulation | Applicability | Status | Notes |
|------------|---------------|--------|-------|
| **GDPR** | EU customers | In Progress | See GDPR section below |
| **CCPA** | California customers | In Progress | Aligned with GDPR |
| **SOC 2 Type II** | Enterprise customers | Planned | Phase 2 |
| **PCI-DSS** | Payment processing | N/A | Stripe handles PCI compliance |
| **HIPAA** | Healthcare data | N/A | Not processing PHI |

---

## GDPR Compliance

### Requirements Mapping

| GDPR Article | Requirement | Implementation | Status |
|--------------|-------------|----------------|--------|
| Art. 5 | Data processing principles | Privacy policy, minimal collection | ✅ Complete |
| Art. 6 | Lawful basis | Consent, contract performance | ✅ Complete |
| Art. 7 | Consent conditions | Cookie consent, marketing opt-in | ✅ Complete |
| Art. 12-14 | Transparency | Privacy policy, data collection notices | ✅ Complete |
| Art. 15 | Right of access | Data export in client portal | ✅ Complete |
| Art. 16 | Right to rectification | Profile editing capability | ✅ Complete |
| Art. 17 | Right to erasure | Account deletion workflow | ✅ Complete |
| Art. 20 | Data portability | JSON/CSV export | ✅ Complete |
| Art. 25 | Privacy by design | Architecture review | ✅ Complete |
| Art. 30 | Records of processing | Processing register | ✅ Complete |
| Art. 32 | Security of processing | Encryption, access controls | ✅ Complete |
| Art. 33-34 | Breach notification | Incident response plan | ✅ Complete |
| Art. 35 | DPIA | Risk assessment completed | ✅ Complete |

### Data Processing Register

| Data Category | Purpose | Legal Basis | Retention | Processor |
|---------------|---------|-------------|-----------|-----------|
| User account data | Service delivery | Contract | Account lifetime + 7 years | Self |
| Contact information | Communication | Contract/Consent | Account lifetime | Postmark |
| Payment data | Billing | Contract | 7 years (legal req) | Stripe |
| Usage analytics | Service improvement | Legitimate interest | 2 years | Self |
| Support tickets | Customer support | Contract | 3 years | Help Scout |

### Sub-Processors

| Processor | Purpose | Location | DPA Status |
|-----------|---------|----------|------------|
| DigitalOcean | Infrastructure | US (Privacy Shield) | ✅ Signed |
| Stripe | Payments | US (Privacy Shield) | ✅ Standard |
| Postmark | Email delivery | US (Privacy Shield) | ✅ Signed |
| Help Scout | Support tickets | US (Privacy Shield) | ✅ Signed |
| Cloudflare | CDN/Security | US (Privacy Shield) | ✅ Standard |

---

## CCPA Compliance

### Requirements Mapping

| CCPA Right | Requirement | Implementation | Status |
|------------|-------------|----------------|--------|
| Right to Know | Data inventory disclosure | Privacy policy + data export | ✅ Complete |
| Right to Delete | Consumer data deletion | Account deletion workflow | ✅ Complete |
| Right to Opt-Out | Sale of personal info | No data sales (N/A) | ✅ N/A |
| Right to Non-Discrimination | Equal service | No differential treatment | ✅ Complete |
| Notice at Collection | Collection disclosure | Privacy notices | ✅ Complete |

---

## SOC 2 Readiness

### Trust Service Criteria Status

| Category | Criteria | Current Status | Gap |
|----------|----------|----------------|-----|
| **Security** | | | |
| CC1 | Control environment | Partial | Formal policies needed |
| CC2 | Communication | Partial | Security training needed |
| CC3 | Risk assessment | Complete | - |
| CC4 | Monitoring | Complete | - |
| CC5 | Control activities | Partial | Access reviews needed |
| CC6 | Logical access | Complete | - |
| CC7 | System operations | Complete | - |
| CC8 | Change management | Complete | - |
| CC9 | Risk mitigation | Complete | - |
| **Availability** | | | |
| A1 | System availability | Complete | - |
| **Confidentiality** | | | |
| C1 | Confidential information | Complete | - |
| **Processing Integrity** | | | |
| PI1 | Processing completeness | Partial | Audit logging needed |
| **Privacy** | | | |
| P1-P8 | Privacy criteria | Complete | GDPR alignment |

### SOC 2 Roadmap

| Phase | Activities | Target |
|-------|------------|--------|
| Phase 1 | Policy documentation | Q2 2025 |
| Phase 2 | Control implementation | Q3 2025 |
| Phase 3 | Type I audit | Q4 2025 |
| Phase 4 | Type II audit | Q2 2026 |

---

## Service Level Agreements

### Platform SLA

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Uptime** | 99.9% | Monthly, excluding maintenance |
| **Response Time (P95)** | < 500ms | API endpoints |
| **Support Response** | | |
| - SEV-1 Critical | < 15 minutes | 24/7 |
| - SEV-2 High | < 1 hour | Business hours |
| - SEV-3 Medium | < 4 hours | Business hours |
| - SEV-4 Low | < 24 hours | Business hours |

### Uptime Calculation

```
Uptime % = (Total Minutes - Downtime Minutes) / Total Minutes × 100

Monthly minutes: 43,200 (30 days)
99.9% allows: 43.2 minutes downtime
99.5% allows: 216 minutes downtime
99.0% allows: 432 minutes downtime
```

### Exclusions

The following are excluded from SLA calculations:
- Scheduled maintenance (with 48-hour notice)
- Third-party service outages (Stripe, etc.)
- Customer-caused issues
- Force majeure events
- Beta/preview features

### SLA Credits

| Uptime | Credit |
|--------|--------|
| 99.0% - 99.9% | 10% monthly fee |
| 95.0% - 99.0% | 25% monthly fee |
| < 95.0% | 50% monthly fee |

---

## Data Protection Controls

### Encryption

| Data State | Method | Key Management |
|------------|--------|----------------|
| At rest (database) | AES-256 | Managed MySQL encryption |
| At rest (files) | AES-256 | S3 server-side encryption |
| In transit | TLS 1.3 | Let's Encrypt certificates |
| Backups | AES-256 | Separate encryption key |
| Application secrets | Laravel encryption | APP_KEY |

### Access Control

| Layer | Control | Review Frequency |
|-------|---------|------------------|
| Network | Firewall rules | Quarterly |
| Application | RBAC (Spatie) | Monthly |
| Database | Principle of least privilege | Quarterly |
| Admin | MFA required | Real-time |
| Audit | Activity logging | Continuous |

### Data Retention

| Data Type | Retention | Deletion Method |
|-----------|-----------|-----------------|
| Active user data | Account lifetime | Soft delete → Hard delete |
| Deleted accounts | 30 days recovery | Hard delete after 30 days |
| Audit logs | 2 years | Automatic purge |
| Backups | 90 days | Automatic expiry |
| Payment records | 7 years | Archival |

---

## Audit Trail

### What We Log

| Event Type | Details Captured |
|------------|------------------|
| Authentication | Login, logout, failed attempts, MFA |
| Authorization | Permission changes, role assignments |
| Data access | Read/write of sensitive records |
| Admin actions | User management, config changes |
| API access | All API calls with user context |
| System events | Deployments, errors, maintenance |

### Log Retention

| Log Type | Retention | Storage |
|----------|-----------|---------|
| Application logs | 30 days | Local + ELK |
| Audit logs | 2 years | Dedicated database |
| Access logs | 90 days | S3 |
| Error logs | 1 year | Flare |

---

## Security Assessments

### Completed Assessments

| Assessment | Date | Findings | Status |
|------------|------|----------|--------|
| Architecture review | 2025-01 | 0 critical, 2 medium | Remediated |
| Dependency audit | 2025-01 | 0 critical, 5 low | Remediated |
| OWASP Top 10 review | 2025-01 | Compliant | Complete |

### Scheduled Assessments

| Assessment | Frequency | Next Due |
|------------|-----------|----------|
| Penetration test | Annual | 2025-06 |
| Vulnerability scan | Monthly | Automated |
| Dependency audit | Weekly | Automated |
| Access review | Quarterly | 2025-03 |

---

## Vendor Security

### Third-Party Risk Assessment

| Vendor | Risk Level | Last Assessed | SOC 2 |
|--------|------------|---------------|-------|
| DigitalOcean | Medium | 2025-01 | Yes |
| Stripe | Low | 2025-01 | Yes |
| Postmark | Low | 2025-01 | Yes |
| Cloudflare | Low | 2025-01 | Yes |
| Help Scout | Low | 2025-01 | Yes |

---

## Compliance Contacts

| Role | Contact | Responsibility |
|------|---------|----------------|
| Data Protection Officer | [TBD] | GDPR compliance |
| Compliance Lead | [TBD] | Overall compliance |
| Security Lead | [TBD] | Security controls |
| Legal Counsel | [TBD] | Regulatory matters |

---

## Related Documents

- [Security Policies](./security-policies.md)
- [Incident Response](./incident-response.md)
- [Disaster Recovery](./disaster-recovery.md)
- [ADR-0012: Security](../03-decisions/adr-0012-security-compliance.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial compliance matrix |
