# Deployment Runbook

**Version:** 1.0.0
**Last Updated:** 2025-11-29

---

## 1. Overview

This runbook covers deployment procedures for the Agency Platform across all environments.

### 1.1 Environments

| Environment | URL | Purpose | Deploy Trigger |
|-------------|-----|---------|----------------|
| Development | localhost | Local development | Manual |
| Staging | staging.agency-platform.com | Testing/QA | Push to `main` |
| Production | agency-platform.com | Live system | Manual release |

### 1.2 Infrastructure

Based on [ADR-0011: Infrastructure & Hosting](../03-decisions/adr-0011-infrastructure-hosting.md):

- **Provider:** DigitalOcean
- **Management:** Laravel Forge
- **Web Server:** Nginx + PHP-FPM 8.3
- **Database:** Managed MySQL 8
- **Cache:** Managed Redis
- **CDN:** DigitalOcean Spaces

---

## 2. Pre-Deployment Checklist

### 2.1 Code Readiness

- [ ] All tests passing in CI
- [ ] Code review approved
- [ ] No critical security alerts
- [ ] Database migrations reviewed
- [ ] Environment variables documented

### 2.2 Infrastructure Readiness

- [ ] Server disk space > 20% free
- [ ] Database backup completed
- [ ] Redis memory < 80%
- [ ] No active incidents

### 2.3 Communication

- [ ] Team notified of deployment window
- [ ] Stakeholders informed (for major releases)
- [ ] Support team briefed on changes

---

## 3. Deployment Procedures

### 3.1 Staging Deployment (Automatic)

Staging deploys automatically on push to `main`:

```yaml
# .github/workflows/deploy-staging.yml
name: Deploy Staging

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Forge Deploy
        run: |
          curl -X POST ${{ secrets.FORGE_DEPLOY_STAGING_URL }}
```

**Post-Deploy Verification:**

1. Check deployment status in Forge
2. Verify application loads: `https://staging.agency-platform.com`
3. Run smoke tests
4. Check error monitoring (Flare)

### 3.2 Production Deployment (Manual)

#### Step 1: Create Release

```bash
# Tag the release
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# Create GitHub release
gh release create v1.2.0 --generate-notes
```

#### Step 2: Enable Maintenance Mode

Via Forge dashboard or:

```bash
ssh forge@production-server
cd /home/forge/agency-platform
php artisan down --secret="bypass-token-123"
```

#### Step 3: Deploy via Forge

1. Log into Laravel Forge
2. Navigate to site → Deployments
3. Click "Deploy Now"
4. Monitor deployment log

Or trigger via CLI:

```bash
curl -X POST https://forge.laravel.com/api/v1/servers/{server}/sites/{site}/deployment \
  -H "Authorization: Bearer $FORGE_API_TOKEN"
```

#### Step 4: Run Migrations

```bash
ssh forge@production-server
cd /home/forge/agency-platform
php artisan migrate --force
```

#### Step 5: Clear Caches

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan cache:clear
php artisan queue:restart
```

#### Step 6: Verify Deployment

```bash
# Check application version
curl -s https://agency-platform.com/api/health | jq .version

# Test critical endpoints
curl -I https://agency-platform.com/
curl -I https://agency-platform.com/portal/login
curl -I https://agency-platform.com/api/v1/projects
```

#### Step 7: Disable Maintenance Mode

```bash
php artisan up
```

#### Step 8: Post-Deploy Monitoring

- Watch Flare for new errors (15-30 minutes)
- Check queue worker status
- Verify scheduled tasks running
- Monitor response times

---

## 4. Rollback Procedures

### 4.1 Quick Rollback (< 5 minutes)

If critical issue detected within 5 minutes:

```bash
# Revert to previous deployment
ssh forge@production-server
cd /home/forge/agency-platform

# List available releases
ls -la releases/

# Symlink to previous release
ln -nfs releases/20251128120000 current

# Restart PHP-FPM
sudo systemctl restart php8.3-fpm

# Restart queue workers
php artisan queue:restart
```

### 4.2 Database Rollback

If migration needs reverting:

```bash
# Enable maintenance mode first
php artisan down --secret="bypass-token"

# Rollback last migration
php artisan migrate:rollback --step=1 --force

# Redeploy previous version
# Then disable maintenance mode
php artisan up
```

### 4.3 Full Rollback

For complete rollback including code and data:

1. Enable maintenance mode
2. Restore database from backup
3. Deploy previous release tag
4. Clear all caches
5. Verify functionality
6. Disable maintenance mode

---

## 5. Zero-Downtime Deployment

Forge handles zero-downtime deployment via:

1. Clone repository to new release directory
2. Install dependencies (`composer install`)
3. Run build steps (`npm run build`)
4. Run migrations
5. Swap symlink atomically
6. Restart PHP-FPM gracefully

**Forge Deploy Script:**

```bash
cd /home/forge/agency-platform

