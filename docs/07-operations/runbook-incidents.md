# Incident Response Runbook

**Version:** 1.0.0
**Last Updated:** 2025-11-29

---

## 1. Overview

This runbook provides procedures for responding to production incidents affecting the Agency Platform.

### 1.1 Incident Severity Levels

| Severity | Impact | Response Time | Examples |
|----------|--------|---------------|----------|
| SEV-1 | Service down, data loss | < 15 min | Complete outage, payment failures |
| SEV-2 | Major feature broken | < 1 hour | Login broken, invoicing down |
| SEV-3 | Minor feature impacted | < 4 hours | Slow performance, UI bugs |
| SEV-4 | Cosmetic/low impact | < 24 hours | Typos, minor styling |

---

## 2. Incident Response Process

### 2.1 Detection

Incidents are detected via:

- **Monitoring Alerts** - Flare, uptime monitoring
- **User Reports** - Support tickets, direct contact
- **Internal Discovery** - Team members notice issues

### 2.2 Response Flow

```
Detection → Triage → Containment → Resolution → Post-Mortem
    ↓          ↓          ↓            ↓            ↓
 Alert     Severity   Stop harm    Fix issue   Learn &
 fires     assigned   spreading    root cause  improve
```

---

## 3. Triage Procedures

### 3.1 Initial Assessment

When incident detected:

1. **Acknowledge** - Claim the incident
2. **Assess** - Determine severity and impact
3. **Communicate** - Update status page/Slack
4. **Escalate** - If SEV-1 or SEV-2

### 3.2 Severity Assessment Questions

| Question | SEV-1 | SEV-2 | SEV-3 |
|----------|-------|-------|-------|
| Service accessible? | No | Partial | Yes |
| Data at risk? | Yes | No | No |
| Revenue impacted? | Yes | Maybe | No |
| Users affected? | All | Many | Few |

### 3.3 Declare Incident

```
# In Slack #incidents channel
@here SEV-2 Incident Declared: [Brief description]
- Impact: [Who/what is affected]
- Status: Investigating
- Commander: @username
- Timeline: [Start time]
```

---

## 4. Common Incidents

### 4.1 Application Down (SEV-1)

**Symptoms:**
- 502/503 errors
- Health check failing
- No response from server

**Diagnosis:**

```bash
# Check if server is reachable
ping agency-platform.com
curl -I https://agency-platform.com/

# SSH to server
ssh forge@production-server

# Check services
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
sudo supervisorctl status
```

**Resolution:**

```bash
# Restart PHP-FPM
sudo systemctl restart php8.3-fpm

# Restart Nginx
sudo systemctl restart nginx

# Restart queue workers
sudo supervisorctl restart all

# Check application logs
tail -100 /home/forge/agency-platform/storage/logs/laravel.log
```

### 4.2 Database Connection Failure (SEV-1)

**Symptoms:**
- "Connection refused" errors
- Slow/hanging requests
- Flare shows PDO exceptions

**Diagnosis:**

```bash
# Check database connectivity
php artisan tinker
>>> DB::connection()->getPdo();

# Check credentials
cat .env | grep DB_

# Check database status (DigitalOcean console)
```

**Resolution:**

```bash
# Clear config cache (if credentials changed)
php artisan config:clear
php artisan config:cache

# If connection limit reached
# Scale up database or kill long-running queries
```

### 4.3 Redis/Cache Failure (SEV-2)

**Symptoms:**
- Session errors
- Slow response times
- Queue not processing

**Diagnosis:**

```bash
# Test Redis connection
redis-cli -h $REDIS_HOST ping

# Check Redis memory
redis-cli -h $REDIS_HOST info memory
```

**Resolution:**

```bash
# Fallback to file cache temporarily
# In .env: CACHE_DRIVER=file

# Clear caches
php artisan cache:clear

# Restart workers
php artisan queue:restart
```

### 4.4 Payment Processing Failure (SEV-1)

**Symptoms:**
- Payment webhooks failing
- Customers unable to pay
- Stripe errors in Flare

**Diagnosis:**

```bash
# Check webhook endpoint
curl -I https://agency-platform.com/webhooks/stripe

# Check Stripe dashboard for webhook failures

# Check failed jobs
php artisan queue:failed
```

**Resolution:**

```bash
# Retry failed webhooks from Stripe dashboard

# Retry failed jobs
php artisan queue:retry all

# If webhook secret changed
# Update STRIPE_WEBHOOK_SECRET in .env
php artisan config:cache
```

### 4.5 High CPU/Memory Usage (SEV-2/3)

**Symptoms:**
- Slow response times
- Server alerts
- Requests timing out

**Diagnosis:**

