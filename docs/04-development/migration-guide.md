---
id: "DEV-MIGRATIONS"
title: "Database Migration & Seeding Strategy"
version: "1.0.0"
status: "active"
owner: "Tech Lead"
last_updated: "2025-11-30"
---

# Database Migration & Seeding Strategy

Standards for database schema management, migrations, and data seeding in the Agency Platform.

---

## Migration Principles

### Core Guidelines

1. **Migrations are immutable** - Once deployed, never modify a migration
2. **Always reversible** - Every `up()` must have a corresponding `down()`
3. **Atomic changes** - One logical change per migration
4. **Safe deployments** - Zero-downtime compatible where possible
5. **Tested locally** - Run migrations and rollbacks before committing

---

## Naming Conventions

### Migration File Names

```bash
# Format: YYYY_MM_DD_HHMMSS_action_table_description.php

# Creating tables
2025_01_15_100000_create_projects_table.php
2025_01_15_100001_create_tasks_table.php

# Adding columns
2025_01_20_143000_add_budget_cents_to_projects_table.php
2025_01_20_143001_add_priority_to_tasks_table.php

# Removing columns
2025_01_25_090000_drop_legacy_status_from_projects_table.php

# Modifying columns
2025_01_26_110000_change_description_to_text_on_tasks_table.php

# Adding indexes
2025_01_27_140000_add_index_to_tasks_status_column.php

# Pivot tables
2025_01_28_100000_create_project_user_table.php

# Complex changes
2025_02_01_150000_refactor_billing_tables.php
```

---

## Migration Structure

### Standard Table Creation

```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            // Primary key
            $table->id();

            // Foreign keys (defined near top)
            $table->foreignId('client_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('owner_id')
                ->nullable()
                ->constrained('users')
                ->nullOnDelete();

            // Core fields
            $table->string('name');
            $table->text('description')->nullable();

            // Status/enum fields
            $table->string('status')->default('draft');
            $table->string('priority')->default('medium');

            // Money fields (always in cents)
            $table->bigInteger('budget_cents')->nullable();
            $table->integer('hourly_rate_cents')->nullable();

            // Date/time fields
            $table->date('due_date')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();

            // Boolean fields
            $table->boolean('is_billable')->default(true);
            $table->boolean('is_archived')->default(false);

            // Timestamps and soft deletes (always at end)
            $table->timestamps();
            $table->softDeletes();

            // Indexes (after column definitions)
            $table->index('status');
            $table->index(['client_id', 'status']);
            $table->index('due_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};
```

### Adding Columns

```php
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('projects', function (Blueprint $table) {
            // Add after specific column for logical ordering
            $table->integer('estimated_hours')
                ->nullable()
                ->after('budget_cents');

            $table->string('external_reference')
                ->nullable()
                ->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('projects', function (Blueprint $table) {
            $table->dropColumn(['estimated_hours', 'external_reference']);
        });
    }
};
```

### Safe Column Modifications

```php
return new class extends Migration
{
    public function up(): void
    {
        // For column type changes, use doctrine/dbal
        Schema::table('projects', function (Blueprint $table) {
            $table->text('description')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('projects', function (Blueprint $table) {
            $table->string('description', 255)->nullable()->change();
        });
    }
};
```

---

## Data Type Standards

### Standard Column Types

| Data Type | Laravel Column | Notes |
|-----------|---------------|-------|
| Primary Key | `$table->id()` | Auto-incrementing BigInt |
| UUID | `$table->uuid('id')->primary()` | For distributed systems |
| Foreign Key | `$table->foreignId('user_id')` | Use with `->constrained()` |
| String | `$table->string('name', 255)` | Default 255 chars |
| Long Text | `$table->text('description')` | For descriptions |
| Rich Text | `$table->longText('content')` | For HTML/Markdown |
| Money | `$table->bigInteger('amount_cents')` | Always store in cents |
| Percentage | `$table->decimal('rate', 5, 2)` | e.g., 15.50% |
| Boolean | `$table->boolean('is_active')` | Prefix with `is_`, `has_`, `can_` |
| Status/Enum | `$table->string('status')` | Use string, not enum() |
| Date Only | `$table->date('due_date')` | No time component |
| DateTime | `$table->timestamp('sent_at')` | With timezone awareness |
| JSON | `$table->json('metadata')` | For flexible schemas |

### Money Handling

