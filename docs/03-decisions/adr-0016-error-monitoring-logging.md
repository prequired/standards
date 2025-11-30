---
id: "ADR-0016"
title: "Error Monitoring & Logging Strategy"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-INTG-010, REQ-SEC-005, REQ-PERF-008"
decision_makers: "Platform Team"
consulted: "Development Team, DevOps"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0016: Error Monitoring & Logging Strategy

## Context and Problem Statement

[REQ-INTG-010](../01-requirements/req-intg-010.md) requires error monitoring integration to capture and track application errors. [REQ-SEC-005](../01-requirements/req-sec-005.md) requires audit logging. [REQ-PERF-008](../01-requirements/req-perf-008.md) requires application monitoring and alerting.

The platform needs:
- Real-time error capture and alerting
- Error grouping and deduplication
- Stack traces with context
- Log aggregation and search
- Performance monitoring (optional)

## Decision Drivers

- **Laravel Integration:** Native Laravel error handling
- **Real-time Alerts:** Immediate notification of errors
- **Context:** Sufficient information to debug issues
- **Cost:** Reasonable for small team/project
- **Simplicity:** Easy setup and maintenance
- **Alerting:** Slack/email notifications

## Considered Options

1. **Option A:** Sentry (self-hosted or cloud)
2. **Option B:** Flare (Laravel-native)
3. **Option C:** Bugsnag
4. **Option D:** Rollbar
5. **Option E:** Laravel Log + CloudWatch/Papertrail

## Decision Outcome

**Chosen Option:** Option B - Flare (Laravel-native)

**Justification:** Flare is built specifically for Laravel by Spatie:
- First-party Laravel integration (Ignition error page)
- Laravel-specific context (routes, middleware, queries)
- Excellent error grouping
- Simple pricing ($9/month for Team)
- Same team that makes many Laravel packages we use

For an agency platform running Laravel, Flare provides the most relevant error context with minimal configuration.

### Consequences

#### Positive

- Purpose-built for Laravel applications
- Ignition error page in development
- Automatic context (user, request, queries, logs)
- Solution suggestions for common errors
- Simple setup (one package install)
- Affordable pricing

#### Negative

