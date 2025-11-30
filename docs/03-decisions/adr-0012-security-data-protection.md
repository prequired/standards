---
id: "ADR-0012"
title: "Security & Data Protection Strategy"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-SEC-001, REQ-SEC-002, REQ-SEC-003, REQ-SEC-004, REQ-SEC-005, REQ-SEC-006, REQ-SEC-007, REQ-SEC-008"
decision_makers: "Platform Team"
consulted: "Security, Legal, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0012: Security & Data Protection Strategy

## Context and Problem Statement

The platform handles sensitive data including:
- Client business information and project details
- Payment information (via Stripe)
- User credentials and session data
- Invoices and financial records

Multiple security requirements must be addressed:
- [REQ-SEC-001](../01-requirements/req-sec-001.md): Data Encryption at Rest
- [REQ-SEC-002](../01-requirements/req-sec-002.md): HTTPS Enforcement
- [REQ-SEC-003](../01-requirements/req-sec-003.md): CSRF Protection
- [REQ-SEC-004](../01-requirements/req-sec-004.md): Rate Limiting
- [REQ-SEC-005](../01-requirements/req-sec-005.md): Audit Logging
- [REQ-SEC-006](../01-requirements/req-sec-006.md): GDPR Compliance
- [REQ-SEC-007](../01-requirements/req-sec-007.md): Data Backup Strategy
- [REQ-SEC-008](../01-requirements/req-sec-008.md): Secure File Access

## Decision Drivers

- **Compliance:** GDPR, data protection regulations
- **Trust:** Clients entrust sensitive business data
- **Laravel Native:** Leverage Laravel's security features
- **Defense in Depth:** Multiple security layers
- **Auditability:** Track who did what, when
- **Recovery:** Backup and disaster recovery capability

## Considered Options

For each security domain, multiple approaches were considered. This ADR documents the chosen approach for each.

## Decision Outcome

### Encryption Strategy

**Decision:** Laravel Encryption + Database-Level Encryption

- Use Laravel's `encrypt()` for sensitive fields (API keys, tokens)
- Use DigitalOcean Managed Database with encryption at rest
- Use DigitalOcean Spaces with encryption at rest for files
- Use TLS 1.3 for all data in transit

### Authentication Security

**Decision:** Laravel Sanctum + bcrypt + Optional MFA

- Sanctum for API token management
- bcrypt password hashing (Laravel default, cost factor 12)
- Optional TOTP-based MFA via `pragmarx/google2fa-laravel`
- Session-based auth for web, tokens for API

### HTTPS & Transport Security

**Decision:** Enforce HTTPS via Nginx + HSTS

- Let's Encrypt certificates via Laravel Forge
- HSTS header with 1-year max-age
- Redirect all HTTP to HTTPS at Nginx level
- TLS 1.2 minimum, prefer TLS 1.3

### CSRF Protection

**Decision:** Laravel Built-in CSRF Middleware

- `@csrf` directive in all forms
- `VerifyCsrfToken` middleware enabled globally
- API routes use Sanctum token auth (stateless)

### Rate Limiting

**Decision:** Laravel Rate Limiter + Cloudflare (Optional)

- Laravel `RateLimiter` facade for application-level limits
- Different limits by route: auth (5/minute), API (60/minute), general (100/minute)
- Cloudflare for DDoS protection if needed (free tier available)

### Audit Logging

**Decision:** Spatie Activity Log Package

- `spatie/laravel-activitylog` for comprehensive audit trail
- Log all model changes (created, updated, deleted)
- Log authentication events (login, logout, failed attempts)
- Log administrative actions (impersonation, permission changes)
- Retain logs for 2 years minimum

### GDPR Compliance

**Decision:** Built-in Features + Privacy by Design

- Data export functionality (user can download their data)
- Data deletion requests (soft delete with purge after retention period)
- Cookie consent banner (simple implementation)
- Privacy policy and terms of service pages
- Minimal data collection principle
- Clear data retention policies

### Backup Strategy

**Decision:** Automated Daily Backups + Off-site Storage

- DigitalOcean Managed Database daily backups (7-day retention)
- Application-level backups via `spatie/laravel-backup`
- Store backups in separate DigitalOcean Spaces bucket
- Daily full backup, retained for 30 days
- Test restore monthly