```php
// ALWAYS store money in cents as integers
$table->bigInteger('amount_cents');           // Total amount
$table->bigInteger('subtotal_cents');         // Before tax
$table->bigInteger('tax_cents');              // Tax amount
$table->integer('hourly_rate_cents');         // Rate per hour
$table->decimal('tax_rate', 5, 2);            // Percentage (e.g., 20.00)

// In model
protected $casts = [
    'amount_cents' => 'integer',
];

public function getAmountAttribute(): float
{
    return $this->amount_cents / 100;
}

public function setAmountAttribute(float $value): void
{
    $this->attributes['amount_cents'] = (int) ($value * 100);
}
```

### Enum Handling

```php
// DON'T use MySQL ENUM (hard to modify)
// ❌ $table->enum('status', ['draft', 'active', 'completed']);

// DO use string column with PHP enum
// ✅ $table->string('status')->default('draft');

// Define PHP Enum
enum ProjectStatus: string
{
    case Draft = 'draft';
    case Active = 'active';
    case OnHold = 'on_hold';
    case Completed = 'completed';
    case Archived = 'archived';

    public function label(): string
    {
        return match($this) {
            self::Draft => 'Draft',
            self::Active => 'Active',
            self::OnHold => 'On Hold',
            self::Completed => 'Completed',
            self::Archived => 'Archived',
        };
    }

    public function color(): string
    {
        return match($this) {
            self::Draft => 'gray',
            self::Active => 'green',
            self::OnHold => 'yellow',
            self::Completed => 'blue',
            self::Archived => 'red',
        };
    }
}

// In model
protected $casts = [
    'status' => ProjectStatus::class,
];
```

---

## Foreign Key Strategies

### Cascade Behaviors

```php
// Delete children when parent deleted
$table->foreignId('project_id')
    ->constrained()
    ->cascadeOnDelete();

// Set null when parent deleted (requires nullable)
$table->foreignId('assignee_id')
    ->nullable()
    ->constrained('users')
    ->nullOnDelete();

// Restrict deletion if children exist
$table->foreignId('client_id')
    ->constrained()
    ->restrictOnDelete();

// Cascade updates (rarely needed)
$table->foreignId('category_id')
    ->constrained()
    ->cascadeOnUpdate()
    ->cascadeOnDelete();
```

### Decision Guide

| Relationship | On Delete | Rationale |
|--------------|-----------|-----------|
| Project → Tasks | CASCADE | Tasks meaningless without project |
| Task → Time Entries | CASCADE | Time entries belong to task |
| Project → Client | RESTRICT | Protect client data |
| Task → Assignee (User) | SET NULL | Keep task, clear assignment |
| Invoice → Project | SET NULL | Keep invoice history |

---

## Index Strategy

### When to Add Indexes

```php
// 1. Foreign keys (automatic in Laravel)
$table->foreignId('client_id')->constrained();

// 2. Frequently filtered columns
$table->index('status');
$table->index('created_at');

// 3. Composite indexes for common query patterns
$table->index(['client_id', 'status']);           // Client's projects by status
$table->index(['user_id', 'date']);               // User's time entries by date
$table->index(['project_id', 'billable', 'billed']); // Unbilled time entries

// 4. Unique constraints
$table->unique('email');
$table->unique(['client_id', 'number'], 'unique_invoice_per_client');

// 5. Partial indexes (MySQL 8.0+)
// Use raw SQL for partial indexes if needed
```

### Index Naming

```php
// Laravel auto-generates: tablename_column_index
// For composite: tablename_col1_col2_index

// Custom names for clarity
$table->index(['status', 'due_date'], 'projects_active_due_index');
$table->unique(['email'], 'users_email_unique');
```

---

## Zero-Downtime Migrations

### Safe Operations (No Locking)

```php
// ✅ Adding nullable column
$table->string('new_field')->nullable()->after('existing');

// ✅ Adding index concurrently (PostgreSQL)
DB::statement('CREATE INDEX CONCURRENTLY ...');

// ✅ Adding column with default (MySQL 8.0+, PostgreSQL)
$table->boolean('is_featured')->default(false);
```

### Dangerous Operations (Require Care)

```php
// ⚠️ Renaming columns (locks table)
$table->renameColumn('old_name', 'new_name');

// ⚠️ Changing column type (may rewrite table)
$table->text('description')->change();

// ⚠️ Adding NOT NULL without default
$table->string('required_field');  // Will fail if rows exist

// ⚠️ Dropping columns (locks briefly)
$table->dropColumn('old_field');
```

