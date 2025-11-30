---
id: DEV-CONFIG
title: Configuration Management
version: 1.0.0
status: active
owner: Development Team
last_updated: 2025-11-29
---

# Configuration Management

Standards and procedures for managing application configuration, environment variables, and secrets.

---

## Configuration Principles

1. **Environment-Specific Configuration**: All environment-specific values in `.env`
2. **No Secrets in Code**: Never commit credentials, API keys, or secrets
3. **Sensible Defaults**: Config files have development-safe defaults
4. **Validation on Boot**: Critical config validated at application start
5. **Documentation**: All variables documented with examples

---

## Environment Variables

### Variable Naming Convention

```
CATEGORY_NAME_DETAIL=value
```

Examples:
- `DB_HOST` - Database host
- `MAIL_MAILER` - Mail driver
- `STRIPE_SECRET` - Stripe secret key
- `FEATURE_DARK_MODE` - Feature flag

### Required Variables

These MUST be set for the application to run:

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_KEY` | Encryption key | `base64:...` |
| `APP_URL` | Application URL | `https://app.agency.com` |
| `DB_CONNECTION` | Database driver | `mysql` |
| `DB_HOST` | Database host | `127.0.0.1` |
| `DB_DATABASE` | Database name | `agency_platform` |
| `DB_USERNAME` | Database user | `forge` |
| `DB_PASSWORD` | Database password | `secret` |

### Environment Tiers

| Tier | APP_ENV | APP_DEBUG | Description |
|------|---------|-----------|-------------|
| Local | `local` | `true` | Developer machines |
| Testing | `testing` | `true` | CI/CD pipelines |
| Staging | `staging` | `false` | Pre-production |
| Production | `production` | `false` | Live environment |

---

## Configuration Categories

### Application Core

```env
# Identity
APP_NAME="Agency Platform"
APP_ENV=production
APP_KEY=base64:generated-key-here
APP_DEBUG=false
APP_URL=https://app.agency.com

# Timezone & Locale
APP_TIMEZONE=UTC
APP_LOCALE=en
APP_FALLBACK_LOCALE=en
```

### Database

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agency_platform
DB_USERNAME=forge
DB_PASSWORD=secret

# Connection pooling (production)
DB_POOL_SIZE=20
```

### Cache & Session

```env
# Drivers: file, redis, memcached, database
CACHE_DRIVER=redis
SESSION_DRIVER=redis
SESSION_LIFETIME=120

# Redis connection
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### Queue

```env
# Drivers: sync, database, redis, sqs
QUEUE_CONNECTION=redis

# Worker configuration
QUEUE_RETRY_AFTER=90
QUEUE_FAILED_DRIVER=database
```

### Mail

```env
MAIL_MAILER=postmark
MAIL_FROM_ADDRESS=hello@agency.com
MAIL_FROM_NAME="${APP_NAME}"

# Postmark specific
POSTMARK_TOKEN=your-postmark-token
```

### Filesystem

```env
FILESYSTEM_DISK=s3

# S3 Configuration
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=agency-platform
AWS_URL=https://cdn.agency.com
```

### Third-Party Services

```env
# Stripe (Payments)
STRIPE_KEY=pk_live_...
STRIPE_SECRET=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Postmark (Email)
POSTMARK_TOKEN=...

# Google (OAuth, Calendar)
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...

# Sentry (Error Tracking)
SENTRY_LARAVEL_DSN=https://...@sentry.io/...
```

### Feature Flags

```env
FEATURE_CLIENT_PORTAL=true
FEATURE_ADVANCED_ANALYTICS=false
FEATURE_WORKFLOW_AUTOMATION=true
FEATURE_API_RATE_LIMITING=true
```

---

## Secrets Management

### What Constitutes a Secret

- API keys and tokens
- Database passwords
- Encryption keys
- OAuth client secrets
- Webhook signing secrets
- Third-party service credentials

### Local Development

For local development, use `.env` file (gitignored):

```bash
cp .env.example .env
# Edit .env with local values
```

### Production Secrets

Production secrets should be managed via:

1. **Environment Variables** (preferred for containers)
2. **Secrets Manager** (AWS Secrets Manager, HashiCorp Vault)
3. **Platform Secrets** (Forge, Vapor, etc.)

Never store production secrets in:
- Version control
- Deployment scripts
- Docker images
- Log files

### Secret Rotation

| Secret Type | Rotation Frequency | Procedure |
|-------------|-------------------|-----------|
| Database passwords | Quarterly | Update via platform |
| API keys | Annually | Regenerate in provider |
| APP_KEY | Never* | Would invalidate encrypted data |
| OAuth secrets | Annually | Regenerate in provider |

*APP_KEY should only be rotated in emergencies with a data re-encryption plan.

---

## Configuration Files

### Laravel Config Structure

