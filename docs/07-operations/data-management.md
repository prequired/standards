---
id: OPS-DATA
title: Data Management Runbook
version: 1.0.0
status: active
owner: DevOps Team
last_updated: 2025-11-29
---

# Data Management Runbook

Procedures for database backups, data migrations, and data lifecycle management.

---

## Backup Strategy

### Backup Types

| Type | Frequency | Retention | Method |
|------|-----------|-----------|--------|
| Full backup | Daily (2 AM) | 30 days | mysqldump |
| Incremental | Hourly | 24 hours | Binary logs |
| Point-in-time | Continuous | 7 days | Binary logs |
| Offsite copy | Daily | 90 days | S3 sync |

### Automated Backup Schedule

```bash
# Crontab entries (server time = UTC)
0 2 * * * /opt/scripts/backup-full.sh >> /var/log/backup.log 2>&1
0 * * * * /opt/scripts/backup-incremental.sh >> /var/log/backup.log 2>&1
0 3 * * * /opt/scripts/backup-offsite.sh >> /var/log/backup.log 2>&1
```

### Backup Scripts

#### Full Backup Script

```bash
#!/bin/bash
# /opt/scripts/backup-full.sh

set -e

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/mysql"
DB_NAME="agency_platform"
S3_BUCKET="agency-backups"

# Create backup
mysqldump -u backup_user -p"${DB_PASSWORD}" \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    $DB_NAME | gzip > "${BACKUP_DIR}/full_${DATE}.sql.gz"

# Verify backup
gunzip -t "${BACKUP_DIR}/full_${DATE}.sql.gz"

# Upload to S3
aws s3 cp "${BACKUP_DIR}/full_${DATE}.sql.gz" \
    "s3://${S3_BUCKET}/mysql/full_${DATE}.sql.gz"

# Cleanup old local backups (keep 7 days)
find ${BACKUP_DIR} -name "full_*.sql.gz" -mtime +7 -delete

echo "[$(date)] Full backup completed: full_${DATE}.sql.gz"
```

#### Offsite Sync Script

```bash
#!/bin/bash
# /opt/scripts/backup-offsite.sh

set -e

S3_BUCKET="agency-backups"
BACKUP_DIR="/backups"

# Sync all backups to S3
aws s3 sync ${BACKUP_DIR} s3://${S3_BUCKET}/ \
    --exclude "*" \
    --include "*.sql.gz" \
    --include "*.tar.gz"

# Apply lifecycle policy (done via S3 bucket policy)
echo "[$(date)] Offsite sync completed"
```

---

## Restore Procedures

### Full Restore

```bash
#!/bin/bash
# restore-full.sh

set -e

BACKUP_FILE=$1
DB_NAME="agency_platform"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore-full.sh <backup_file.sql.gz>"
    exit 1
fi

# Stop application
sudo systemctl stop php8.3-fpm

# Create restore database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}_restore;"

# Restore
gunzip < $BACKUP_FILE | mysql -u root -p ${DB_NAME}_restore

# Verify
TABLES=$(mysql -u root -p -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB_NAME}_restore';")
echo "Restored database has $TABLES tables"

# Swap databases (if verified)
# mysql -u root -p -e "DROP DATABASE ${DB_NAME}; RENAME DATABASE ${DB_NAME}_restore TO ${DB_NAME};"

# Restart application
sudo systemctl start php8.3-fpm
```

### Point-in-Time Recovery

```bash
#!/bin/bash
# restore-point-in-time.sh

# 1. Restore most recent full backup
gunzip < /backups/mysql/full_latest.sql.gz | mysql -u root -p agency_platform_recovery

# 2. Apply binary logs up to desired point
mysqlbinlog --stop-datetime="2025-01-15 14:30:00" \
    /var/log/mysql/mysql-bin.000001 \
    /var/log/mysql/mysql-bin.000002 \
    | mysql -u root -p agency_platform_recovery

# 3. Verify and swap
```

### Restore from S3

```bash
#!/bin/bash
# restore-from-s3.sh

BACKUP_DATE=$1
S3_BUCKET="agency-backups"

# Download from S3
aws s3 cp "s3://${S3_BUCKET}/mysql/full_${BACKUP_DATE}.sql.gz" /tmp/

# Restore
gunzip < /tmp/full_${BACKUP_DATE}.sql.gz | mysql -u root -p agency_platform
```

---