### Safe Multi-Step Migration Pattern

```php
// Step 1: Add new nullable column (migration 1)
$table->string('new_status')->nullable();

// Step 2: Backfill data (queue job, not migration)
Project::chunk(1000, function ($projects) {
    foreach ($projects as $project) {
        $project->update(['new_status' => $project->old_status]);
    }
});

// Step 3: Add constraints after backfill (migration 2)
$table->string('new_status')->nullable(false)->change();

// Step 4: Drop old column (migration 3, after deploy verification)
$table->dropColumn('old_status');
```

---

## Seeding Strategy

### Seeder Organization

```
database/seeders/
├── DatabaseSeeder.php          # Main orchestrator
├── Production/
│   ├── RolesAndPermissionsSeeder.php
│   └── DefaultSettingsSeeder.php
├── Development/
│   ├── UserSeeder.php
│   ├── ClientSeeder.php
│   ├── ProjectSeeder.php
│   └── InvoiceSeeder.php
└── Testing/
    └── TestDataSeeder.php
```

### Environment-Aware Seeding

```php
// database/seeders/DatabaseSeeder.php
<?php

declare(strict_types=1);

namespace Database\Seeders;

use Illuminate\Database\Seeder;

final class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Always run (required for app to function)
        $this->call([
            Production\RolesAndPermissionsSeeder::class,
            Production\DefaultSettingsSeeder::class,
        ]);

        // Development/staging only
        if (app()->environment(['local', 'staging'])) {
            $this->call([
                Development\UserSeeder::class,
                Development\ClientSeeder::class,
                Development\ProjectSeeder::class,
                Development\InvoiceSeeder::class,
            ]);
        }
    }
}
```

### Production Seeder Example

```php
// database/seeders/Production/RolesAndPermissionsSeeder.php
<?php

declare(strict_types=1);

namespace Database\Seeders\Production;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

final class RolesAndPermissionsSeeder extends Seeder
{
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // Create permissions
        $permissions = [
            // Projects
            'view projects',
            'create projects',
            'edit projects',
            'delete projects',

            // Invoices
            'view invoices',
            'create invoices',
            'send invoices',
            'void invoices',

            // Users
            'view users',
            'create users',
            'edit users',
            'delete users',
            'impersonate users',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission]);
        }

        // Create roles with permissions
        $admin = Role::firstOrCreate(['name' => 'admin']);
        $admin->syncPermissions(Permission::all());

        $manager = Role::firstOrCreate(['name' => 'manager']);
        $manager->syncPermissions([
            'view projects', 'create projects', 'edit projects',
            'view invoices', 'create invoices', 'send invoices',
            'view users',
        ]);

        $staff = Role::firstOrCreate(['name' => 'staff']);
        $staff->syncPermissions([
            'view projects',
            'view invoices',
        ]);
    }
}
```

### Development Seeder Example

```php
// database/seeders/Development/ProjectSeeder.php
<?php

declare(strict_types=1);

namespace Database\Seeders\Development;

use App\Models\Client;
use App\Models\Project;
use App\Models\Task;
use App\Models\TimeEntry;
use App\Models\User;
use Illuminate\Database\Seeder;

final class ProjectSeeder extends Seeder
{
    public function run(): void
    {
        $clients = Client::all();
        $users = User::where('role', 'staff')->get();

        // Create realistic project distribution
        foreach ($clients as $client) {
            // 2-5 projects per client
            $projectCount = fake()->numberBetween(2, 5);

            Project::factory($projectCount)
                ->for($client)
                ->create()
                ->each(function (Project $project) use ($users) {
                    // 5-15 tasks per project
                    $tasks = Task::factory(fake()->numberBetween(5, 15))
                        ->for($project)
                        ->create();

                    // Time entries for some tasks
                    $tasks->random(min(5, $tasks->count()))
                        ->each(function (Task $task) use ($users, $project) {
                            TimeEntry::factory(fake()->numberBetween(1, 5))
                                ->for($task)
                                ->for($project)
                                ->for($users->random())
                                ->create();
                        });
                });
        }
    }
}
```

---

## Factory Standards

### Factory Structure

