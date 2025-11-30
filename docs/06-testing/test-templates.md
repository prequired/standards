---
id: TEST-TEMPLATES
title: Test Templates and Examples
version: 1.0.0
status: active
owner: QA Team
last_updated: 2025-11-29
---

# Test Templates and Examples

Standard templates for writing tests across the Agency Platform. Follow these patterns for consistency and maintainability.

---

## Unit Test Template

### Basic Model Test

```php
<?php

declare(strict_types=1);

namespace Tests\Unit\Models;

use App\Models\Project;
use App\Models\Client;
use App\Enums\ProjectStatus;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Unit tests for the Project model.
 */
final class ProjectTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test project can be created with valid attributes.
     */
    public function test_can_create_project(): void
    {
        // Arrange
        $client = Client::factory()->create();

        // Act
        $project = Project::create([
            'name' => 'Website Redesign',
            'client_id' => $client->id,
            'status' => ProjectStatus::Active,
        ]);

        // Assert
        $this->assertDatabaseHas('projects', [
            'name' => 'Website Redesign',
            'client_id' => $client->id,
        ]);
    }

    /**
     * Test project belongs to a client.
     */
    public function test_project_belongs_to_client(): void
    {
        // Arrange
        $client = Client::factory()->create();
        $project = Project::factory()->for($client)->create();

        // Act
        $projectClient = $project->client;

        // Assert
        $this->assertInstanceOf(Client::class, $projectClient);
        $this->assertEquals($client->id, $projectClient->id);
    }

    /**
     * Test project has many tasks.
     */
    public function test_project_has_many_tasks(): void
    {
        // Arrange
        $project = Project::factory()
            ->hasTasks(3)
            ->create();

        // Assert
        $this->assertCount(3, $project->tasks);
    }

    /**
     * Test project calculates total billable hours.
     */
    public function test_calculates_total_billable_hours(): void
    {
        // Arrange
        $project = Project::factory()->create();
        TimeEntry::factory()->count(3)->create([
            'project_id' => $project->id,
            'duration_minutes' => 60,
            'billable' => true,
        ]);
        TimeEntry::factory()->create([
            'project_id' => $project->id,
            'duration_minutes' => 120,
            'billable' => false,
        ]);

        // Act
        $billableHours = $project->totalBillableHours();

        // Assert
        $this->assertEquals(3.0, $billableHours);
    }
}
```

### Service Class Test

```php
<?php

declare(strict_types=1);

namespace Tests\Unit\Services;

use App\Services\InvoiceService;
use App\Models\Invoice;
use App\Models\Project;
use App\DTOs\InvoiceData;
use App\Exceptions\InvoiceException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Unit tests for the InvoiceService.
 */
final class InvoiceServiceTest extends TestCase
{
    use RefreshDatabase;

    private InvoiceService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = app(InvoiceService::class);
    }

    /**
     * Test can create invoice from project time entries.
     */
    public function test_creates_invoice_from_project_time_entries(): void
    {
        // Arrange
        $project = Project::factory()
            ->hasTimeEntries(5, ['billable' => true, 'duration_minutes' => 60])
            ->create();

        $data = new InvoiceData(
            clientId: $project->client_id,
            projectId: $project->id,
            dueDate: now()->addDays(30),
        );

        // Act
        $invoice = $this->service->createFromProject($data);

        // Assert
        $this->assertInstanceOf(Invoice::class, $invoice);
        $this->assertEquals($project->client_id, $invoice->client_id);
        $this->assertCount(1, $invoice->lineItems);
    }

    /**
     * Test throws exception for project with no billable time.
     */
    public function test_throws_exception_for_no_billable_time(): void
    {
        // Arrange
        $project = Project::factory()->create();

        $data = new InvoiceData(
            clientId: $project->client_id,
            projectId: $project->id,
            dueDate: now()->addDays(30),
        );

        // Assert
        $this->expectException(InvoiceException::class);
        $this->expectExceptionMessage('No billable time entries');

        // Act
        $this->service->createFromProject($data);
    }
}
```

---

## Feature Test Template

### API Endpoint Test

