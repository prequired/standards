# Testing Strategy

**Version:** 1.0.0
**Last Updated:** 2025-11-29

---

## 1. Overview

This document defines the testing strategy for the Agency Platform, ensuring code quality, reliability, and confidence in deployments.

### 1.1 Testing Principles

1. **Test behavior, not implementation** - Focus on what code does, not how
2. **Fast feedback** - Tests should run quickly in CI
3. **Reliable tests** - No flaky tests allowed
4. **Meaningful coverage** - Cover critical paths, not vanity metrics
5. **Test pyramid** - More unit tests, fewer E2E tests

### 1.2 Related Documents

- [Development Standards](../04-development/dev-standards.md)
- [ADR-0012: Security](../03-decisions/adr-0012-security-data-protection.md)
- [ADR-0020: Performance](../03-decisions/adr-0020-performance-optimization.md)

---

## 2. Test Pyramid

```
        /\
       /  \        E2E Tests (5%)
      /----\       Browser-based, critical user journeys
     /      \
    /--------\     Integration Tests (25%)
   /          \    API endpoints, database operations
  /------------\
 /              \  Unit Tests (70%)
/----------------\ Services, models, value objects
```

### 2.1 Test Types

| Type | Scope | Speed | Database | Browser |
|------|-------|-------|----------|---------|
| Unit | Single class/function | Fast | No | No |
| Integration | Multiple components | Medium | Yes | No |
| Feature | Full request cycle | Medium | Yes | No |
| E2E | User workflows | Slow | Yes | Yes |

---

## 3. Unit Tests

### 3.1 What to Unit Test

- Services and business logic
- Value objects and DTOs
- Helpers and utilities
- Model accessors and mutators
- Validation rules
- Event handlers

### 3.2 Unit Test Examples

```php
<?php

declare(strict_types=1);

use App\Domain\Billing\Services\InvoiceCalculator;
use App\Domain\Billing\ValueObjects\Money;

describe('InvoiceCalculator', function () {
    it('calculates subtotal from line items', function () {
        $calculator = new InvoiceCalculator();

        $lineItems = [
            ['quantity' => 2, 'unit_price_cents' => 5000],
            ['quantity' => 5, 'unit_price_cents' => 10000],
        ];

        $subtotal = $calculator->calculateSubtotal($lineItems);

        expect($subtotal)->toBe(60000); // 2*50 + 5*100 = $600
    });

    it('applies percentage discount', function () {
        $calculator = new InvoiceCalculator();

        $result = $calculator->applyDiscount(10000, 10); // $100, 10%

        expect($result)->toBe(9000); // $90
    });

    it('calculates tax amount', function () {
        $calculator = new InvoiceCalculator();

        $tax = $calculator->calculateTax(10000, 8.5); // $100, 8.5%

        expect($tax)->toBe(850); // $8.50
    });
});

describe('Money value object', function () {
    it('creates from cents', function () {
        $money = Money::fromCents(5000);

        expect($money->cents())->toBe(5000);
        expect($money->dollars())->toBe(50.00);
        expect($money->formatted())->toBe('$50.00');
    });

    it('adds two money values', function () {
        $a = Money::fromCents(1000);
        $b = Money::fromCents(2500);

        $result = $a->add($b);

        expect($result->cents())->toBe(3500);
    });

    it('prevents negative values', function () {
        expect(fn() => Money::fromCents(-100))
            ->toThrow(InvalidArgumentException::class);
    });
});
```

### 3.3 Unit Test Guidelines

- One assertion per test (ideally)
- Use descriptive test names
- Arrange-Act-Assert pattern
- Mock external dependencies
- Test edge cases and error conditions

---

## 4. Integration Tests

### 4.1 What to Integration Test

- Database operations (CRUD)
- External service integrations (mocked)
- Queue job processing
- Event/listener chains
- Cache operations

### 4.2 Integration Test Examples

