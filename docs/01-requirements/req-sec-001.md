---
id: "REQ-SEC-001"
title: "Data Encryption at Rest"
domain: "Security"
status: approved
priority: critical
created: 2025-11-29
updated: 2025-11-29
author: "Platform Team"
---

# REQ-SEC-001: Data Encryption at Rest

## Description

The system shall encrypt sensitive data at rest using industry-standard encryption algorithms.

## Rationale

Encryption at rest protects data if storage media is compromised, meeting security best practices and compliance requirements.

## Source

- **Stakeholder:** Security Team
- **Document:** Data protection requirements

## Fit Criterion (Measurement)

- All sensitive data encrypted with AES-256
- Encryption keys managed securely
- Decryption only possible by authorized processes

## Dependencies

- **Depends On:** None
- **Blocks:** None
- **External:** Key management infrastructure

## Satisfied By

- [ADR-0012: Security & Data Protection](../03-decisions/adr-0012-security-data-protection.md)

## Acceptance Criteria

1. Database encryption enabled (RDS encryption)
2. File storage encryption (S3 SSE)
3. Application-level encryption for PII
4. Encryption keys rotated regularly
5. Backup data encrypted
6. Log data encrypted
7. Key management via AWS KMS or similar
8. No plaintext secrets in codebase
9. Secret management (AWS Secrets Manager, Vault)
10. Encryption documented in security policy

## Notes

- Laravel Encryption for application-level
- Database and S3 encryption at infrastructure level
- Separate encryption from authentication

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial draft                |
