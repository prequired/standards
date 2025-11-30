# Development Standards

**Version:** 1.0.0
**Last Updated:** 2025-11-29
**Applies To:** Agency Platform

---

## 1. Overview

This document defines the development standards, coding conventions, and workflows for the Agency Platform. All contributors must follow these standards to maintain code quality and consistency.

### 1.1 Guiding Principles

1. **Follow Laravel conventions first** - Only deviate with clear justification
2. **Write expressive code** - Code should be self-documenting
3. **Keep it simple** - Avoid over-engineering
4. **Test what matters** - Focus on critical paths and edge cases
5. **Document decisions** - Use ADRs for significant choices

### 1.2 Related Documents

- [Architecture Specification](../02-architecture/arch-agency-platform.md)
- [ADR Index](../03-decisions/README.md)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

---

## 2. PHP Standards

### 2.1 General Requirements

```php
<?php

declare(strict_types=1);

namespace App\Domain\Projects;

use App\Domain\Projects\Contracts\ProjectRepositoryInterface;
use App\Domain\Projects\Events\ProjectCreated;
use Illuminate\Support\Collection;

/**
 * Manages project lifecycle operations.
 *
 * Handles creation, updates, and status transitions for projects.
 * Integrates with time tracking and invoicing systems.
 *
 * @package App\Domain\Projects
 */
final class ProjectService
{
    /**
     * Create a new ProjectService instance.
     */
    public function __construct(
        private ProjectRepositoryInterface $repository,
        private TimeTrackingService $timeTracking,
    ) {}

    /**
     * Create a new project for a client.
     *
     * @param  array<string, mixed>  $data  Project attributes
     * @return Project  The created project
     *
     * @throws ValidationException  When data is invalid
     * @throws ClientNotFoundException  When client doesn't exist
     */
    public function create(array $data): Project
    {
        $project = $this->repository->create($data);

        event(new ProjectCreated($project));

        return $project;
    }
}
```

**Requirements:**
- `declare(strict_types=1);` in every file
- Type hints on all parameters and return types
- PHPDoc blocks on all classes and public methods
- Import all classes (no inline FQCNs)
- Use `final` for classes not designed for inheritance

### 2.2 Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes | PascalCase | `ProjectController`, `InvoiceService` |
| Methods | camelCase | `getActiveProjects()`, `calculateTotal()` |
| Properties | camelCase | `$projectName`, `$createdAt` |
| Constants | UPPER_SNAKE | `MAX_RETRY_ATTEMPTS` |
| Config keys | snake_case | `stripe.api_key` |
| Database columns | snake_case | `created_at`, `client_id` |
| Routes (URLs) | kebab-case | `/client-portal`, `/time-entries` |
| Route names | camelCase | `projects.show`, `invoices.download` |

### 2.3 Control Flow

**Happy path last:**
```php
public function process(Request $request): Response
{
    // Handle error conditions first
    if (! $request->hasValidSignature()) {
        return response()->json(['error' => 'Invalid signature'], 401);
    }

    if (! $this->canProcess($request)) {
        return response()->json(['error' => 'Cannot process'], 422);
    }

    // Happy path is the last thing
    return $this->doProcess($request);
}
```

**Avoid else - use early returns:**
```php
// Good
public function getDiscount(User $user): int
{
    if ($user->isVip()) {
        return 20;
    }

    if ($user->hasLoyaltyCard()) {
        return 10;
    }

    return 0;
}

// Avoid
public function getDiscount(User $user): int
{
    if ($user->isVip()) {
        return 20;
    } else {
        if ($user->hasLoyaltyCard()) {
            return 10;
        } else {
            return 0;
        }
    }
}
```

### 2.4 String Handling

**Use interpolation over concatenation:**
```php
// Good
$message = "Project {$project->name} created by {$user->name}";

// Avoid
$message = 'Project ' . $project->name . ' created by ' . $user->name;
```

### 2.5 Arrays and Collections

