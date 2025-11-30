---
id: OPS-COMMON
title: Common Operations Runbook
version: 1.0.0
status: active
owner: DevOps Team
last_updated: 2025-11-29
---

# Common Operations Runbook

Standard procedures for routine operational tasks.

---

## Quick Reference

| Task | Command/Procedure | Frequency |
|------|-------------------|-----------|
| Clear cache | `php artisan cache:clear` | As needed |
| Queue restart | `php artisan queue:restart` | After deploys |
| View logs | `tail -f storage/logs/laravel.log` | As needed |
| Database backup | `mysqldump` or automated | Daily |
| SSL renewal | Automatic via Let's Encrypt | 90 days |

---

## 1. Cache Management

### Clear Application Cache

```bash
# Clear all caches
php artisan optimize:clear

# Individual caches
php artisan cache:clear      # Application cache
php artisan config:clear     # Config cache
php artisan route:clear      # Route cache
php artisan view:clear       # Compiled views
php artisan event:clear      # Event cache
```

### Rebuild Caches

```bash
# Rebuild all caches (production)
php artisan optimize

# Individual rebuilds
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
```

### Redis Cache Operations

```bash
# Connect to Redis CLI
redis-cli

# View cache keys
redis-cli KEYS "agency_platform:*"

# Flush specific prefix
redis-cli KEYS "agency_platform:cache:*" | xargs redis-cli DEL

# Flush all (CAUTION: affects sessions too)
redis-cli FLUSHDB
```

### When to Clear Cache

| Scenario | Action |
|----------|--------|
| Config changes | `config:clear` then `config:cache` |
| New routes added | `route:clear` then `route:cache` |
| Blade template issues | `view:clear` |
| Stale data | `cache:clear` |
| Post-deployment | `optimize:clear` then `optimize` |

---

## 2. Queue Management

### View Queue Status

```bash
# Current queue size
php artisan queue:monitor redis:default

# Failed jobs count
php artisan queue:failed
```

### Worker Management

```bash
# Start worker
php artisan queue:work --queue=high,default,low

# Restart workers (graceful)
php artisan queue:restart

# Stop workers (processes current job then stops)
# Send SIGTERM to worker processes
```

### Process Failed Jobs

```bash
# List failed jobs
php artisan queue:failed

# Retry specific job
php artisan queue:retry <job-id>

# Retry all failed jobs
php artisan queue:retry all

# Delete failed job
php artisan queue:forget <job-id>

# Delete all failed jobs
php artisan queue:flush
```

### Queue Debugging

```bash
# Work single job with output
php artisan queue:work --once -vvv

# Check queue driver
php artisan tinker
>>> config('queue.default')

# Check Redis queue length
redis-cli LLEN queues:default
```

---

## 3. Database Operations

### Backup Database

```bash
# Manual backup
mysqldump -u username -p agency_platform > backup_$(date +%Y%m%d_%H%M%S).sql

# Compressed backup
mysqldump -u username -p agency_platform | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz

# With structure only
mysqldump -u username -p --no-data agency_platform > schema.sql

# Specific tables
mysqldump -u username -p agency_platform users projects clients > partial_backup.sql
```

### Restore Database

```bash
# Restore from backup
mysql -u username -p agency_platform < backup.sql

# Restore compressed
gunzip < backup.sql.gz | mysql -u username -p agency_platform
```

### Database Maintenance

```bash
# Check table sizes
mysql -u root -p -e "
SELECT
  table_name,
  ROUND(data_length/1024/1024, 2) as 'Data MB',
  ROUND(index_length/1024/1024, 2) as 'Index MB'
FROM information_schema.tables
WHERE table_schema = 'agency_platform'
ORDER BY data_length DESC;
"

# Optimize tables
mysqlcheck -u username -p --optimize agency_platform

# Analyze tables (update statistics)
mysqlcheck -u username -p --analyze agency_platform
```

### Run Migrations

```bash
# Check migration status
php artisan migrate:status

# Run pending migrations
php artisan migrate

# Rollback last batch
php artisan migrate:rollback

# Rollback specific steps
php artisan migrate:rollback --step=3

# Fresh migration (CAUTION: drops all tables)
php artisan migrate:fresh --seed
```

---

## 4. Log Management

### View Logs

```bash
# Real-time log viewing
tail -f storage/logs/laravel.log

# Last 100 lines
tail -100 storage/logs/laravel.log

# Filter by error level
grep -i "error\|exception" storage/logs/laravel.log

# Today's logs only
grep "$(date +%Y-%m-%d)" storage/logs/laravel.log
```

### Log Rotation

```bash
# Laravel daily logs auto-rotate
# Configured in config/logging.php

# Manual archive of old logs
find storage/logs -name "*.log" -mtime +30 -exec gzip {} \;
find storage/logs -name "*.gz" -mtime +90 -delete
```

### Clear Logs