```bash
# Check system resources
htop
df -h
free -m

# Find resource-heavy processes
ps aux --sort=-%mem | head -20
ps aux --sort=-%cpu | head -20

# Check for runaway queries
# In MySQL:
SHOW PROCESSLIST;
```

**Resolution:**

```bash
# Kill problematic processes
kill -9 <PID>

# Restart PHP-FPM (clears memory)
sudo systemctl restart php8.3-fpm

# If disk full, clear logs
sudo truncate -s 0 /var/log/nginx/access.log
php artisan log:clear
```

### 4.6 SSL Certificate Expiry (SEV-1)

**Symptoms:**
- Browser security warnings
- HTTPS not working
- Let's Encrypt errors

**Resolution:**

```bash
# Force certificate renewal via Forge
# Or manually:
sudo certbot renew --force-renewal

# Restart Nginx
sudo systemctl restart nginx
```

---

## 5. Communication

### 5.1 Internal Updates

Update every 30 minutes (SEV-1/2) or hourly (SEV-3):

```
[TIME] Incident Update
- Status: [Investigating/Identified/Monitoring/Resolved]
- Current state: [What's happening]
- Actions taken: [What we've done]
- Next steps: [What we're doing next]
- ETA: [When we expect resolution]
```

### 5.2 External Communication

For SEV-1/SEV-2 affecting customers:

**Status Page Update:**

```
[Investigating] Payment Processing Degraded
We are investigating issues with payment processing.
Some customers may experience delays.
We will provide an update within 30 minutes.
```

**Resolution Update:**

```
[Resolved] Payment Processing Restored
The issue affecting payment processing has been resolved.
All payments are now processing normally.
Duration: 45 minutes
Impact: Delayed payment confirmations
```

---

## 6. Escalation Matrix

### 6.1 When to Escalate

| Situation | Escalate To |
|-----------|-------------|
| SEV-1 not resolved in 30 min | Tech Lead |
| Data breach suspected | Security + Legal |
| Infrastructure provider issue | DevOps + Vendor |
| Customer-facing impact > 1 hour | Product + Support |

### 6.2 Escalation Contacts

| Role | Primary | Backup | Method |
|------|---------|--------|--------|
| On-Call | [Rotation] | [Rotation] | PagerDuty |
| Tech Lead | [Name] | [Name] | Phone/Slack |
| DevOps | [Name] | [Name] | Slack |
| Security | [Name] | [Name] | Phone |

---

## 7. Post-Incident

### 7.1 Immediate Actions

After resolution:

1. Confirm services restored
2. Update status page to "Resolved"
3. Notify stakeholders
4. Document timeline
5. Schedule post-mortem (SEV-1/2)

### 7.2 Post-Mortem Template

```markdown
# Post-Mortem: [Incident Title]

**Date:** YYYY-MM-DD
**Duration:** X hours Y minutes
**Severity:** SEV-X
**Author:** [Name]

## Summary
Brief description of what happened.

## Timeline
- HH:MM - First alert received
- HH:MM - Incident declared
- HH:MM - Root cause identified
- HH:MM - Fix deployed
- HH:MM - Incident resolved

## Root Cause
What actually caused the incident.

## Impact
- Users affected: X
- Revenue impact: $X
- Data loss: None/Description

## What Went Well
- Quick detection
- Effective communication

## What Went Wrong
- Delayed escalation
- Missing monitoring

## Action Items
| Action | Owner | Due Date |
|--------|-------|----------|
| Add monitoring for X | @name | YYYY-MM-DD |
| Update runbook for Y | @name | YYYY-MM-DD |

## Lessons Learned
Key takeaways for preventing similar incidents.
```

---

## 8. Preventive Measures

### 8.1 Monitoring Checklist

- [ ] Uptime monitoring configured
- [ ] Error tracking active (Flare)
- [ ] Database monitoring enabled
- [ ] Queue monitoring active
- [ ] Disk space alerts set
- [ ] SSL expiry alerts set

### 8.2 Regular Maintenance

| Task | Frequency | Owner |
|------|-----------|-------|
| Review error logs | Daily | On-call |
| Check queue health | Daily | On-call |
| Database backup verify | Weekly | DevOps |
| Security patches | Weekly | DevOps |
| Capacity planning | Monthly | Tech Lead |
| Runbook review | Quarterly | Team |

---

## Links

- [Deployment Runbook](./runbook-deployment.md)
- [ADR-0016: Error Monitoring](../03-decisions/adr-0016-error-monitoring-logging.md)
- [Flare Dashboard](https://flareapp.io/)
- [DigitalOcean Status](https://status.digitalocean.com/)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial incident runbook |