```php
// Typed array documentation
/** @param array<int, Project> $projects */
public function processProjects(array $projects): void

// Collection generics
/** @return Collection<int, Invoice> */
public function getPendingInvoices(): Collection

// Array shapes for fixed structures
/**
 * @return array{
 *     id: int,
 *     name: string,
 *     status: ProjectStatus,
 * }
 */
public function toArray(): array
```

---

## 3. Laravel Conventions

### 3.1 Directory Structure

```
app/
├── Console/
│   └── Commands/           # Artisan commands
├── Domain/                 # Business logic (DDD-lite)
│   ├── Projects/
│   │   ├── Actions/        # Single-purpose action classes
│   │   ├── Contracts/      # Interfaces
│   │   ├── Events/
│   │   ├── Listeners/
│   │   ├── Models/
│   │   ├── Policies/
│   │   └── Services/
│   ├── Billing/
│   ├── Clients/
│   └── ...
├── Http/
│   ├── Controllers/
│   │   ├── Api/            # API controllers
│   │   └── Portal/         # Client portal controllers
│   ├── Middleware/
│   ├── Requests/           # Form requests
│   └── Resources/          # API resources
├── Livewire/
│   ├── Admin/              # Filament customizations
│   └── Portal/             # Client portal components
├── Providers/
└── Support/                # Helpers, utilities
```

### 3.2 Controllers

**Naming:** Plural resource name + `Controller`

```php
// Good
class ProjectsController extends Controller
class InvoicesController extends Controller

// For single-action controllers
class DashboardController extends Controller
{
    public function __invoke(): View
    {
        return view('dashboard');
    }
}
```

**Stick to CRUD methods:**
- `index` - List resources
- `create` - Show creation form
- `store` - Save new resource
- `show` - Display single resource
- `edit` - Show edit form
- `update` - Update resource
- `destroy` - Delete resource

**Extract new controllers for non-CRUD actions:**
```php
// Instead of ProjectsController@archive
class ArchivedProjectsController extends Controller
{
    public function store(Project $project): RedirectResponse
    {
        // Archive the project
    }

    public function destroy(Project $project): RedirectResponse
    {
        // Unarchive the project
    }
}
```

### 3.3 Routes

```php
// routes/web.php
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('dashboard', DashboardController::class)->name('dashboard');

    Route::resource('projects', ProjectsController::class);
    Route::resource('projects.tasks', TasksController::class)->shallow();

    Route::post('projects/{project}/archive', [ArchivedProjectsController::class, 'store'])
        ->name('projects.archive');
});

// routes/portal.php
Route::middleware(['auth:client'])->prefix('portal')->name('portal.')->group(function () {
    Route::get('/', [Portal\DashboardController::class, 'index'])->name('dashboard');
    Route::resource('invoices', Portal\InvoicesController::class)->only(['index', 'show']);
});
```

**Route conventions:**
- Use tuple notation: `[Controller::class, 'method']`
- URLs in kebab-case: `/time-entries`
- Route names in camelCase: `timeEntries.index`
- Parameters in camelCase: `{projectId}`

### 3.4 Models

```php
<?php

declare(strict_types=1);

namespace App\Domain\Projects\Models;

use App\Domain\Billing\Models\Invoice;
use App\Domain\Clients\Models\Client;
use App\Domain\Projects\Enums\ProjectStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

/**
 * Represents a client project.
 *
 * @property int $id
 * @property string $name
 * @property ProjectStatus $status
 * @property int $client_id
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property Carbon|null $deleted_at
 */
final class Project extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'name',
        'description',
        'status',
        'client_id',
        'budget_cents',
        'due_date',
    ];

    protected $casts = [
        'status' => ProjectStatus::class,
        'budget_cents' => 'integer',
        'due_date' => 'date',
    ];

    // Relationships

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }

    public function tasks(): HasMany
    {
        return $this->hasMany(Task::class);
    }

    public function invoices(): HasMany
    {
        return $this->hasMany(Invoice::class);
    }

    // Scopes

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', ProjectStatus::Active);
    }

    public function scopeForClient(Builder $query, Client $client): Builder
    {
        return $query->where('client_id', $client->id);
    }

    // Accessors

    public function getBudgetAttribute(): Money
    {
        return Money::fromCents($this->budget_cents);
    }

    // Business Logic

    public function isOverdue(): bool
    {
        return $this->due_date?->isPast() ?? false;
    }

    public function calculateProgress(): float
    {
        $total = $this->tasks()->count();

        if ($total === 0) {
            return 0.0;
        }

        $completed = $this->tasks()->where('status', TaskStatus::Completed)->count();

        return round(($completed / $total) * 100, 2);
    }
}
```