```php
<?php

declare(strict_types=1);

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\Project;
use App\Models\Client;
use Laravel\Sanctum\Sanctum;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Feature tests for Projects API endpoints.
 */
final class ProjectApiTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();
        $this->user = User::factory()->create();
        Sanctum::actingAs($this->user);
    }

    /**
     * Test can list projects.
     */
    public function test_can_list_projects(): void
    {
        // Arrange
        Project::factory()->count(3)->create();

        // Act
        $response = $this->getJson('/api/v1/projects');

        // Assert
        $response
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'type',
                        'attributes' => [
                            'name',
                            'status',
                            'created_at',
                        ],
                    ],
                ],
                'meta' => ['current_page', 'per_page', 'total'],
            ]);
    }

    /**
     * Test can create project.
     */
    public function test_can_create_project(): void
    {
        // Arrange
        $client = Client::factory()->create();

        // Act
        $response = $this->postJson('/api/v1/projects', [
            'name' => 'New Website',
            'client_id' => $client->id,
            'description' => 'Build a new website',
            'status' => 'active',
        ]);

        // Assert
        $response
            ->assertCreated()
            ->assertJsonPath('data.attributes.name', 'New Website');

        $this->assertDatabaseHas('projects', [
            'name' => 'New Website',
            'client_id' => $client->id,
        ]);
    }

    /**
     * Test validation errors for invalid project data.
     */
    public function test_validation_errors_for_invalid_data(): void
    {
        // Act
        $response = $this->postJson('/api/v1/projects', [
            'name' => '', // Required
            'client_id' => 999, // Doesn't exist
        ]);

        // Assert
        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'client_id']);
    }

    /**
     * Test cannot access other user's projects.
     */
    public function test_cannot_access_other_users_projects(): void
    {
        // Arrange
        $otherUser = User::factory()->create();
        $project = Project::factory()->create(['user_id' => $otherUser->id]);

        // Act
        $response = $this->getJson("/api/v1/projects/{$project->id}");

        // Assert
        $response->assertForbidden();
    }

    /**
     * Test unauthenticated access is rejected.
     */
    public function test_unauthenticated_access_rejected(): void
    {
        // Arrange
        Sanctum::actingAs(null);

        // Act
        $response = $this->getJson('/api/v1/projects');

        // Assert
        $response->assertUnauthorized();
    }
}
```

### Livewire Component Test

```php
<?php

declare(strict_types=1);

namespace Tests\Feature\Livewire;

use App\Livewire\Projects\CreateProjectForm;
use App\Models\User;
use App\Models\Client;
use Livewire\Livewire;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Feature tests for CreateProjectForm Livewire component.
 */
final class CreateProjectFormTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test can render the form.
     */
    public function test_can_render(): void
    {
        $this->actingAs(User::factory()->create());

        Livewire::test(CreateProjectForm::class)
            ->assertStatus(200)
            ->assertSee('Create Project');
    }

    /**
     * Test can submit form with valid data.
     */
    public function test_can_submit_form(): void
    {
        $user = User::factory()->create();
        $client = Client::factory()->create();

        Livewire::actingAs($user)
            ->test(CreateProjectForm::class)
            ->set('name', 'New Project')
            ->set('client_id', $client->id)
            ->set('description', 'Project description')
            ->call('save')
            ->assertHasNoErrors()
            ->assertDispatched('project-created');

        $this->assertDatabaseHas('projects', [
            'name' => 'New Project',
            'client_id' => $client->id,
        ]);
    }

    /**
     * Test validation errors displayed.
     */
    public function test_shows_validation_errors(): void
    {
        $user = User::factory()->create();

        Livewire::actingAs($user)
            ->test(CreateProjectForm::class)
            ->set('name', '')
            ->call('save')
            ->assertHasErrors(['name' => 'required']);
    }

    /**
     * Test client dropdown is populated.
     */
    public function test_client_dropdown_populated(): void
    {
        $user = User::factory()->create();
        $clients = Client::factory()->count(3)->create();

        Livewire::actingAs($user)
            ->test(CreateProjectForm::class)
            ->assertSee($clients[0]->name)
            ->assertSee($clients[1]->name)
            ->assertSee($clients[2]->name);
    }
}
```

---

## Integration Test Template

### Service Integration Test

```php
<?php

declare(strict_types=1);

namespace Tests\Integration\Services;

use App\Services\PaymentService;
use App\Models\Invoice;
use Stripe\Stripe;
use Stripe\PaymentIntent;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Integration tests for PaymentService with Stripe.
 */
final class PaymentServiceIntegrationTest extends TestCase
{
    use RefreshDatabase;

    private PaymentService $service;

    protected function setUp(): void
    {
        parent::setUp();

        // Use Stripe test mode
        Stripe::setApiKey(config('services.stripe.secret'));
        $this->service = app(PaymentService::class);
    }

    /**
     * Test can create payment intent for invoice.
     *
     * @group external
     */
    public function test_creates_payment_intent_for_invoice(): void
    {
        // Skip if no Stripe key configured
        if (empty(config('services.stripe.secret'))) {
            $this->markTestSkipped('Stripe not configured');
        }

        // Arrange
        $invoice = Invoice::factory()->create([
            'total_cents' => 10000, // $100.00
        ]);

        // Act
        $paymentIntent = $this->service->createPaymentIntent($invoice);

        // Assert
        $this->assertInstanceOf(PaymentIntent::class, $paymentIntent);
        $this->assertEquals(10000, $paymentIntent->amount);
        $this->assertEquals('usd', $paymentIntent->currency);
    }
}
```

