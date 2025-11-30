---
id: "DEV-PROVIDERS"
title: "Service Providers & Container Guide"
version: "1.0.0"
status: "active"
owner: "Tech Lead"
last_updated: "2025-11-30"
---

# Service Providers & Container Guide

Standards for dependency injection, service container configuration, and service providers.

---

## Service Container Fundamentals

### Binding Basics

```php
// Simple binding (new instance each time)
$this->app->bind(PaymentService::class, function ($app) {
    return new PaymentService(
        $app->make(StripeClient::class),
        $app->make(LoggerInterface::class)
    );
});

// Singleton (same instance throughout request)
$this->app->singleton(AnalyticsService::class, function ($app) {
    return new AnalyticsService(
        config('services.analytics.key')
    );
});

// Instance binding (bind existing object)
$this->app->instance(Configuration::class, $config);

// Scoped (singleton within request, fresh in queues)
$this->app->scoped(RequestContext::class, function ($app) {
    return new RequestContext(request());
});
```

### Interface Binding

```php
// Bind interface to implementation
$this->app->bind(
    PaymentGatewayInterface::class,
    StripePaymentGateway::class
);

// Contextual binding (different implementations per consumer)
$this->app->when(InvoicePaymentService::class)
    ->needs(PaymentGatewayInterface::class)
    ->give(StripePaymentGateway::class);

$this->app->when(SubscriptionService::class)
    ->needs(PaymentGatewayInterface::class)
    ->give(StripeSubscriptionGateway::class);
```

---

## Service Provider Structure

### Standard Provider

```php
<?php

declare(strict_types=1);

namespace App\Providers;

use App\Contracts\InvoiceGenerator;
use App\Contracts\PdfRenderer;
use App\Services\Invoicing\InvoiceGeneratorService;
use App\Services\Pdf\BrowsershotPdfRenderer;
use Illuminate\Contracts\Support\DeferrableProvider;
use Illuminate\Support\ServiceProvider;

/**
 * Registers invoicing-related services.
 *
 * @package App\Providers
 */
final class InvoicingServiceProvider extends ServiceProvider implements DeferrableProvider
{
    /**
     * All bindings registered by this provider.
     *
     * @var array<class-string, class-string>
     */
    public array $bindings = [
        InvoiceGenerator::class => InvoiceGeneratorService::class,
    ];

    /**
     * All singletons registered by this provider.
     *
     * @var array<class-string, class-string>
     */
    public array $singletons = [
        PdfRenderer::class => BrowsershotPdfRenderer::class,
    ];

    /**
     * Register services.
     */
    public function register(): void
    {
        $this->app->singleton(InvoiceNumberGenerator::class, function ($app) {
            return new InvoiceNumberGenerator(
                prefix: config('invoicing.number_prefix', 'INV-'),
                yearFormat: config('invoicing.year_format', 'Y')
            );
        });
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        // Register invoice observers
        Invoice::observe(InvoiceObserver::class);

        // Publish config
        $this->publishes([
            __DIR__ . '/../../config/invoicing.php' => config_path('invoicing.php'),
        ], 'invoicing-config');
    }

    /**
     * Get the services provided (for deferred loading).
     *
     * @return array<int, class-string>
     */
    public function provides(): array
    {
        return [
            InvoiceGenerator::class,
            PdfRenderer::class,
            InvoiceNumberGenerator::class,
        ];
    }
}
```

### Domain Service Provider

```php
<?php

declare(strict_types=1);

namespace App\Providers;

use App\Domain\Billing\Services\BillingService;
use App\Domain\Projects\Services\ProjectService;
use App\Domain\Projects\Services\TaskService;
use App\Domain\TimeTracking\Services\TimeEntryService;
use Illuminate\Support\ServiceProvider;

/**
 * Registers domain services and repositories.
 */
final class DomainServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Project Domain
        $this->app->singleton(ProjectService::class);
        $this->app->singleton(TaskService::class);

        // Billing Domain
        $this->app->singleton(BillingService::class, function ($app) {
            return new BillingService(
                invoiceGenerator: $app->make(InvoiceGenerator::class),
                paymentGateway: $app->make(PaymentGatewayInterface::class),
                taxCalculator: $app->make(TaxCalculatorInterface::class)
            );
        });

        // Time Tracking Domain
        $this->app->singleton(TimeEntryService::class);
    }

    public function boot(): void
    {
        // Register domain event listeners
        Event::listen(
            ProjectCompleted::class,
            [GenerateFinalInvoice::class, NotifyClientOfCompletion::class]
        );

        Event::listen(
            InvoicePaid::class,
            [UpdateRevenueMetrics::class, SendPaymentReceipt::class]
        );
    }
}
```

---

## Provider Registration

### Laravel 11 Bootstrap