### 3.5 Form Requests

```php
<?php

declare(strict_types=1);

namespace App\Http\Requests;

use App\Domain\Projects\Enums\ProjectStatus;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/**
 * Validates project creation requests.
 */
final class StoreProjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Project::class);
    }

    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:10000'],
            'client_id' => ['required', 'exists:clients,id'],
            'status' => ['required', Rule::enum(ProjectStatus::class)],
            'budget' => ['nullable', 'numeric', 'min:0'],
            'due_date' => ['nullable', 'date', 'after:today'],
        ];
    }
}
```

### 3.6 Services and Actions

**Services** for complex operations spanning multiple models:

```php
<?php

declare(strict_types=1);

namespace App\Domain\Billing\Services;

/**
 * Handles invoice generation and management.
 */
final class InvoiceService
{
    public function __construct(
        private InvoiceRepository $invoices,
        private TimeEntryRepository $timeEntries,
        private StripeService $stripe,
    ) {}

    /**
     * Generate invoice from unbilled time entries.
     */
    public function generateFromTimeEntries(Project $project): Invoice
    {
        $entries = $this->timeEntries->unbilledForProject($project);

        $invoice = $this->invoices->create([
            'project_id' => $project->id,
            'client_id' => $project->client_id,
            'amount_cents' => $entries->sum('billable_amount_cents'),
        ]);

        $entries->each->markAsBilled($invoice);

        return $invoice;
    }
}
```

**Actions** for single-purpose operations:

```php
<?php

declare(strict_types=1);

namespace App\Domain\Projects\Actions;

/**
 * Archives a project and notifies stakeholders.
 */
final class ArchiveProjectAction
{
    public function __construct(
        private NotificationService $notifications,
    ) {}

    public function execute(Project $project): void
    {
        $project->update(['status' => ProjectStatus::Archived]);

        $this->notifications->notifyProjectArchived($project);
    }
}
```

### 3.7 Enums

```php
<?php

declare(strict_types=1);

namespace App\Domain\Projects\Enums;

enum ProjectStatus: string
{
    case Draft = 'draft';
    case Active = 'active';
    case OnHold = 'on_hold';
    case Completed = 'completed';
    case Archived = 'archived';

    public function label(): string
    {
        return match ($this) {
            self::Draft => 'Draft',
            self::Active => 'Active',
            self::OnHold => 'On Hold',
            self::Completed => 'Completed',
            self::Archived => 'Archived',
        };
    }

    public function color(): string
    {
        return match ($this) {
            self::Draft => 'gray',
            self::Active => 'green',
            self::OnHold => 'yellow',
            self::Completed => 'blue',
            self::Archived => 'gray',
        };
    }
}
```

---

## 4. Database Standards

### 4.1 Migrations

```php
<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained()->cascadeOnDelete();
            $table->foreignId('created_by')->constrained('users');
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('status')->default('draft');
            $table->unsignedBigInteger('budget_cents')->nullable();
            $table->date('due_date')->nullable();
            $table->timestamps();
            $table->softDeletes();

            // Indexes for common queries
            $table->index(['client_id', 'status']);
            $table->index(['status', 'due_date']);
            $table->index('created_at');
        });
    }
};
```

**Conventions:**
- Only define `up()` method (Laravel handles rollback)
- Use `foreignId()` with explicit constraints
- Add indexes for frequently queried columns
- Use `unsignedBigInteger` for monetary values (store in cents)
- Always include `timestamps()` and consider `softDeletes()`