```php
// database/factories/ProjectFactory.php
<?php

declare(strict_types=1);

namespace Database\Factories;

use App\Enums\ProjectStatus;
use App\Models\Client;
use App\Models\Project;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Project>
 */
final class ProjectFactory extends Factory
{
    protected $model = Project::class;

    public function definition(): array
    {
        $status = fake()->randomElement(ProjectStatus::cases());
        $startDate = fake()->dateTimeBetween('-6 months', 'now');

        return [
            'client_id' => Client::factory(),
            'name' => fake()->catchPhrase(),
            'description' => fake()->paragraph(),
            'status' => $status,
            'budget_cents' => fake()->optional(0.7)->numberBetween(100000, 5000000),
            'hourly_rate_cents' => fake()->randomElement([7500, 10000, 12500, 15000]),
            'due_date' => fake()->optional(0.8)->dateTimeBetween('now', '+3 months'),
            'started_at' => $status !== ProjectStatus::Draft ? $startDate : null,
            'completed_at' => $status === ProjectStatus::Completed
                ? fake()->dateTimeBetween($startDate, 'now')
                : null,
        ];
    }

    // State methods for common scenarios
    public function draft(): static
    {
        return $this->state(fn () => [
            'status' => ProjectStatus::Draft,
            'started_at' => null,
            'completed_at' => null,
        ]);
    }

    public function active(): static
    {
        return $this->state(fn () => [
            'status' => ProjectStatus::Active,
            'started_at' => fake()->dateTimeBetween('-3 months', '-1 week'),
            'completed_at' => null,
        ]);
    }

    public function completed(): static
    {
        $startDate = fake()->dateTimeBetween('-6 months', '-1 month');

        return $this->state(fn () => [
            'status' => ProjectStatus::Completed,
            'started_at' => $startDate,
            'completed_at' => fake()->dateTimeBetween($startDate, 'now'),
        ]);
    }

    public function overdue(): static
    {
        return $this->state(fn () => [
            'status' => ProjectStatus::Active,
            'due_date' => fake()->dateTimeBetween('-2 weeks', '-1 day'),
        ]);
    }

    public function forClient(Client $client): static
    {
        return $this->state(fn () => [
            'client_id' => $client->id,
        ]);
    }

    public function withTasks(int $count = 5): static
    {
        return $this->has(Task::factory($count));
    }

    public function withTimeEntries(int $count = 10): static
    {
        return $this->has(TimeEntry::factory($count));
    }
}
```

---

## Rollback Procedures

### Local Development

```bash
# Rollback last batch
php artisan migrate:rollback

# Rollback specific steps
php artisan migrate:rollback --step=3

# Rollback and re-run all
php artisan migrate:refresh

# Rollback, re-run, and seed
php artisan migrate:refresh --seed

# Fresh install (drops all tables)
php artisan migrate:fresh --seed
```

### Production Rollback

```bash
# 1. Check current migration status
php artisan migrate:status

# 2. Rollback specific batch (carefully!)
php artisan migrate:rollback --step=1

# 3. NEVER use migrate:fresh in production

# 4. For data-affecting rollbacks, restore from backup
```

### Emergency Procedures

```bash
# If migration fails mid-execution:

# 1. Check what was applied
php artisan migrate:status

# 2. Manually fix schema if needed
# (Connect to DB directly)

# 3. Mark migration as run without executing
# Add to migrations table manually if needed

# 4. Always have database backups before deploying migrations
```

---

## Testing Migrations

### Migration Test

```php
// tests/Feature/Migrations/CreateProjectsTableTest.php
<?php

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;

uses(RefreshDatabase::class);

test('projects table has expected columns', function () {
    expect(Schema::hasTable('projects'))->toBeTrue();

    expect(Schema::hasColumns('projects', [
        'id',
        'client_id',
        'name',
        'description',
        'status',
        'budget_cents',
        'due_date',
        'created_at',
        'updated_at',
        'deleted_at',
    ]))->toBeTrue();
});

test('projects table has correct indexes', function () {
    $indexes = collect(DB::select("SHOW INDEX FROM projects"))
        ->pluck('Key_name')
        ->unique()
        ->values();

    expect($indexes)->toContain('projects_client_id_foreign');
    expect($indexes)->toContain('projects_status_index');
});
```

---

## Related Documentation

- [Database Schema](../02-architecture/database-schema.md) - Full ERD
- [Development Standards](./dev-standards.md) - Code standards
- [Testing Strategy](../06-testing/testing-strategy.md) - Test setup
- [CI/CD Pipeline](../07-operations/ci-cd-pipeline.md) - Deployment

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-30 | 1.0.0 | Claude | Initial migration guide |