```php
<?php

declare(strict_types=1);

use App\Domain\Projects\Models\Project;
use App\Domain\Projects\Services\ProjectService;
use App\Domain\Projects\Events\ProjectCreated;

describe('ProjectService integration', function () {
    beforeEach(function () {
        $this->client = Client::factory()->create();
        $this->user = User::factory()->create();
        $this->service = app(ProjectService::class);
    });

    it('creates project in database', function () {
        $project = $this->service->create([
            'name' => 'Test Project',
            'client_id' => $this->client->id,
            'created_by' => $this->user->id,
        ]);

        expect($project)->toBeInstanceOf(Project::class);

        $this->assertDatabaseHas('projects', [
            'id' => $project->id,
            'name' => 'Test Project',
            'client_id' => $this->client->id,
        ]);
    });

    it('dispatches ProjectCreated event', function () {
        Event::fake([ProjectCreated::class]);

        $project = $this->service->create([
            'name' => 'Test Project',
            'client_id' => $this->client->id,
            'created_by' => $this->user->id,
        ]);

        Event::assertDispatched(ProjectCreated::class, function ($event) use ($project) {
            return $event->project->id === $project->id;
        });
    });

    it('assigns default status', function () {
        $project = $this->service->create([
            'name' => 'Test Project',
            'client_id' => $this->client->id,
            'created_by' => $this->user->id,
        ]);

        expect($project->status)->toBe(ProjectStatus::Draft);
    });
});
```

---

## 5. Feature Tests

### 5.1 What to Feature Test

- API endpoints (request/response)
- Form submissions
- Authentication flows
- Authorization (policies)
- Middleware behavior

### 5.2 Feature Test Examples

```php
<?php

declare(strict_types=1);

use App\Domain\Projects\Models\Project;

describe('Projects API', function () {
    describe('GET /api/v1/projects', function () {
        it('requires authentication', function () {
            $this->getJson('/api/v1/projects')
                ->assertUnauthorized();
        });

        it('returns paginated projects', function () {
            $user = User::factory()->create();
            Project::factory()->count(25)->create();

            $this->actingAs($user)
                ->getJson('/api/v1/projects')
                ->assertOk()
                ->assertJsonStructure([
                    'data' => [['id', 'type', 'attributes']],
                    'meta' => ['current_page', 'total', 'per_page'],
                    'links' => ['first', 'last', 'prev', 'next'],
                ])
                ->assertJsonCount(15, 'data');
        });

        it('filters by status', function () {
            $user = User::factory()->create();
            Project::factory()->count(5)->active()->create();
            Project::factory()->count(3)->completed()->create();

            $this->actingAs($user)
                ->getJson('/api/v1/projects?status=active')
                ->assertOk()
                ->assertJsonCount(5, 'data');
        });
    });

    describe('POST /api/v1/projects', function () {
        it('creates a project', function () {
            $user = User::factory()->create();
            $client = Client::factory()->create();

            $this->actingAs($user)
                ->postJson('/api/v1/projects', [
                    'name' => 'New Project',
                    'client_id' => $client->id,
                    'description' => 'Project description',
                ])
                ->assertCreated()
                ->assertJsonPath('data.attributes.name', 'New Project');

            $this->assertDatabaseHas('projects', ['name' => 'New Project']);
        });

        it('validates required fields', function () {
            $user = User::factory()->create();

            $this->actingAs($user)
                ->postJson('/api/v1/projects', [])
                ->assertUnprocessable()
                ->assertJsonValidationErrors(['name', 'client_id']);
        });
    });

    describe('Authorization', function () {
        it('prevents viewing other users projects', function () {
            $user = User::factory()->create();
            $otherProject = Project::factory()->create();

            $this->actingAs($user)
                ->getJson("/api/v1/projects/{$otherProject->id}")
                ->assertForbidden();
        });
    });
});
```

### 5.3 Testing Authentication