### 4.2 Seeders

```php
<?php

declare(strict_types=1);

namespace Database\Seeders;

use App\Domain\Projects\Models\Project;
use Illuminate\Database\Seeder;

final class ProjectSeeder extends Seeder
{
    public function run(): void
    {
        // Only seed in non-production
        if (app()->isProduction()) {
            return;
        }

        Project::factory()
            ->count(20)
            ->hasTimeEntries(10)
            ->create();
    }
}
```

---

## 5. Frontend Standards

### 5.1 Blade Templates

```blade
{{-- resources/views/projects/show.blade.php --}}
<x-app-layout>
    <x-slot name="header">
        <h2 class="text-xl font-semibold">
            {{ $project->name }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="mx-auto max-w-7xl sm:px-6 lg:px-8">
            {{-- Project details --}}
            <x-card>
                <x-slot name="header">
                    <div class="flex items-center justify-between">
                        <h3>Project Details</h3>
                        <x-badge :color="$project->status->color()">
                            {{ $project->status->label() }}
                        </x-badge>
                    </div>
                </x-slot>

                <dl class="grid grid-cols-2 gap-4">
                    <div>
                        <dt class="text-sm text-gray-500">Client</dt>
                        <dd>{{ $project->client->name }}</dd>
                    </div>
                    <div>
                        <dt class="text-sm text-gray-500">Due Date</dt>
                        <dd>{{ $project->due_date?->format('M j, Y') ?? 'Not set' }}</dd>
                    </div>
                </dl>
            </x-card>

            {{-- Tasks --}}
            @if($project->tasks->isNotEmpty())
                <x-card class="mt-6">
                    <x-slot name="header">Tasks</x-slot>

                    <ul class="divide-y">
                        @foreach($project->tasks as $task)
                            <li class="py-3">
                                <x-task-row :task="$task" />
                            </li>
                        @endforeach
                    </ul>
                </x-card>
            @endif
        </div>
    </div>
</x-app-layout>
```

**Conventions:**
- Indent with 4 spaces
- No spaces after control structures: `@if($condition)`
- Use Blade components for reusable UI
- Keep logic minimal - use view composers for complex data

### 5.2 Livewire Components

```php
<?php

declare(strict_types=1);

namespace App\Livewire\Portal;

use App\Domain\Projects\Models\Project;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Computed;
use Livewire\Attributes\On;
use Livewire\Component;

/**
 * Displays project status with real-time updates.
 */
final class ProjectStatus extends Component
{
    public Project $project;

    #[On('project-updated.{project.id}')]
    public function refresh(): void
    {
        // Component will re-render with fresh data
    }

    #[Computed]
    public function progress(): float
    {
        return $this->project->calculateProgress();
    }

    #[Computed]
    public function tasks(): Collection
    {
        return $this->project->tasks()
            ->with('assignee:id,name')
            ->ordered()
            ->get();
    }

    public function render(): View
    {
        return view('livewire.portal.project-status');
    }
}
```

### 5.3 JavaScript/Alpine.js

```js
// resources/js/components/task-timer.js
export default () => ({
    running: false,
    seconds: 0,
    interval: null,

    start() {
        this.running = true;
        this.interval = setInterval(() => this.seconds++, 1000);
    },

    stop() {
        this.running = false;
        clearInterval(this.interval);
    },

    get formatted() {
        const hours = Math.floor(this.seconds / 3600);
        const minutes = Math.floor((this.seconds % 3600) / 60);
        const secs = this.seconds % 60;

        return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    },
});
```

---

## 6. Testing Standards

### 6.1 Test Organization

```
tests/
├── Feature/                    # Integration tests
│   ├── Api/
│   │   └── ProjectsApiTest.php
│   ├── Portal/
│   │   └── InvoicePaymentTest.php
│   └── Admin/
│       └── ProjectManagementTest.php
├── Unit/                       # Unit tests
│   ├── Domain/
│   │   ├── Projects/
│   │   │   └── ProjectServiceTest.php
│   │   └── Billing/
│   │       └── InvoiceCalculatorTest.php
│   └── Support/
└── Pest.php                    # Pest configuration
```

