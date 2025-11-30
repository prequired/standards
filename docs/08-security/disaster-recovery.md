---
id: SEC-DR
title: Disaster Recovery Plan
version: 1.0.0
status: active
owner: DevOps Team
last_updated: 2025-11-29
classification: internal
---

# Disaster Recovery Plan

Procedures for recovering the Agency Platform from major outages and disasters.

---

## Recovery Objectives

| Metric | Target | Current Capability |
|--------|--------|-------------------|
| **RTO** (Recovery Time Objective) | 4 hours | 2-4 hours |
| **RPO** (Recovery Point Objective) | 1 hour | 1 hour (hourly backups) |
| **MTTR** (Mean Time to Recovery) | 2 hours | 2 hours |

---

## Disaster Scenarios

### Tier 1: Infrastructure Failure

| Scenario | RTO | RPO | Recovery Procedure |
|----------|-----|-----|-------------------|
| Single server failure | 30 min | 0 | Auto-failover via load balancer |
| Database failure | 1 hour | 1 hour | Restore from replica/backup |
| Redis failure | 15 min | 0 | Restart service, cache rebuilds |
| Storage (S3) unavailable | 1 hour | 0 | Switch to backup region |

### Tier 2: Data Center Failure

| Scenario | RTO | RPO | Recovery Procedure |
|----------|-----|-----|-------------------|
| Single region outage | 2 hours | 1 hour | Deploy to backup region |
| Provider-wide outage | 4 hours | 1 hour | Deploy to alternate provider |

### Tier 3: Data Loss/Corruption

| Scenario | RTO | RPO | Recovery Procedure |
|----------|-----|-----|-------------------|
| Accidental deletion | 1 hour | 1 hour | Restore from backup |
| Data corruption | 2 hours | 1 hour | PITR to pre-corruption |
| Ransomware | 4 hours | 24 hours | Clean restore from offline backup |

---

## Backup Strategy

### Backup Schedule

| Type | Frequency | Retention | Location |
|------|-----------|-----------|----------|
| Database full | Daily 2 AM | 30 days | S3 primary |
| Database incremental | Hourly | 24 hours | S3 primary |
| Binary logs | Continuous | 7 days | Local + S3 |
| File storage | Daily sync | 90 days | S3 replica region |
| Configuration | On change | Indefinite | Git repository |

### Backup Locations

```
Primary: DigitalOcean Spaces (NYC3)
    └── agency-backups/
        ├── mysql/
        │   ├── full/
        │   └── incremental/
        ├── files/
        └── config/

Secondary: DigitalOcean Spaces (SFO3)
    └── agency-backups-replica/
        └── [mirror of primary]

Offline: Encrypted external storage (monthly)
    └── [critical data snapshot]
```

### Backup Verification

```bash
# Weekly backup verification
#!/bin/bash
set -e

# 1. Download latest backup
aws s3 cp s3://agency-backups/mysql/full/latest.sql.gz /tmp/

# 2. Verify integrity
gunzip -t /tmp/latest.sql.gz

# 3. Test restore to verification database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS backup_verify;"
gunzip < /tmp/latest.sql.gz | mysql -u root -p backup_verify

# 4. Run data integrity checks
php artisan backup:verify

# 5. Cleanup
mysql -u root -p -e "DROP DATABASE backup_verify;"
rm /tmp/latest.sql.gz

echo "Backup verification completed successfully"
```

---

## Recovery Procedures

### Procedure 1: Database Recovery

**Trigger:** Database server failure or corruption

**Steps:**

1. **Assess damage**
   ```bash
   # Check database status
   mysql -u root -p -e "SHOW STATUS LIKE 'Uptime';"

   # Check for corruption
   mysqlcheck -u root -p --all-databases --check
   ```

2. **Failover to replica** (if available)
   ```bash
   # Promote replica to primary
   mysql -u root -p -e "STOP REPLICA; RESET REPLICA ALL;"

   # Update application config
   # Update DB_HOST in .env or environment variables
   ```

3. **Restore from backup** (if no replica)
   ```bash
   # Download latest backup
   aws s3 cp s3://agency-backups/mysql/full/latest.sql.gz /tmp/

   # Create new database
   mysql -u root -p -e "CREATE DATABASE agency_platform_restored;"

   # Restore
   gunzip < /tmp/latest.sql.gz | mysql -u root -p agency_platform_restored

   # Apply binary logs for PITR (if needed)
   mysqlbinlog --start-datetime="2025-01-15 10:00:00" \
     /var/log/mysql/mysql-bin.* | mysql -u root -p agency_platform_restored

   # Swap databases
   mysql -u root -p -e "
     DROP DATABASE agency_platform;
     RENAME DATABASE agency_platform_restored TO agency_platform;
   "
   ```

4. **Verify restoration**
   ```bash
   php artisan migrate:status
   php artisan tinker
   >>> User::count()
   >>> Project::count()
   ```

5. **Resume operations**
   ```bash
   php artisan up
   php artisan queue:restart
   ```

---

### Procedure 2: Full Application Recovery

**Trigger:** Complete infrastructure loss

**Steps:**

1. **Provision new infrastructure**
   ```bash
   # Using Laravel Forge or Terraform
   # Create new droplet in backup region
   # Configure: PHP 8.3, MySQL 8, Redis, Nginx
   ```