```php
<?php

describe('Authentication', function () {
    it('issues token on valid credentials', function () {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        $this->postJson('/api/v1/auth/token', [
            'email' => 'test@example.com',
            'password' => 'password',
            'device_name' => 'test',
        ])
            ->assertOk()
            ->assertJsonStructure(['token', 'expires_at']);
    });

    it('rejects invalid credentials', function () {
        $user = User::factory()->create([
            'email' => 'test@example.com',
            'password' => bcrypt('password'),
        ]);

        $this->postJson('/api/v1/auth/token', [
            'email' => 'test@example.com',
            'password' => 'wrong-password',
            'device_name' => 'test',
        ])
            ->assertUnauthorized();
    });
});
```

---

## 6. E2E Tests

### 6.1 What to E2E Test

- Critical user journeys
- Payment flows
- Authentication/registration
- Complex multi-step workflows

### 6.2 E2E Test Examples (Playwright)

```typescript
// tests/e2e/invoice-payment.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Invoice Payment Flow', () => {
    test('client can pay invoice', async ({ page }) => {
        // Login as client
        await page.goto('/portal/login');
        await page.fill('[name="email"]', 'client@example.com');
        await page.fill('[name="password"]', 'password');
        await page.click('button[type="submit"]');

        // Navigate to invoices
        await page.click('text=Invoices');
        await expect(page).toHaveURL('/portal/invoices');

        // Click on pending invoice
        await page.click('text=INV-2025-0001');
        await expect(page.locator('h1')).toContainText('INV-2025-0001');

        // Click pay button
        await page.click('text=Pay Now');

        // Should redirect to Stripe
        await expect(page).toHaveURL(/checkout\.stripe\.com/);
    });

    test('dashboard shows correct stats', async ({ page }) => {
        await page.goto('/portal/login');
        await page.fill('[name="email"]', 'client@example.com');
        await page.fill('[name="password"]', 'password');
        await page.click('button[type="submit"]');

        await expect(page).toHaveURL('/portal');

        // Verify dashboard widgets
        await expect(page.locator('[data-testid="active-projects"]')).toBeVisible();
        await expect(page.locator('[data-testid="pending-invoices"]')).toBeVisible();
        await expect(page.locator('[data-testid="recent-activity"]')).toBeVisible();
    });
});
```

### 6.3 E2E Test Guidelines

- Only test critical user journeys
- Use data-testid attributes for selectors
- Reset database before each test
- Mock external services (Stripe, email)
- Run in CI on dedicated stage

---

## 7. Performance Tests

### 7.1 Performance Requirements

| Metric | Target | Source |
|--------|--------|--------|
| Page load | < 3 seconds | REQ-PERF-001 |
| API response | < 500ms | REQ-PERF-002 |
| Query count/page | < 20 | REQ-PERF-005 |
| Cache hit rate | > 80% | REQ-PERF-006 |

### 7.2 Performance Test Examples

```php
<?php

describe('Performance', function () {
    it('homepage loads under 3 seconds', function () {
        $start = microtime(true);

        $response = $this->get('/');

        $duration = microtime(true) - $start;

        $response->assertOk();
        expect($duration)->toBeLessThan(3.0);
    });

    it('API responds under 500ms', function () {
        $user = User::factory()->create();
        Project::factory()->count(100)->create();

        $start = microtime(true);

        $this->actingAs($user)->getJson('/api/v1/projects');

        $duration = microtime(true) - $start;

        expect($duration)->toBeLessThan(0.5);
    });

    it('dashboard has under 20 queries', function () {
        $user = User::factory()->create();
        Project::factory()->count(10)->create(['created_by' => $user->id]);

        DB::enableQueryLog();

        $this->actingAs($user)->get('/dashboard');

        $queryCount = count(DB::getQueryLog());

        expect($queryCount)->toBeLessThan(20);
    });
});
```

---

## 8. Security Tests

### 8.1 Security Test Checklist

- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] Authorization enforcement
- [ ] Rate limiting
- [ ] Input validation
- [ ] File upload restrictions

### 8.2 Security Test Examples