- Laravel-only (can't monitor non-Laravel services)
- Newer than Sentry/Bugsnag (smaller ecosystem)
- Less APM features than Sentry
- No self-hosted option

#### Risks

- **Risk:** Flare service outage misses errors
  - **Mitigation:** Also log errors to file; configure backup notification channel
- **Risk:** Missing JavaScript frontend errors
  - **Mitigation:** Flare has JS SDK; or add separate frontend error tracking if needed
- **Risk:** Vendor dependency for error tracking
  - **Mitigation:** Can migrate to Sentry; error tracking is somewhat commodity

## Validation

- **Metric 1:** Errors appear in Flare within 30 seconds
- **Metric 2:** Alert received within 1 minute of new error
- **Metric 3:** 95% of errors have sufficient context to debug
- **Metric 4:** Zero missed production errors

## Pros and Cons of the Options

### Option A: Sentry

**Pros:**
- Industry standard
- Excellent features (releases, performance)
- Self-hosted option
- Multi-language support

**Cons:**
- More complex setup
- Higher pricing for team use
- Generic (not Laravel-specific)
- Can be overwhelming

### Option B: Flare

**Pros:**
- Laravel-native
- Ignition integration
- Simple setup
- Affordable
- Laravel-specific context

**Cons:**
- Laravel only
- Newer platform
- Less ecosystem
- No self-hosted

### Option C: Bugsnag

**Pros:**
- Mature platform
- Good stability tracking
- Multi-platform

**Cons:**
- Expensive ($59+/month)
- Less Laravel-specific
- Complex pricing

### Option D: Rollbar

**Pros:**
- Good error grouping
- Multi-language
- Reasonable pricing

**Cons:**
- Generic PHP support
- Less Laravel integration
- Dated UI

### Option E: Laravel Log + CloudWatch

**Pros:**
- No external service
- Full control
- Low cost

**Cons:**
- Must build alerting
- No error grouping
- Limited search capabilities
- More operational overhead

## Implementation Notes

### Flare Installation

```bash
composer require spatie/laravel-ignition
```

```php
// .env
FLARE_KEY=your-flare-key

// config/flare.php (published)
return [
    'key' => env('FLARE_KEY'),
    'reporting' => [
        'anonymize_ips' => true,
        'collect_git_information' => true,
        'report_queries' => true,
        'maximum_number_of_collected_queries' => 200,
        'report_query_bindings' => true,
        'report_view_data' => true,
        'grouping_type' => 'exception',
    ],
];
```

### Custom Context

```php
// Add custom context to errors
use Spatie\FlareClient\Flare;

class Handler extends ExceptionHandler
{
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            if (app()->bound('flare')) {
                app('flare')->context('user', [
                    'id' => auth()->id(),
                    'email' => auth()->user()?->email,
                    'role' => auth()->user()?->role,
                ]);

                app('flare')->context('environment', [
                    'tenant' => session('tenant_id'),
                    'feature_flags' => config('features'),
                ]);
            }
        });
    }
}
```

### JavaScript Error Tracking

```html
<!-- In your app layout -->
<script>
    window.flare = @json([
        'key' => config('flare.key'),
        'projectId' => config('flare.project_id'),
    ]);
</script>
<script src="https://flareapp.io/js/flare.js" crossorigin="anonymous"></script>
<script>
    if (typeof window.Flare !== 'undefined') {
        window.Flare.light(window.flare.key);
    }
</script>
```

### Alert Configuration

In Flare dashboard:
1. Navigate to Project → Notifications
2. Configure channels:
   - **Slack:** Connect workspace, select channel
   - **Email:** Add team email addresses
3. Set notification rules:
   - First occurrence of new error: Slack + Email
   - Recurring errors: Daily digest
   - High-frequency errors: Immediate alert

### Log Aggregation

```php
// config/logging.php
'channels' => [
    'stack' => [
        'driver' => 'stack',
        'channels' => ['daily', 'flare'],
        'ignore_exceptions' => false,
    ],

    'daily' => [
        'driver' => 'daily',
        'path' => storage_path('logs/laravel.log'),
        'level' => 'debug',
        'days' => 14,
    ],

    'flare' => [
        'driver' => 'flare',
    ],
],
```

### Audit Logging (Separate from Error Monitoring)

```php
// Audit logging uses Spatie Activity Log (ADR-0012)
// Error monitoring uses Flare
// These are complementary:

// Audit: WHO did WHAT (business events)
activity()
    ->causedBy($user)
    ->performedOn($project)
    ->log('Project status changed to completed');

// Error: WHAT went wrong (technical events)
// Automatically captured by Flare when exceptions thrown
```

### Health Check Endpoint

```php
// routes/web.php
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toIso8601String(),
        'checks' => [
            'database' => DB::connection()->getPdo() ? 'ok' : 'error',
            'cache' => Cache::store()->get('health') !== false ? 'ok' : 'error',
            'queue' => Queue::size() < 1000 ? 'ok' : 'warning',
        ],
    ]);
});
```

## Links

- [REQ-INTG-010](../01-requirements/req-intg-010.md) - Error Monitoring Integration
- [REQ-SEC-005](../01-requirements/req-sec-005.md) - Audit Logging
- [REQ-PERF-008](../01-requirements/req-perf-008.md) - Application Monitoring
- [ADR-0011](./adr-0011-infrastructure-hosting.md) - Infrastructure
- [ADR-0012](./adr-0012-security-data-protection.md) - Security (Audit Logging)
- [Flare Documentation](https://flareapp.io/docs)
- [Spatie Laravel-Ignition](https://spatie.be/docs/ignition)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