## Data Migration

### Migration Best Practices

1. **Always backup first** - Full backup before any migration
2. **Use transactions** - Wrap in transaction when possible
3. **Test on staging** - Run migration on staging first
4. **Have rollback plan** - Prepare reverse migration
5. **Monitor performance** - Watch for locks and slow queries

### Large Data Migration

```php
// database/migrations/2025_01_15_000000_migrate_legacy_data.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Process in chunks to avoid memory issues
        DB::table('legacy_clients')
            ->orderBy('id')
            ->chunk(1000, function ($legacyClients) {
                $clients = $legacyClients->map(fn ($legacy) => [
                    'name' => $legacy->company_name,
                    'email' => $legacy->contact_email,
                    'created_at' => $legacy->created_date,
                    'updated_at' => now(),
                ]);

                DB::table('clients')->insert($clients->toArray());
            });
    }

    public function down(): void
    {
        // Rollback: delete migrated records
        DB::table('clients')
            ->whereNotNull('migrated_from_legacy_id')
            ->delete();
    }
};
```

### Zero-Downtime Migration

For migrations that add columns:

```php
// Step 1: Add nullable column (no downtime)
Schema::table('projects', function (Blueprint $table) {
    $table->string('new_field')->nullable()->after('existing_field');
});

// Step 2: Backfill data (background job)
Project::query()
    ->whereNull('new_field')
    ->chunk(1000, function ($projects) {
        foreach ($projects as $project) {
            $project->update(['new_field' => $this->calculateValue($project)]);
        }
    });

// Step 3: Make non-nullable (after backfill complete)
Schema::table('projects', function (Blueprint $table) {
    $table->string('new_field')->nullable(false)->change();
});
```

---

## Data Seeding

### Development Seeding

```bash
# Fresh database with all seeders
php artisan migrate:fresh --seed

# Run specific seeder
php artisan db:seed --class=ClientSeeder

# Reset and reseed specific tables
php artisan db:seed --class=DemoDataSeeder --force
```

### Production Data Seeding

```bash
# Never use --seed in production!
# Use specific seeders with caution

# Add initial admin user
php artisan db:seed --class=AdminUserSeeder --force

# Add system configuration
php artisan db:seed --class=SystemConfigSeeder --force
```

### Refresh Staging from Production

```bash
#!/bin/bash
# refresh-staging.sh

set -e

# 1. Create production snapshot
mysqldump -h production-db -u user -p agency_platform | gzip > /tmp/prod_snapshot.sql.gz

# 2. Anonymize sensitive data
gunzip < /tmp/prod_snapshot.sql.gz | \
    sed "s/\([A-Za-z0-9._%+-]*\)@\([A-Za-z0-9.-]*\)\.\([A-Za-z]*\)/anonymized@example.com/g" | \
    gzip > /tmp/staging_snapshot.sql.gz

# 3. Restore to staging
gunzip < /tmp/staging_snapshot.sql.gz | mysql -h staging-db -u user -p agency_platform

# 4. Run anonymization script
php artisan staging:anonymize

# 5. Cleanup
rm /tmp/prod_snapshot.sql.gz /tmp/staging_snapshot.sql.gz
```

### Anonymization Script

```php
// app/Console/Commands/AnonymizeStagingData.php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Faker\Factory as Faker;

class AnonymizeStagingData extends Command
{
    protected $signature = 'staging:anonymize';

    public function handle(): void
    {
        $faker = Faker::create();

        // Anonymize users
        DB::table('users')->update([
            'email' => DB::raw("CONCAT('user', id, '@staging.test')"),
            'password' => bcrypt('staging-password'),
        ]);

        // Anonymize clients
        DB::table('clients')->get()->each(function ($client) use ($faker) {
            DB::table('clients')->where('id', $client->id)->update([
                'name' => $faker->company,
                'email' => $faker->companyEmail,
                'phone' => $faker->phoneNumber,
            ]);
        });

        // Clear sensitive tokens
        DB::table('personal_access_tokens')->truncate();
        DB::table('password_reset_tokens')->truncate();

        $this->info('Staging data anonymized successfully.');
    }
}
```

---

## Data Retention

### Retention Policy