### 6.2 Test Examples

```php
<?php

declare(strict_types=1);

use App\Domain\Projects\Models\Project;
use App\Domain\Projects\Services\ProjectService;

describe('ProjectService', function () {
    it('creates a project for a client', function () {
        $client = Client::factory()->create();
        $user = User::factory()->create();

        $service = app(ProjectService::class);

        $project = $service->create([
            'name' => 'Website Redesign',
            'client_id' => $client->id,
            'created_by' => $user->id,
        ]);

        expect($project)
            ->toBeInstanceOf(Project::class)
            ->name->toBe('Website Redesign')
            ->client_id->toBe($client->id);
    });

    it('dispatches ProjectCreated event', function () {
        Event::fake([ProjectCreated::class]);

        $project = app(ProjectService::class)->create([
            'name' => 'New Project',
            'client_id' => Client::factory()->create()->id,
        ]);

        Event::assertDispatched(ProjectCreated::class, fn ($e) => $e->project->is($project));
    });
});

describe('Projects API', function () {
    it('requires authentication', function () {
        $this->getJson('/api/projects')
            ->assertUnauthorized();
    });

    it('lists projects for authenticated user', function () {
        $user = User::factory()->create();
        $projects = Project::factory()->count(3)->create(['created_by' => $user->id]);

        $this->actingAs($user)
            ->getJson('/api/projects')
            ->assertOk()
            ->assertJsonCount(3, 'data');
    });

    it('responds in under 500ms', function () {
        $user = User::factory()->create();
        Project::factory()->count(100)->create();

        $start = microtime(true);
        $this->actingAs($user)->getJson('/api/projects');
        $duration = microtime(true) - $start;

        expect($duration)->toBeLessThan(0.5);
    });
});
```

### 6.3 Test Coverage Requirements

| Type | Minimum Coverage | Focus Areas |
|------|------------------|-------------|
| Unit | 80% | Services, Actions, Value Objects |
| Feature | 70% | Controllers, API endpoints |
| Integration | Critical paths | Payment flows, Auth |

---

## 7. Code Quality Tools

### 7.1 Static Analysis (PHPStan)

```yaml
# phpstan.neon
parameters:
    level: 8
    paths:
        - app
    excludePaths:
        - app/Console/Kernel.php
    checkMissingIterableValueType: true
    checkGenericClassInNonGenericObjectType: true
```

### 7.2 Code Style (Laravel Pint)

```json
{
    "preset": "laravel",
    "rules": {
        "declare_strict_types": true,
        "final_class": true,
        "ordered_imports": {
            "sort_algorithm": "alpha"
        }
    }
}
```

### 7.3 Git Hooks (Pre-commit)

```bash
#!/bin/sh
# .husky/pre-commit

# Run Pint
./vendor/bin/pint --test

# Run PHPStan
./vendor/bin/phpstan analyse

# Run tests
./vendor/bin/pest --parallel
```

---

## 8. Artisan Commands

### 8.1 Command Structure

```php
<?php

declare(strict_types=1);

namespace App\Console\Commands;

use App\Domain\Billing\Services\InvoiceService;
use Illuminate\Console\Command;

/**
 * Generates invoices for projects with unbilled time entries.
 */
final class GenerateInvoicesCommand extends Command
{
    protected $signature = 'invoices:generate
                            {--project= : Generate for specific project}
                            {--dry-run : Show what would be generated}';

    protected $description = 'Generate invoices from unbilled time entries';

    public function handle(InvoiceService $invoices): int
    {
        $projects = $this->getProjects();

        if ($projects->isEmpty()) {
            $this->info('No projects with unbilled time entries.');

            return self::SUCCESS;
        }

        $this->info("Found {$projects->count()} projects with unbilled entries.");

        $bar = $this->output->createProgressBar($projects->count());

        $generated = 0;

        foreach ($projects as $project) {
            $this->line("Processing: {$project->name}");

            if (! $this->option('dry-run')) {
                $invoices->generateFromTimeEntries($project);
                $generated++;
            }

            $bar->advance();
        }

        $bar->finish();
        $this->newLine();

        $this->info("Generated {$generated} invoices.");

        return self::SUCCESS;
    }
}
```