2. **Deploy application**
   ```bash
   # Clone repository
   git clone git@github.com:agency/platform.git /var/www/platform
   cd /var/www/platform

   # Install dependencies
   composer install --no-dev --optimize-autoloader
   npm install && npm run build

   # Configure environment
   cp .env.production .env
   # Update database credentials, keys, etc.
   ```

3. **Restore database**
   ```bash
   # Download and restore latest backup
   aws s3 cp s3://agency-backups/mysql/full/latest.sql.gz /tmp/
   gunzip < /tmp/latest.sql.gz | mysql -u root -p agency_platform
   ```

4. **Restore file storage**
   ```bash
   # Sync from S3 backup
   aws s3 sync s3://agency-backups/files/ storage/app/
   ```

5. **Configure services**
   ```bash
   # Cache configuration
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache

   # Run any pending migrations
   php artisan migrate --force

   # Start queue workers
   supervisorctl start all
   ```

6. **Update DNS**
   - Point domain to new server IP
   - Wait for propagation (or use low TTL)

7. **Verify and monitor**
   ```bash
   curl https://app.agency.com/api/health
   # Monitor for 24 hours
   ```

---

### Procedure 3: Ransomware Recovery

**Trigger:** Ransomware detected on systems

**CRITICAL:** Do not pay ransom. Restore from clean backups.

**Steps:**

1. **Isolate affected systems**
   - Disconnect from network
   - Do NOT power off (preserve evidence)

2. **Assess scope**
   - Which systems affected?
   - When did encryption start?
   - Is backup infrastructure compromised?

3. **Verify backup integrity**
   ```bash
   # Check offline backups first
   # Verify backups from BEFORE infection date
   gunzip -t /offline/backup_2025-01-01.sql.gz
   ```

4. **Rebuild from scratch**
   - Provision entirely new infrastructure
   - Do NOT restore from potentially infected backups
   - Use backups verified as pre-infection

5. **Restore data**
   - Use oldest clean backup
   - Accept data loss between backup and infection
   - Manually recreate critical recent data if possible

6. **Harden systems**
   - Patch all vulnerabilities
   - Implement additional monitoring
   - Review access controls

7. **Report incident**
   - Follow incident response procedures
   - Notify authorities if required
   - Notify affected customers

---

## Communication Plan

### Internal Communication

| Event | Notify | Channel | Template |
|-------|--------|---------|----------|
| Disaster declared | All staff | Slack + SMS | DR-001 |
| Recovery in progress | Engineering | Slack | DR-002 |
| Recovery complete | All staff | Slack + Email | DR-003 |

### External Communication

| Event | Notify | Channel | Owner |
|-------|--------|---------|-------|
| Service disruption | Customers | Status page | Communications |
| Extended outage (>1hr) | Customers | Email | Communications |
| Recovery complete | Customers | Status page + Email | Communications |

### Status Page Updates

```
# Initial outage
Title: Service Disruption
Body: We are currently experiencing a service disruption.
Our team is investigating and working to restore service.
We will provide updates every 30 minutes.

# In progress
Title: Recovery In Progress
Body: We have identified the issue and are actively
working on recovery. Estimated time to recovery: [X hours].

# Resolved
Title: Service Restored
Body: Service has been fully restored. We apologize for
any inconvenience. A post-incident report will be published
within 48 hours.
```

---

## DR Testing

### Test Schedule

| Test Type | Frequency | Duration | Participants |
|-----------|-----------|----------|--------------|
| Backup verification | Weekly | 1 hour | Automated |
| Database restore | Monthly | 2 hours | DevOps |
| Full DR simulation | Quarterly | 4-8 hours | All engineering |
| Tabletop exercise | Annually | 2 hours | All stakeholders |

### Test Checklist

- [ ] Backups accessible from secondary location
- [ ] Backup restoration completes successfully
- [ ] Application starts with restored data
- [ ] All critical functions work
- [ ] Performance acceptable
- [ ] DNS failover works
- [ ] Communication channels function
- [ ] Documentation accurate

### Test Documentation

After each DR test, document:
- Test date and duration
- Scenarios tested
- Issues encountered
- Time to recovery achieved
- Action items for improvement

---

## Roles and Responsibilities

| Role | Primary | Backup | Responsibilities |
|------|---------|--------|------------------|
| DR Coordinator | CTO | Tech Lead | Declare disaster, coordinate recovery |
| Infrastructure | DevOps Lead | Sr. Engineer | Server/network recovery |
| Database | DBA | DevOps | Database restoration |
| Application | Tech Lead | Sr. Developer | Application deployment |
| Communications | CEO | COO | Stakeholder updates |

---

## Checklist: Disaster Declaration

Before declaring a disaster:

- [ ] Confirmed outage is not recoverable through normal means
- [ ] Estimated downtime exceeds acceptable threshold
- [ ] DR Coordinator notified and available
- [ ] Recovery team available
- [ ] Communication channels established

---

## Recovery Validation

Before declaring recovery complete:

- [ ] All services responding
- [ ] Database integrity verified
- [ ] User authentication working
- [ ] Payment processing functional
- [ ] Email delivery working
- [ ] File storage accessible
- [ ] API endpoints responding
- [ ] Background jobs processing
- [ ] Monitoring active
- [ ] No data loss beyond RPO

---

## Related Documents

- [Incident Response](./incident-response.md)
- [Data Management](../07-operations/data-management.md)
- [Deployment Runbook](../07-operations/runbook-deployment.md)
- [ADR-0011: Infrastructure](../03-decisions/adr-0011-infrastructure-hosting.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial disaster recovery plan |