| Data Type | Retention Period | Action at Expiry |
|-----------|------------------|------------------|
| User sessions | 30 days | Auto-delete |
| Password reset tokens | 1 hour | Auto-delete |
| Audit logs | 2 years | Archive |
| Deleted records (soft) | 90 days | Hard delete |
| Time entries | Indefinite | Archive after 5 years |
| Invoices | 7 years | Archive |
| Backups (local) | 30 days | Delete |
| Backups (offsite) | 1 year | Move to Glacier |

### Automated Cleanup

```php
// app/Console/Commands/CleanupOldData.php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CleanupOldData extends Command
{
    protected $signature = 'cleanup:old-data';

    public function handle(): void
    {
        // Delete expired sessions
        DB::table('sessions')
            ->where('last_activity', '<', now()->subDays(30)->timestamp)
            ->delete();

        // Delete expired password resets
        DB::table('password_reset_tokens')
            ->where('created_at', '<', now()->subHour())
            ->delete();

        // Force delete old soft-deleted records
        $models = [
            \App\Models\Project::class,
            \App\Models\Task::class,
            \App\Models\TimeEntry::class,
        ];

        foreach ($models as $model) {
            $model::onlyTrashed()
                ->where('deleted_at', '<', now()->subDays(90))
                ->forceDelete();
        }

        $this->info('Old data cleaned up successfully.');
    }
}
```

### Archive Old Data

```php
// app/Console/Commands/ArchiveOldData.php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ArchiveOldData extends Command
{
    protected $signature = 'archive:old-data {--year=}';

    public function handle(): void
    {
        $year = $this->option('year') ?? now()->subYears(5)->year;

        // Export old time entries to JSON
        $entries = DB::table('time_entries')
            ->whereYear('created_at', '<=', $year)
            ->get();

        $filename = "archives/time_entries_{$year}.json";
        Storage::put($filename, $entries->toJson());

        // Upload to cold storage
        Storage::disk('s3-glacier')->put($filename, Storage::get($filename));

        // Delete from primary database
        DB::table('time_entries')
            ->whereYear('created_at', '<=', $year)
            ->delete();

        $this->info("Archived {$entries->count()} time entries from {$year}");
    }
}
```

---

## Data Integrity

### Integrity Checks

```php
// app/Console/Commands/CheckDataIntegrity.php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class CheckDataIntegrity extends Command
{
    protected $signature = 'data:check-integrity';

    public function handle(): void
    {
        $errors = [];

        // Check for orphaned records
        $orphanedTasks = DB::table('tasks')
            ->leftJoin('projects', 'tasks.project_id', '=', 'projects.id')
            ->whereNull('projects.id')
            ->count();

        if ($orphanedTasks > 0) {
            $errors[] = "Found {$orphanedTasks} orphaned tasks";
        }

        // Check for invalid invoice totals
        $invalidInvoices = DB::table('invoices')
            ->whereRaw('total_cents != (subtotal_cents + tax_cents)')
            ->count();

        if ($invalidInvoices > 0) {
            $errors[] = "Found {$invalidInvoices} invoices with incorrect totals";
        }

        // Report results
        if (empty($errors)) {
            $this->info('Data integrity check passed.');
        } else {
            foreach ($errors as $error) {
                $this->error($error);
            }
            return 1;
        }
    }
}
```

---

## Disaster Recovery

### RTO/RPO Targets

| Metric | Target | Current |
|--------|--------|---------|
| Recovery Time Objective (RTO) | 4 hours | 2 hours |
| Recovery Point Objective (RPO) | 1 hour | 1 hour |

### Recovery Procedure

1. **Assess damage** - Determine scope of data loss
2. **Notify stakeholders** - Alert management and affected users
3. **Select recovery point** - Choose appropriate backup
4. **Restore to staging** - Test restore in staging first
5. **Validate data** - Run integrity checks
6. **Promote to production** - Switch to restored database
7. **Post-mortem** - Document incident and improvements

### Recovery Checklist

- [ ] Identify most recent valid backup
- [ ] Verify backup integrity (gunzip -t)
- [ ] Create new database for restore
- [ ] Restore backup to new database
- [ ] Run data integrity checks
- [ ] Compare record counts with last known good
- [ ] Test application with restored database
- [ ] Update application config to use restored database
- [ ] Verify all services operational
- [ ] Document recovery time and data loss

---

## Related Documents

- [Common Tasks Runbook](./runbook-common-tasks.md)
- [Incident Response](./runbook-incidents.md)
- [Deployment Runbook](./runbook-deployment.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial data management runbook |
