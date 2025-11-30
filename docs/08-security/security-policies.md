# Security Policies

**Version:** 1.0.0
**Last Updated:** 2025-11-29
**Classification:** Internal

---

## 1. Overview

This document defines security policies for the Agency Platform, implementing requirements from [ADR-0012: Security & Data Protection](../03-decisions/adr-0012-security-data-protection.md).

### 1.1 Security Principles

1. **Defense in Depth** - Multiple layers of security
2. **Least Privilege** - Minimum necessary access
3. **Secure by Default** - Secure configuration out of the box
4. **Zero Trust** - Verify everything, trust nothing
5. **Privacy by Design** - Protect user data at every level

### 1.2 Compliance Requirements

- GDPR (EU data protection)
- PCI-DSS (payment card handling)
- SOC 2 (security controls)

---

## 2. Authentication & Authorization

### 2.1 Password Policy

| Requirement | Value |
|-------------|-------|
| Minimum length | 12 characters |
| Complexity | Upper, lower, number, special |
| Expiry | None (NIST recommendation) |
| History | Cannot reuse last 5 passwords |
| Lockout | 5 failed attempts → 15 min lockout |

### 2.2 Multi-Factor Authentication

- **Required for:** Admin users, payment access
- **Recommended for:** All staff users
- **Methods:** TOTP (Google Authenticator, Authy)

### 2.3 Session Management

| Setting | Value |
|---------|-------|
| Session lifetime | 8 hours (staff), 30 days (clients) |
| Idle timeout | 30 minutes |
| Single session | Optional per user |
| Cookie flags | Secure, HttpOnly, SameSite=Lax |

### 2.4 API Authentication

- Use Laravel Sanctum tokens
- Tokens expire after 30 days
- Scope-based access control
- Rate limiting per token

---

## 3. Data Protection

### 3.1 Data Classification

| Level | Description | Examples | Handling |
|-------|-------------|----------|----------|
| Public | Freely shareable | Marketing content | None |
| Internal | Business use only | Project names | Access control |
| Confidential | Restricted access | Client data | Encryption |
| Sensitive | Highest protection | Payment info, PII | Encryption + audit |

### 3.2 Encryption Standards

| Data State | Method | Standard |
|------------|--------|----------|
| At rest | Database encryption | AES-256 |
| In transit | TLS | TLS 1.3 |
| Passwords | Hashing | Bcrypt (cost 12) |
| Tokens | Hashing | SHA-256 |
| Files | Server-side | AES-256 |

### 3.3 PII Handling

Personal Identifiable Information includes:
- Names, email addresses, phone numbers
- Physical addresses
- Payment information
- IP addresses

**Requirements:**
- Encrypt at rest
- Access logging
- Data minimization
- Right to deletion (GDPR)

### 3.4 Data Retention

| Data Type | Retention | Disposal |
|-----------|-----------|----------|
| User accounts | Active + 2 years | Anonymize |
| Transaction logs | 7 years | Secure delete |
| Access logs | 1 year | Automatic purge |
| Backups | 30 days | Automatic expire |
| Deleted content | 30 days | Permanent delete |

---

## 4. Application Security

### 4.1 Input Validation

**All user input must be:**
- Validated on server-side (never trust client)
- Type-checked and sanitized
- Length-limited
- Rejected if invalid (fail closed)

```php
// Always use Form Requests
$validated = $request->validate([
    'email' => ['required', 'email', 'max:255'],
    'name' => ['required', 'string', 'max:100'],
]);
```

### 4.2 Output Encoding

**Always escape output:**
- Use `{{ }}` in Blade (auto-escaped)
- Use `{!! !!}` only for trusted HTML
- Encode JSON with `@json()`
- Set `Content-Type` headers correctly

### 4.3 SQL Injection Prevention

- Use Eloquent ORM or Query Builder
- Never concatenate user input into queries
- Use parameterized queries for raw SQL

```php
// Good
User::where('email', $email)->first();

// Bad
DB::select("SELECT * FROM users WHERE email = '$email'");
```

### 4.4 XSS Prevention

- Escape all output
- Use Content Security Policy headers
- Validate/sanitize rich text input
- Use `htmlspecialchars()` for non-Blade output

### 4.5 CSRF Protection

- All state-changing requests require CSRF token
- Use `@csrf` in forms
- API uses token authentication instead

### 4.6 File Upload Security

| Check | Implementation |
|-------|----------------|
| File type | Validate MIME type, not just extension |
| File size | Max 10MB (configurable) |
| Filename | Sanitize, generate UUID |
| Storage | Outside web root |
| Scanning | Virus scan (optional) |

```php
$request->validate([
    'file' => ['required', 'file', 'max:10240', 'mimes:pdf,doc,docx,jpg,png'],
]);

$path = $request->file('file')->store('uploads', 's3');
```

### 4.7 Dependency Security

- Run `composer audit` weekly
- Enable Dependabot alerts
- Update dependencies monthly
- Review changelogs for security fixes

---

## 5. Infrastructure Security

### 5.1 Server Hardening

- Disable root SSH login
- Use SSH keys only (no passwords)
- Enable firewall (UFW)
- Keep packages updated
- Remove unused services

### 5.2 Network Security

| Port | Service | Access |
|------|---------|--------|
| 22 | SSH | IP whitelist |
| 80 | HTTP | All (redirect to 443) |
| 443 | HTTPS | All |
| 3306 | MySQL | Internal only |
| 6379 | Redis | Internal only |