```bash
# Clear Laravel log
> storage/logs/laravel.log

# Or using truncate
truncate -s 0 storage/logs/laravel.log
```

---

## 5. Scheduled Tasks

### View Scheduled Tasks

```bash
# List all scheduled tasks
php artisan schedule:list

# Run scheduler once (debugging)
php artisan schedule:run

# Run specific task
php artisan schedule:test
```

### Common Scheduled Tasks

| Task | Schedule | Command |
|------|----------|---------|
| Backup database | Daily 2:00 AM | `backup:run` |
| Prune old sessions | Daily 3:00 AM | `session:prune` |
| Clear old tokens | Daily 4:00 AM | `sanctum:prune-expired` |
| Send overdue reminders | Daily 9:00 AM | `invoices:send-reminders` |
| Generate reports | Weekly Monday | `reports:weekly` |

### Debug Scheduled Tasks

```bash
# Check cron is running
grep CRON /var/log/syslog

# Check Laravel scheduler is being called
cat /var/log/syslog | grep artisan

# Verify timezone
php artisan tinker
>>> config('app.timezone')
>>> now()
```

---

## 6. Storage Management

### Check Disk Usage

```bash
# Overall disk usage
df -h

# Storage directory sizes
du -sh storage/*

# Large files
find storage -type f -size +10M -exec ls -lh {} \;
```

### Clean Temporary Files

```bash
# Clear framework temporary files
php artisan optimize:clear

# Clear old uploaded temp files
find storage/app/temp -type f -mtime +1 -delete

# Clear old session files (if file driver)
find storage/framework/sessions -type f -mtime +7 -delete
```

### Media Library Cleanup

```bash
# Remove orphaned media files (using Spatie Media Library)
php artisan media-library:clean

# Regenerate media conversions
php artisan media-library:regenerate
```

---

## 7. SSL Certificate Management

### Check Certificate Expiry

```bash
# Check expiry date
echo | openssl s_client -servername app.agency.com -connect app.agency.com:443 2>/dev/null | openssl x509 -noout -dates

# Days until expiry
echo | openssl s_client -servername app.agency.com -connect app.agency.com:443 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2 | xargs -I {} date -d {} +%s | xargs -I {} expr {} - $(date +%s) | xargs -I {} expr {} / 86400
```

### Renew Let's Encrypt

```bash
# Manual renewal
certbot renew

# Test renewal (dry run)
certbot renew --dry-run

# Force renewal
certbot renew --force-renewal
```

---

## 8. Performance Checks

### Application Performance

```bash
# Response time check
curl -o /dev/null -s -w "%{time_total}\n" https://app.agency.com/api/health

# Memory usage
php artisan tinker
>>> memory_get_usage(true) / 1024 / 1024 . ' MB'
```

### Database Performance

```bash
# Slow query log check
mysql -u root -p -e "SHOW VARIABLES LIKE 'slow_query%';"

# Current connections
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# Process list
mysql -u root -p -e "SHOW FULL PROCESSLIST;"
```

### Redis Performance

```bash
# Redis info
redis-cli INFO stats

# Memory usage
redis-cli INFO memory

# Connected clients
redis-cli CLIENT LIST | wc -l
```

---

## 9. User Account Management

### Password Reset

```bash
# Generate password reset link
php artisan tinker
>>> $user = User::where('email', 'user@example.com')->first();
>>> Password::createToken($user);
```

### Disable User Account

```bash
php artisan tinker
>>> $user = User::where('email', 'user@example.com')->first();
>>> $user->update(['is_active' => false]);
```

### Clear User Sessions

```bash
# Clear all sessions (Redis)
redis-cli KEYS "agency_platform:session:*" | xargs redis-cli DEL

# Clear specific user's sessions
php artisan tinker
>>> DB::table('sessions')->where('user_id', $userId)->delete();
```

---

## 10. Health Checks

### Application Health

```bash
# Health endpoint
curl https://app.agency.com/api/health

# Expected response
# {"status":"ok","database":"ok","redis":"ok","queue":"ok"}
```

### Service Status

```bash
# Check all services
systemctl status nginx
systemctl status php8.3-fpm
systemctl status mysql
systemctl status redis
systemctl status supervisor
```

### Quick Diagnostic

```bash
# Run artisan about command
php artisan about

# Check environment
php artisan env

# Verify config
php artisan config:show database
```

---

## Troubleshooting Quick Reference

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| 500 errors | Check logs | `tail storage/logs/laravel.log` |
| Slow response | Database/cache | Check slow queries, clear cache |
| Queue stuck | Worker died | `php artisan queue:restart` |
| Session lost | Redis/session driver | Check Redis connection |
| File upload fails | Permissions/size | Check `storage/` permissions |
| Emails not sending | Queue/config | Check queue worker, mail config |

---

## Related Documents

- [Deployment Runbook](./runbook-deployment.md)
- [Incident Response](./runbook-incidents.md)
- [Data Management](./data-management.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial common tasks runbook |