---

## Mocking Examples

### Mocking External Services

```php
<?php

declare(strict_types=1);

namespace Tests\Feature;

use App\Services\EmailService;
use Mockery\MockInterface;
use Tests\TestCase;

final class NotificationTest extends TestCase
{
    /**
     * Test invoice sent notification uses email service.
     */
    public function test_sends_invoice_email(): void
    {
        // Arrange
        $this->mock(EmailService::class, function (MockInterface $mock) {
            $mock->shouldReceive('send')
                ->once()
                ->withArgs(fn ($to, $template) =>
                    $to === 'client@example.com' &&
                    $template === 'invoice-sent'
                )
                ->andReturn(true);
        });

        $invoice = Invoice::factory()->create();

        // Act
        $invoice->send();

        // Assert handled by mock expectations
    }
}
```

### Faking Events/Jobs/Mail

```php
<?php

use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Queue;
use App\Events\InvoiceSent;
use App\Mail\InvoiceMail;
use App\Jobs\ProcessPayment;

public function test_sends_invoice_dispatches_event(): void
{
    Event::fake([InvoiceSent::class]);

    $invoice = Invoice::factory()->create();
    $invoice->send();

    Event::assertDispatched(InvoiceSent::class, fn ($e) =>
        $e->invoice->id === $invoice->id
    );
}

public function test_sends_invoice_email(): void
{
    Mail::fake();

    $invoice = Invoice::factory()->create();
    $invoice->send();

    Mail::assertSent(InvoiceMail::class, fn ($mail) =>
        $mail->hasTo($invoice->client->email)
    );
}

public function test_queues_payment_processing(): void
{
    Queue::fake();

    $payment = Payment::factory()->create();

    Queue::assertPushed(ProcessPayment::class, fn ($job) =>
        $job->payment->id === $payment->id
    );
}
```

---

## Data Providers

### Using Data Providers

```php
<?php

use PHPUnit\Framework\Attributes\DataProvider;

final class ProjectStatusTest extends TestCase
{
    #[DataProvider('validStatusTransitions')]
    public function test_valid_status_transitions(
        string $from,
        string $to,
        bool $expected
    ): void {
        $project = Project::factory()->create(['status' => $from]);

        $result = $project->canTransitionTo($to);

        $this->assertEquals($expected, $result);
    }

    public static function validStatusTransitions(): array
    {
        return [
            'draft to active' => ['draft', 'active', true],
            'active to on_hold' => ['active', 'on_hold', true],
            'active to completed' => ['active', 'completed', true],
            'completed to active' => ['completed', 'active', false],
            'archived to active' => ['archived', 'active', false],
        ];
    }
}
```

---

## Database Testing Patterns

### Using Factories

```php
// Basic factory usage
$project = Project::factory()->create();

// With specific attributes
$project = Project::factory()->create([
    'name' => 'Specific Name',
    'status' => ProjectStatus::Active,
]);

// With relationships
$project = Project::factory()
    ->for(Client::factory())
    ->hasTasks(5)
    ->hasTimeEntries(10)
    ->create();

// Multiple records
$projects = Project::factory()->count(10)->create();

// Sequences
$projects = Project::factory()
    ->count(3)
    ->sequence(
        ['status' => 'draft'],
        ['status' => 'active'],
        ['status' => 'completed'],
    )
    ->create();
```

### Database Assertions

```php
// Assert record exists
$this->assertDatabaseHas('projects', [
    'name' => 'Test Project',
    'client_id' => $client->id,
]);

// Assert record doesn't exist
$this->assertDatabaseMissing('projects', [
    'name' => 'Deleted Project',
]);

// Assert record count
$this->assertDatabaseCount('projects', 5);

// Assert soft deleted
$this->assertSoftDeleted('projects', ['id' => $project->id]);
```

---

## Test Organization

### Test File Location

```
tests/
├── Unit/
│   ├── Models/
│   │   └── ProjectTest.php
│   ├── Services/
│   │   └── InvoiceServiceTest.php
│   └── Actions/
│       └── CreateProjectActionTest.php
├── Feature/
│   ├── Api/
│   │   └── ProjectApiTest.php
│   ├── Livewire/
│   │   └── CreateProjectFormTest.php
│   └── Http/
│       └── ProjectControllerTest.php
├── Integration/
│   └── Services/
│       └── StripeIntegrationTest.php
└── TestCase.php
```

### Test Naming

| Convention | Example |
|------------|---------|
| test_ prefix | `test_can_create_project()` |
| snake_case | `test_user_cannot_access_other_projects()` |
| Descriptive | `test_throws_exception_when_budget_exceeded()` |

---

## Related Documents

- [Testing Strategy](./testing-strategy.md)
- [E2E Test Scenarios](./e2e-scenarios.md)
- [Development Standards](../04-development/dev-standards.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial test templates |