### 5.3 Database Security

- Use managed database service
- Enable TLS for connections
- Separate read/write users
- Regular backups (encrypted)
- Access from app servers only

### 5.4 Secrets Management

- Store secrets in environment variables
- Use Laravel's encrypted environment
- Rotate secrets quarterly
- Never commit secrets to git
- Use different secrets per environment

---

## 6. Access Control

### 6.1 Role-Based Access Control

| Role | Permissions |
|------|-------------|
| Super Admin | Full system access |
| Admin | User management, settings |
| Manager | Project management, billing |
| Staff | Assigned projects only |
| Client | Own portal access only |

### 6.2 Permission Matrix

| Resource | View | Create | Edit | Delete | Admin |
|----------|------|--------|------|--------|-------|
| Projects | Staff+ | Manager+ | Manager+ | Admin+ | Admin |
| Invoices | Staff+ | Manager+ | Manager+ | Admin+ | Admin |
| Users | Manager+ | Admin+ | Admin+ | Super | Super |
| Settings | Admin+ | Admin+ | Admin+ | Super | Super |

### 6.3 Client Data Isolation

- Clients can only access their own data
- Global scopes enforce isolation
- API tokens scoped to client
- Separate database schemas (optional)

---

## 7. Logging & Monitoring

### 7.1 Security Logging

**Must log:**
- Authentication attempts (success/failure)
- Authorization failures
- Password changes
- Permission changes
- Data exports
- Admin actions

### 7.2 Log Format

```json
{
    "timestamp": "2025-11-29T10:00:00Z",
    "level": "warning",
    "event": "auth.failed",
    "user_id": null,
    "ip": "192.168.1.1",
    "user_agent": "Mozilla/5.0...",
    "details": {
        "email": "user@example.com",
        "reason": "invalid_password"
    }
}
```

### 7.3 Log Retention

| Log Type | Retention |
|----------|-----------|
| Application | 30 days |
| Security | 1 year |
| Audit | 7 years |
| Access | 90 days |

### 7.4 Alerting

Alert on:
- Multiple failed logins (> 5 in 5 min)
- Admin permission changes
- New admin users created
- Unusual data access patterns
- Security scan detections

---

## 8. Incident Response

### 8.1 Security Incident Classification

| Severity | Description | Response |
|----------|-------------|----------|
| Critical | Active breach, data loss | Immediate |
| High | Vulnerability exploited | < 4 hours |
| Medium | Potential vulnerability | < 24 hours |
| Low | Minor security issue | < 1 week |

### 8.2 Incident Response Steps

1. **Detect** - Identify the incident
2. **Contain** - Stop the damage spreading
3. **Eradicate** - Remove the threat
4. **Recover** - Restore normal operations
5. **Learn** - Post-mortem and improvements

### 8.3 Data Breach Notification

If personal data breached:
- Notify authorities within 72 hours (GDPR)
- Notify affected users without undue delay
- Document breach and response
- Review and improve controls

---

## 9. Secure Development

### 9.1 Security in SDLC

| Phase | Security Activity |
|-------|-------------------|
| Design | Threat modeling |
| Development | Secure coding practices |
| Code Review | Security-focused review |
| Testing | Security testing |
| Deployment | Security configuration |
| Operations | Monitoring, patching |

### 9.2 Code Review Checklist

- [ ] Input validation present
- [ ] Output properly encoded
- [ ] Authentication checked
- [ ] Authorization enforced
- [ ] No hardcoded secrets
- [ ] SQL injection prevented
- [ ] Error handling appropriate
- [ ] Logging sensitive actions

### 9.3 Security Testing

| Test Type | Frequency | Tool |
|-----------|-----------|------|
| Static analysis | Every PR | PHPStan |
| Dependency scan | Weekly | Composer audit |
| Dynamic testing | Monthly | OWASP ZAP |
| Penetration test | Annually | External firm |

---

## 10. Compliance

### 10.1 GDPR Compliance

- [x] Lawful basis for processing
- [x] Privacy policy published
- [x] Consent mechanisms
- [x] Data subject rights (access, deletion)
- [x] Data processing agreements
- [x] Breach notification process
- [x] Data protection impact assessments

### 10.2 PCI-DSS Compliance

For payment handling:
- [x] Use Stripe (PCI Level 1)
- [x] No card data stored locally
- [x] TLS for all transmissions
- [x] Access logging enabled
- [x] Regular security reviews

### 10.3 SOC 2 Considerations

- Security policies documented
- Access controls implemented
- Encryption standards met
- Monitoring and alerting active
- Incident response defined

---

## 11. Security Training

### 11.1 Required Training

| Audience | Training | Frequency |
|----------|----------|-----------|
| All staff | Security awareness | Annual |
| Developers | Secure coding | Annual |
| Admins | Security operations | Annual |
| New hires | Security onboarding | Hire date |

### 11.2 Topics Covered

- Password security
- Phishing awareness
- Data handling
- Incident reporting
- Social engineering
- OWASP Top 10

---

## Links

- [ADR-0012: Security & Data Protection](../03-decisions/adr-0012-security-data-protection.md)
- [OWASP Top 10](https://owasp.org/Top10/)
- [Laravel Security](https://laravel.com/docs/security)
- [Incident Runbook](../07-operations/runbook-incidents.md)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial security policies |