```php
<?php

describe('Security', function () {
    it('prevents SQL injection in search', function () {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->getJson("/api/v1/projects?search='; DROP TABLE projects; --")
            ->assertOk();

        // Table should still exist
        $this->assertDatabaseCount('projects', 0);
    });

    it('escapes XSS in output', function () {
        $user = User::factory()->create();
        $project = Project::factory()->create([
            'name' => '<script>alert("xss")</script>',
        ]);

        $response = $this->actingAs($user)
            ->get("/projects/{$project->id}");

        $response->assertDontSee('<script>alert("xss")</script>', false);
        $response->assertSee('&lt;script&gt;');
    });

    it('enforces rate limiting', function () {
        for ($i = 0; $i < 65; $i++) {
            $response = $this->postJson('/api/v1/auth/token', [
                'email' => 'test@example.com',
                'password' => 'wrong',
                'device_name' => 'test',
            ]);
        }

        $response->assertStatus(429);
    });

    it('requires CSRF token for forms', function () {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->post('/projects', ['name' => 'Test'])
            ->assertStatus(419);
    });
});
```

---

## 9. Test Data

### 9.1 Factories

```php
<?php

namespace Database\Factories;

use App\Domain\Projects\Enums\ProjectStatus;
use App\Domain\Projects\Models\Project;

class ProjectFactory extends Factory
{
    protected $model = Project::class;

    public function definition(): array
    {
        return [
            'name' => fake()->sentence(3),
            'description' => fake()->paragraph(),
            'client_id' => Client::factory(),
            'created_by' => User::factory(),
            'status' => ProjectStatus::Draft,
            'budget_cents' => fake()->numberBetween(100000, 1000000),
            'due_date' => fake()->dateTimeBetween('+1 week', '+3 months'),
        ];
    }

    public function active(): static
    {
        return $this->state(fn () => ['status' => ProjectStatus::Active]);
    }

    public function completed(): static
    {
        return $this->state(fn () => ['status' => ProjectStatus::Completed]);
    }

    public function withTasks(int $count = 5): static
    {
        return $this->has(Task::factory()->count($count));
    }
}
```

### 9.2 Test Fixtures

```php
// tests/Fixtures/InvoiceFixtures.php
trait InvoiceFixtures
{
    protected function createPaidInvoice(Client $client): Invoice
    {
        return Invoice::factory()
            ->for($client)
            ->paid()
            ->create();
    }

    protected function createOverdueInvoice(Client $client): Invoice
    {
        return Invoice::factory()
            ->for($client)
            ->state(['due_date' => now()->subDays(30)])
            ->create();
    }
}
```

---

## 10. CI/CD Integration

### 10.1 GitHub Actions

```yaml
# .github/workflows/tests.yml
name: Tests

on: [push, pull_request]

jobs:
  tests:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: testing
          MYSQL_ROOT_PASSWORD: secret
        ports:
          - 3306:3306
      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: mbstring, pdo_mysql, redis
          coverage: xdebug

      - name: Install dependencies
        run: composer install --no-interaction

      - name: Run tests
        run: ./vendor/bin/pest --parallel --coverage --min=80
        env:
          DB_CONNECTION: mysql
          DB_HOST: 127.0.0.1
          DB_DATABASE: testing
          DB_USERNAME: root
          DB_PASSWORD: secret

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### 10.2 Local Testing

```bash
# Run all tests
./vendor/bin/pest

# Run specific test file
./vendor/bin/pest tests/Feature/ProjectsApiTest.php

# Run tests matching pattern
./vendor/bin/pest --filter="creates project"

# Run in parallel
./vendor/bin/pest --parallel

# With coverage
./vendor/bin/pest --coverage --min=80
```

---

## 11. Coverage Requirements

### 11.1 Minimum Coverage

| Category | Target |
|----------|--------|
| Overall | 80% |
| Critical paths | 95% |
| New code | 90% |

### 11.2 Critical Paths

Must have 95%+ coverage:

- Authentication and authorization
- Payment processing
- Invoice generation
- Time entry calculations
- Project status transitions

---

## Links

- [Pest PHP Documentation](https://pestphp.com/)
- [Laravel Testing](https://laravel.com/docs/testing)
- [Playwright Documentation](https://playwright.dev/)
- [Development Standards](../04-development/dev-standards.md)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial testing strategy |