**Conventions:**
- Command names in kebab-case: `invoices:generate`
- Always provide feedback to user
- Show progress for loops
- Support `--dry-run` for destructive operations
- Return `self::SUCCESS` or `self::FAILURE`

---

## 9. Error Handling

### 9.1 Custom Exceptions

```php
<?php

declare(strict_types=1);

namespace App\Domain\Projects\Exceptions;

use Exception;

/**
 * Thrown when a project is not found.
 */
final class ProjectNotFoundException extends Exception
{
    public static function withId(int $id): self
    {
        return new self("Project with ID {$id} not found.");
    }

    public static function withSlug(string $slug): self
    {
        return new self("Project with slug '{$slug}' not found.");
    }
}
```

### 9.2 Exception Handler

```php
// app/Exceptions/Handler.php
public function register(): void
{
    $this->renderable(function (ProjectNotFoundException $e, Request $request) {
        if ($request->expectsJson()) {
            return response()->json(['error' => $e->getMessage()], 404);
        }

        return response()->view('errors.project-not-found', [], 404);
    });
}
```

---

## 10. Security Practices

### 10.1 Input Validation

- Always use Form Requests for validation
- Never trust user input
- Sanitize output with `{{ }}` (auto-escaped)
- Use `{!! !!}` only for trusted HTML

### 10.2 Authorization

```php
// Always check authorization
public function show(Project $project): View
{
    $this->authorize('view', $project);

    return view('projects.show', compact('project'));
}

// Policy methods
public function view(User $user, Project $project): bool
{
    return $user->id === $project->created_by
        || $user->hasRole('admin')
        || $project->team->contains($user);
}
```

### 10.3 Sensitive Data

- Never log passwords, tokens, or API keys
- Use `.env` for secrets (never commit)
- Encrypt sensitive database fields
- Use Sanctum/Passport for API authentication

---

## 11. Performance Guidelines

### 11.1 Database Queries

```php
// Eager load relationships
$projects = Project::with(['client', 'tasks', 'tasks.assignee'])->get();

// Use select for specific columns
$clients = Client::select(['id', 'name', 'email'])->get();

// Avoid N+1 with withCount
$projects = Project::withCount('tasks')->get();

// Use chunk for large datasets
Project::chunk(100, function ($projects) {
    foreach ($projects as $project) {
        // Process
    }
});
```

### 11.2 Caching

```php
// Cache expensive queries
$stats = Cache::remember('dashboard.stats', 300, fn () => [
    'total_projects' => Project::count(),
    'active_clients' => Client::active()->count(),
]);

// Cache with tags for easy invalidation
$project = Cache::tags(['projects', "project.{$id}"])
    ->remember("project.{$id}", 600, fn () => Project::find($id));

// Invalidate on update
Cache::tags(["project.{$project->id}"])->flush();
```

---

## 12. Documentation Requirements

### 12.1 Code Documentation

Every class must have:
```php
/**
 * Brief one-line description.
 *
 * Longer description if needed explaining the purpose
 * and responsibilities of this class.
 *
 * @package App\Domain\[DomainName]
 */
```

Every public method must have:
```php
/**
 * Brief description of what method does.
 *
 * @param  Type  $param  Description of parameter
 * @return Type  Description of return value
 *
 * @throws ExceptionClass  When this condition occurs
 */
```

### 12.2 API Documentation

- Document all API endpoints in OpenAPI/Swagger format
- Include request/response examples
- Document error responses
- Keep documentation in sync with code

---

## Links

- [Laravel Documentation](https://laravel.com/docs)
- [Spatie Laravel Guidelines](https://spatie.be/guidelines/laravel-php)
- [PHP-FIG Standards](https://www.php-fig.org/psr/)
- [Pest PHP Testing](https://pestphp.com/)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial development standards |