```
config/
├── app.php           # Core application
├── auth.php          # Authentication
├── cache.php         # Caching
├── database.php      # Database connections
├── filesystems.php   # Storage disks
├── logging.php       # Log channels
├── mail.php          # Mail configuration
├── queue.php         # Queue connections
├── services.php      # Third-party services
└── agency/           # Custom app config
    ├── billing.php
    ├── portal.php
    └── features.php
```

### Adding New Configuration

1. Add to appropriate config file
2. Use environment variable with default
3. Document in `.env.example`
4. Add validation if critical

Example:

```php
// config/agency/billing.php
return [
    'default_currency' => env('BILLING_CURRENCY', 'USD'),
    'payment_terms_days' => env('BILLING_PAYMENT_TERMS', 30),
    'tax_rate' => env('BILLING_TAX_RATE', 0),
];
```

---

## Configuration Validation

### Boot-Time Validation

Critical configuration is validated when the application starts:

```php
// app/Providers/AppServiceProvider.php
public function boot(): void
{
    $this->validateCriticalConfig();
}

private function validateCriticalConfig(): void
{
    $required = [
        'app.key' => 'APP_KEY is required',
        'database.connections.mysql.database' => 'Database must be configured',
        'services.stripe.secret' => 'Stripe secret is required',
    ];

    foreach ($required as $key => $message) {
        if (empty(config($key))) {
            throw new RuntimeException($message);
        }
    }
}
```

### Runtime Validation

For non-critical but important settings:

```php
if (! config('services.postmark.token')) {
    Log::warning('Postmark not configured, emails will not be sent');
}
```

---

## Environment Files

### File Hierarchy

```
.env                  # Local overrides (gitignored)
.env.example          # Template with documentation
.env.testing          # Testing environment
.env.ci               # CI/CD environment
```

### .env.example Template

```env
# Agency Platform Environment Configuration
# Copy to .env and customize for your environment

#--------------------------------------------
# APPLICATION
#--------------------------------------------
APP_NAME="Agency Platform"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

#--------------------------------------------
# DATABASE
#--------------------------------------------
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agency_platform
DB_USERNAME=root
DB_PASSWORD=

#--------------------------------------------
# CACHE & SESSION
#--------------------------------------------
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

#--------------------------------------------
# MAIL
#--------------------------------------------
# Local: Use Mailpit (MAIL_PORT=1025)
# Production: Use Postmark
MAIL_MAILER=smtp
MAIL_HOST=127.0.0.1
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS=hello@agency.test
MAIL_FROM_NAME="${APP_NAME}"

#--------------------------------------------
# STRIPE
#--------------------------------------------
# Get test keys from https://dashboard.stripe.com/test/apikeys
STRIPE_KEY=pk_test_
STRIPE_SECRET=sk_test_
STRIPE_WEBHOOK_SECRET=whsec_

#--------------------------------------------
# STORAGE
#--------------------------------------------
FILESYSTEM_DISK=local

# For S3 (production):
# AWS_ACCESS_KEY_ID=
# AWS_SECRET_ACCESS_KEY=
# AWS_DEFAULT_REGION=us-east-1
# AWS_BUCKET=

#--------------------------------------------
# FEATURE FLAGS
#--------------------------------------------
FEATURE_CLIENT_PORTAL=true
FEATURE_ADVANCED_ANALYTICS=false
```

---

## Per-Environment Overrides

### Testing Environment

```env
# .env.testing
APP_ENV=testing
DB_DATABASE=agency_platform_test
CACHE_DRIVER=array
SESSION_DRIVER=array
QUEUE_CONNECTION=sync
MAIL_MAILER=array
```

### CI/CD Environment

```env
# .env.ci
APP_ENV=testing
APP_KEY=base64:test-key-for-ci-only
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_DATABASE=test
DB_USERNAME=root
DB_PASSWORD=
CACHE_DRIVER=array
QUEUE_CONNECTION=sync
```

---

## Configuration Caching

### When to Cache

Production environments should cache configuration:

```bash
php artisan config:cache
```

This creates `bootstrap/cache/config.php`.

### When NOT to Cache

- Local development (changes won't be detected)
- When using `env()` outside config files

### Clear Cache

```bash
php artisan config:clear
```

---

## Security Checklist

- [ ] `.env` is in `.gitignore`
- [ ] `.env.example` has no real secrets
- [ ] `APP_DEBUG=false` in production
- [ ] `APP_ENV=production` in production
- [ ] All API keys are for production accounts
- [ ] Webhook secrets are unique per environment
- [ ] Database credentials are environment-specific
- [ ] Error reporting configured (Sentry, etc.)
- [ ] Session driver is secure (redis, not file)
- [ ] HTTPS enforced in production

---

## Related Documents

- [Setup Guide](./setup-guide.md)
- [Security Policies](../08-security/security-policies.md)
- [Deployment Runbook](../07-operations/runbook-deployment.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial configuration management doc |