```php
// bootstrap/providers.php
<?php

return [
    // Framework Providers
    App\Providers\AppServiceProvider::class,
    App\Providers\AuthServiceProvider::class,
    App\Providers\EventServiceProvider::class,
    App\Providers\RouteServiceProvider::class,

    // Domain Providers
    App\Providers\DomainServiceProvider::class,
    App\Providers\InvoicingServiceProvider::class,

    // Integration Providers
    App\Providers\StripeServiceProvider::class,
    App\Providers\MailServiceProvider::class,

    // Third-Party (auto-discovered, but can be explicit)
    // Spatie\Permission\PermissionServiceProvider::class,
];
```

### Conditional Registration

```php
// In AppServiceProvider::register()
public function register(): void
{
    // Development-only providers
    if ($this->app->environment('local')) {
        $this->app->register(TelescopeServiceProvider::class);
        $this->app->register(DebugbarServiceProvider::class);
    }

    // Testing-only providers
    if ($this->app->runningUnitTests()) {
        $this->app->register(TestingServiceProvider::class);
    }
}
```

---

## Dependency Injection Patterns

### Constructor Injection (Preferred)

```php
<?php

declare(strict_types=1);

namespace App\Services;

use App\Contracts\PaymentGatewayInterface;
use App\Contracts\InvoiceRepositoryInterface;
use Psr\Log\LoggerInterface;

final class PaymentService
{
    public function __construct(
        private PaymentGatewayInterface $paymentGateway,
        private InvoiceRepositoryInterface $invoices,
        private LoggerInterface $logger
    ) {}

    public function processPayment(Invoice $invoice): PaymentResult
    {
        $this->logger->info('Processing payment', ['invoice_id' => $invoice->id]);

        return $this->paymentGateway->charge(
            amount: $invoice->total_cents,
            currency: $invoice->currency,
            customer: $invoice->client->stripe_customer_id
        );
    }
}
```

### Method Injection

```php
// In controller - Laravel auto-injects
public function store(
    StoreProjectRequest $request,
    ProjectService $projectService  // Injected
): JsonResponse {
    $project = $projectService->create($request->validated());

    return new JsonResponse(new ProjectResource($project), 201);
}
```

### Resolving from Container

```php
// Using app() helper (avoid in domain code)
$service = app(PaymentService::class);

// Using make()
$service = $this->app->make(PaymentService::class);

// With parameters
$service = $this->app->makeWith(ReportGenerator::class, [
    'startDate' => $startDate,
    'endDate' => $endDate,
]);

// Resolve or create with defaults
$config = $this->app->get(Configuration::class);
```

---

## Configuration Providers

### External Service Configuration

```php
<?php

declare(strict_types=1);

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Stripe\StripeClient;

final class StripeServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(StripeClient::class, function () {
            return new StripeClient([
                'api_key' => config('services.stripe.secret'),
                'stripe_version' => '2023-10-16',
            ]);
        });

        // Bind webhook handler
        $this->app->singleton(StripeWebhookHandler::class, function ($app) {
            return new StripeWebhookHandler(
                $app->make(StripeClient::class),
                config('services.stripe.webhook_secret')
            );
        });
    }

    public function boot(): void
    {
        // Verify configuration on boot
        if (app()->environment('production') && empty(config('services.stripe.secret'))) {
            throw new RuntimeException('Stripe secret key not configured');
        }
    }
}
```

### Config Publishing

```php
public function boot(): void
{
    // Publish config file
    $this->publishes([
        __DIR__ . '/../../config/invoicing.php' => config_path('invoicing.php'),
    ], 'config');

    // Merge with app config
    $this->mergeConfigFrom(
        __DIR__ . '/../../config/invoicing.php',
        'invoicing'
    );
}
```

---

## Event Service Provider

```php
<?php

declare(strict_types=1);

namespace App\Providers;

use App\Events\InvoicePaid;
use App\Events\InvoiceSent;
use App\Events\ProjectCompleted;
use App\Events\UserRegistered;
use App\Listeners\NotifyAdminOfPayment;
use App\Listeners\SendPaymentReceipt;
use App\Listeners\SendWelcomeEmail;
use App\Listeners\UpdateRevenueMetrics;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

final class EventServiceProvider extends ServiceProvider
{
    /**
     * Event to listener mappings.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $listen = [
        UserRegistered::class => [
            SendWelcomeEmail::class,
        ],

        InvoiceSent::class => [
            // Listeners execute in order
        ],

        InvoicePaid::class => [
            SendPaymentReceipt::class,
            UpdateRevenueMetrics::class,
            NotifyAdminOfPayment::class,
        ],

        ProjectCompleted::class => [
            // Auto-generate final invoice?
        ],
    ];

    /**
     * Model observers.
     *
     * @var array<class-string, array<int, class-string>>
     */
    protected $observers = [
        \App\Models\Project::class => [\App\Observers\ProjectObserver::class],
        \App\Models\Invoice::class => [\App\Observers\InvoiceObserver::class],
        \App\Models\TimeEntry::class => [\App\Observers\TimeEntryObserver::class],
    ];

    /**
     * Determine if events and listeners should be auto-discovered.
     */
    public function shouldDiscoverEvents(): bool
    {
        return false; // Explicit registration preferred
    }
}
```