### Secure File Access

**Decision:** S3 Signed URLs + Middleware Verification

- All files stored in private S3/Spaces bucket
- Generate signed URLs with expiration (default: 60 minutes)
- Middleware verifies user has access to file's parent resource
- No direct public file URLs

### Consequences

#### Positive

- Defense in depth with multiple security layers
- Laravel-native solutions minimize complexity
- Audit trail provides accountability
- GDPR compliance built-in from start
- Automated backups reduce data loss risk
- Signed URLs prevent unauthorized file access

#### Negative

- MFA adds friction for users (optional mitigates)
- Audit logging increases database storage
- Encryption adds minor performance overhead
- Backup storage costs (minimal with Spaces)

#### Risks

- **Risk:** Encryption key compromise
  - **Mitigation:** Store APP_KEY in environment, rotate periodically, use secrets manager for production
- **Risk:** Backup restoration failure when needed
  - **Mitigation:** Monthly restore tests; document restoration procedure
- **Risk:** Rate limiting too aggressive
  - **Mitigation:** Start conservative; monitor and adjust based on legitimate usage patterns
- **Risk:** GDPR data request handling overwhelming
  - **Mitigation:** Automate export/deletion; build admin tools for handling requests

## Validation

- **Metric 1:** Zero data breaches
- **Metric 2:** GDPR requests processed within 30 days (regulatory requirement)
- **Metric 3:** Backup restoration tested successfully monthly
- **Metric 4:** All sensitive operations appear in audit log
- **Metric 5:** Security headers score A+ on securityheaders.com

## Implementation Notes

### Encryption Configuration

```php
// config/app.php
'cipher' => 'AES-256-CBC',

// Encrypt sensitive model attributes
protected $casts = [
    'api_token' => 'encrypted',
    'settings' => 'encrypted:array',
];
```

### Rate Limiting Configuration

```php
// app/Providers/RouteServiceProvider.php
RateLimiter::for('auth', function (Request $request) {
    return Limit::perMinute(5)->by($request->ip());
});

RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});
```

### Audit Logging Setup

```php
// Install: composer require spatie/laravel-activitylog
// Model trait usage:
use Spatie\Activitylog\Traits\LogsActivity;
use Spatie\Activitylog\LogOptions;

class Project extends Model
{
    use LogsActivity;

    public function getActivitylogOptions(): LogOptions
    {
        return LogOptions::defaults()
            ->logAll()
            ->logOnlyDirty();
    }
}
```

### Backup Configuration

```php
// config/backup.php (spatie/laravel-backup)
'backup' => [
    'destination' => [
        'disks' => ['spaces'], // DigitalOcean Spaces
    ],
],
'cleanup' => [
    'strategy' => \Spatie\Backup\Tasks\Cleanup\Strategies\DefaultStrategy::class,
    'default_strategy' => [
        'keep_all_backups_for_days' => 7,
        'keep_daily_backups_for_days' => 30,
        'keep_weekly_backups_for_weeks' => 8,
        'keep_monthly_backups_for_months' => 4,
    ],
],
```

### Security Headers (Nginx)

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';" always;
```

## Links

- [REQ-SEC-001](../01-requirements/req-sec-001.md) - Data Encryption at Rest
- [REQ-SEC-002](../01-requirements/req-sec-002.md) - HTTPS Enforcement
- [REQ-SEC-003](../01-requirements/req-sec-003.md) - CSRF Protection
- [REQ-SEC-004](../01-requirements/req-sec-004.md) - Rate Limiting
- [REQ-SEC-005](../01-requirements/req-sec-005.md) - Audit Logging
- [REQ-SEC-006](../01-requirements/req-sec-006.md) - GDPR Compliance
- [REQ-SEC-007](../01-requirements/req-sec-007.md) - Data Backup Strategy
- [REQ-SEC-008](../01-requirements/req-sec-008.md) - Secure File Access
- [Laravel Security Documentation](https://laravel.com/docs/security)
- [Spatie Laravel-Activitylog](https://spatie.be/docs/laravel-activitylog)
- [Spatie Laravel-Backup](https://spatie.be/docs/laravel-backup)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