git pull origin main

composer install --no-interaction --prefer-dist --optimize-autoloader

npm ci
npm run build

php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

php artisan queue:restart
```

---

## 6. Database Migrations

### 6.1 Safe Migration Practices

- Test migrations on staging first
- Use `--force` flag in production
- Always have rollback plan
- For large tables, use batched migrations

### 6.2 Large Table Migrations

For tables with millions of rows:

```php
// Use pt-online-schema-change for large ALTER TABLE
// Or implement batched migrations

public function up(): void
{
    Schema::table('large_table', function (Blueprint $table) {
        $table->index('new_column')->algorithm('inplace');
    });
}
```

### 6.3 Migration Verification

```bash
# Check migration status
php artisan migrate:status

# Dry run
php artisan migrate --pretend

# Execute
php artisan migrate --force
```

---

## 7. Environment Configuration

### 7.1 Environment Variables

Critical variables to verify before deploy:

```bash
APP_ENV=production
APP_DEBUG=false
APP_URL=https://agency-platform.com

DB_CONNECTION=mysql
DB_HOST=db-production.cluster.digitalocean.com

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

MAIL_MAILER=postmark
POSTMARK_TOKEN=***

STRIPE_KEY=pk_live_***
STRIPE_SECRET=sk_live_***
```

### 7.2 Secrets Management

- Store secrets in Forge environment
- Never commit secrets to git
- Rotate credentials quarterly
- Use separate credentials per environment

---

## 8. Queue Workers

### 8.1 Worker Management

Managed by Supervisor via Forge:

```ini
[program:agency-platform-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /home/forge/agency-platform/artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
numprocs=3
redirect_stderr=true
stdout_logfile=/home/forge/.forge/worker-*.log
stopwaitsecs=3600
```

### 8.2 Restart Workers After Deploy

```bash
php artisan queue:restart
```

### 8.3 Monitor Queue Health

```bash
# Check queue length
php artisan queue:monitor redis:default,redis:emails --max=100

# Failed jobs
php artisan queue:failed
php artisan queue:retry all
```

---

## 9. Scheduled Tasks

### 9.1 Cron Configuration

Managed by Forge scheduler:

```bash
* * * * * cd /home/forge/agency-platform && php artisan schedule:run >> /dev/null 2>&1
```

### 9.2 Verify Scheduler

```bash
# List scheduled commands
php artisan schedule:list

# Run scheduler manually
php artisan schedule:run
```

---

## 10. Health Checks

### 10.1 Application Health Endpoint

```php
// routes/api.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'version' => config('app.version'),
        'timestamp' => now()->toIso8601String(),
        'checks' => [
            'database' => DB::connection()->getPdo() ? 'ok' : 'fail',
            'cache' => Cache::set('health', true) ? 'ok' : 'fail',
            'queue' => Queue::size() < 1000 ? 'ok' : 'degraded',
        ],
    ]);
});
```

### 10.2 External Monitoring

Configure uptime monitoring:

- **URL:** `https://agency-platform.com/api/health`
- **Interval:** 1 minute
- **Alert threshold:** 3 consecutive failures
- **Notification:** Slack, PagerDuty

---

## 11. Troubleshooting

### 11.1 Deployment Failed

```bash
# Check deployment log in Forge

# SSH and check manually
ssh forge@production-server
cd /home/forge/agency-platform

# Check Laravel logs
tail -f storage/logs/laravel.log

# Check Nginx logs
tail -f /var/log/nginx/error.log
```

### 11.2 Application Errors After Deploy

```bash
# Check Flare dashboard for errors

# Clear and rebuild caches
php artisan optimize:clear
php artisan optimize

# Restart PHP-FPM
sudo systemctl restart php8.3-fpm
```

### 11.3 Database Connection Issues

```bash
# Test database connection
php artisan tinker
>>> DB::connection()->getPdo();

# Check credentials
cat .env | grep DB_
```

### 11.4 Queue Not Processing

```bash
# Check supervisor status
sudo supervisorctl status

# Restart workers
sudo supervisorctl restart all

# Check for failed jobs
php artisan queue:failed
```

---

## 12. Emergency Contacts

| Role | Contact | When to Escalate |
|------|---------|------------------|
| On-Call Engineer | [PagerDuty] | Critical failures |
| Tech Lead | [Phone/Slack] | Architecture decisions |
| DevOps | [Slack] | Infrastructure issues |
| Database Admin | [Slack] | Data issues |

---

## Links

- [ADR-0011: Infrastructure](../03-decisions/adr-0011-infrastructure-hosting.md)
- [Laravel Forge Documentation](https://forge.laravel.com/docs)
- [DigitalOcean Status](https://status.digitalocean.com/)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial deployment runbook |