---

## Authorization Service Provider

```php
<?php

declare(strict_types=1);

namespace App\Providers;

use App\Models\Client;
use App\Models\Invoice;
use App\Models\Project;
use App\Models\Task;
use App\Models\TimeEntry;
use App\Models\User;
use App\Policies\ClientPolicy;
use App\Policies\InvoicePolicy;
use App\Policies\ProjectPolicy;
use App\Policies\TaskPolicy;
use App\Policies\TimeEntryPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Gate;

final class AuthServiceProvider extends ServiceProvider
{
    /**
     * Policy mappings.
     *
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Project::class => ProjectPolicy::class,
        Task::class => TaskPolicy::class,
        Client::class => ClientPolicy::class,
        Invoice::class => InvoicePolicy::class,
        TimeEntry::class => TimeEntryPolicy::class,
    ];

    public function boot(): void
    {
        // Super admin bypass
        Gate::before(function (User $user, string $ability) {
            if ($user->isSuperAdmin()) {
                return true;
            }
        });

        // Custom gates
        Gate::define('access-admin', function (User $user) {
            return $user->hasRole(['admin', 'manager']);
        });

        Gate::define('impersonate', function (User $user, User $target) {
            return $user->isAdmin() && ! $target->isAdmin();
        });

        Gate::define('view-reports', function (User $user) {
            return $user->hasPermissionTo('view reports');
        });
    }
}
```

---

## Testing with Service Container

### Mocking Services

```php
use App\Contracts\PaymentGatewayInterface;

test('processes payment successfully', function () {
    // Create mock
    $gateway = Mockery::mock(PaymentGatewayInterface::class);
    $gateway->shouldReceive('charge')
        ->once()
        ->andReturn(new PaymentResult(success: true, transactionId: 'txn_123'));

    // Bind mock to container
    $this->app->instance(PaymentGatewayInterface::class, $gateway);

    // Test
    $invoice = Invoice::factory()->create();
    $service = app(PaymentService::class);

    $result = $service->processPayment($invoice);

    expect($result->success)->toBeTrue();
});
```

### Faking Services

```php
use App\Services\InvoiceNumberGenerator;

test('generates sequential invoice numbers', function () {
    // Create fake implementation
    $this->app->bind(InvoiceNumberGenerator::class, function () {
        return new class implements InvoiceNumberGenerator {
            private int $counter = 0;

            public function generate(): string
            {
                return 'TEST-' . ++$this->counter;
            }
        };
    });

    $generator = app(InvoiceNumberGenerator::class);

    expect($generator->generate())->toBe('TEST-1');
    expect($generator->generate())->toBe('TEST-2');
});
```

### Swapping Implementations

```php
test('uses test payment gateway in tests', function () {
    $this->swap(
        PaymentGatewayInterface::class,
        new TestPaymentGateway()
    );

    // All PaymentGatewayInterface injections now use TestPaymentGateway
});
```

---

## Best Practices

### DO

```php
// ✅ Use interfaces for external dependencies
$this->app->bind(PaymentGatewayInterface::class, StripeGateway::class);

// ✅ Use singletons for stateless services
$this->app->singleton(AnalyticsService::class);

// ✅ Defer loading when possible
class HeavyServiceProvider implements DeferrableProvider

// ✅ Use constructor injection
public function __construct(private PaymentService $payments) {}

// ✅ Type-hint interfaces, not implementations
public function __construct(private LoggerInterface $logger) {}
```

### DON'T

```php
// ❌ Don't use app() in domain code
$service = app(PaymentService::class); // Hard to test

// ❌ Don't create new instances directly
$service = new PaymentService(); // Bypasses DI

// ❌ Don't use facades in domain services
Log::info('...'); // Use injected LoggerInterface

// ❌ Don't bind too many things in AppServiceProvider
// Split into focused providers instead

// ❌ Don't forget to make providers deferrable
// Heavy services should only load when needed
```

---

## Provider Organization

```
app/Providers/
├── AppServiceProvider.php        # Core app bindings
├── AuthServiceProvider.php       # Gates, policies
├── EventServiceProvider.php      # Events, listeners, observers
├── RouteServiceProvider.php      # Route configuration

├── Domain/
│   ├── BillingServiceProvider.php
│   ├── ProjectServiceProvider.php
│   └── TimeTrackingServiceProvider.php

├── Integration/
│   ├── StripeServiceProvider.php
│   ├── PostmarkServiceProvider.php
│   └── StorageServiceProvider.php

└── Development/
    ├── TelescopeServiceProvider.php
    └── DebugServiceProvider.php
```

---

## Related Documentation

- [Development Standards](./dev-standards.md) - Code standards
- [Exception Handling](./exception-handling.md) - Error handling
- [Testing Strategy](../06-testing/testing-strategy.md) - Testing
- [Architecture](../02-architecture/arch-agency-platform.md) - System design

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-30 | 1.0.0 | Claude | Initial service providers guide |
