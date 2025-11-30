---
id: TEST-PERF
title: Performance Testing Strategy
version: 1.0.0
status: active
owner: QA Team
last_updated: 2025-11-29
---

# Performance Testing Strategy

Guidelines and procedures for performance testing the Agency Platform.

---

## Performance Requirements

### Response Time Targets

| Endpoint Type | P50 Target | P95 Target | P99 Target |
|--------------|------------|------------|------------|
| API GET (list) | < 100ms | < 300ms | < 500ms |
| API GET (single) | < 50ms | < 150ms | < 250ms |
| API POST/PUT | < 150ms | < 400ms | < 600ms |
| Page Load (TTFB) | < 200ms | < 500ms | < 800ms |
| Dashboard | < 300ms | < 800ms | < 1200ms |
| Report Generation | < 2s | < 5s | < 10s |

### Throughput Targets

| Scenario | Target RPS | Concurrent Users |
|----------|-----------|------------------|
| Normal Load | 100 | 50 |
| Peak Load | 500 | 200 |
| Stress Test | 1000 | 500 |

### Resource Limits

| Resource | Threshold | Action |
|----------|-----------|--------|
| CPU | < 70% | Scale if exceeded |
| Memory | < 80% | Alert at 75% |
| Database Connections | < 80% of pool | Increase pool |
| Response Queue | < 1000 jobs | Add workers |

---

## Testing Tools

### Primary Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| k6 | Load testing | API endpoint testing |
| Lighthouse | Frontend performance | Page load analysis |
| Laravel Debugbar | Development profiling | Query analysis |
| Clockwork | Request profiling | Timeline inspection |
| MySQL EXPLAIN | Query optimization | Query plans |
| Redis Monitor | Cache analysis | Cache hit rates |

### Setup

```bash
# Install k6
brew install k6  # macOS
# or
sudo apt install k6  # Ubuntu

# Install Lighthouse
npm install -g lighthouse

# Laravel packages (dev dependencies)
composer require barryvdh/laravel-debugbar --dev
composer require itsgoingd/clockwork --dev
```

---

## Load Testing Scripts

### Basic API Test

```javascript
// tests/performance/api-basic.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 10 },   // Ramp up
    { duration: '3m', target: 50 },   // Steady state
    { duration: '1m', target: 100 },  // Peak
    { duration: '1m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<300'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';
const API_TOKEN = __ENV.API_TOKEN;

export default function () {
  const headers = {
    'Authorization': `Bearer ${API_TOKEN}`,
    'Accept': 'application/json',
  };

  // List projects
  const projectsRes = http.get(`${BASE_URL}/api/v1/projects`, { headers });
  check(projectsRes, {
    'projects status 200': (r) => r.status === 200,
    'projects response time < 300ms': (r) => r.timings.duration < 300,
  });

  sleep(1);

  // Get single project
  const projectRes = http.get(`${BASE_URL}/api/v1/projects/1`, { headers });
  check(projectRes, {
    'project status 200': (r) => r.status === 200,
    'project response time < 150ms': (r) => r.timings.duration < 150,
  });

  sleep(1);
}
```

### Authenticated User Flow

```javascript
// tests/performance/user-flow.js
import http from 'k6/http';
import { check, group, sleep } from 'k6';

export const options = {
  vus: 50,
  duration: '5m',
  thresholds: {
    'http_req_duration{name:login}': ['p(95)<500'],
    'http_req_duration{name:dashboard}': ['p(95)<800'],
    'http_req_duration{name:projects}': ['p(95)<300'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8000';

export default function () {
  let token;

  group('authentication', () => {
    const loginRes = http.post(
      `${BASE_URL}/api/v1/auth/token`,
      JSON.stringify({
        email: 'loadtest@agency.test',
        password: 'password',
        device_name: 'k6-test',
      }),
      {
        headers: { 'Content-Type': 'application/json' },
        tags: { name: 'login' },
      }
    );

    check(loginRes, { 'login successful': (r) => r.status === 200 });
    token = JSON.parse(loginRes.body).token;
  });

  const headers = {
    'Authorization': `Bearer ${token}`,
    'Accept': 'application/json',
  };

  group('dashboard', () => {
    const dashRes = http.get(`${BASE_URL}/api/v1/dashboard`, {
      headers,
      tags: { name: 'dashboard' },
    });
    check(dashRes, { 'dashboard loaded': (r) => r.status === 200 });
  });

  sleep(2);

  group('projects', () => {
    const projectsRes = http.get(`${BASE_URL}/api/v1/projects?per_page=20`, {
      headers,
      tags: { name: 'projects' },
    });
    check(projectsRes, { 'projects loaded': (r) => r.status === 200 });
  });

  sleep(1);
}
```

### Stress Test

```javascript
// tests/performance/stress-test.js
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '2m', target: 500 },
    { duration: '5m', target: 500 },
    { duration: '5m', target: 0 },
  ],
};

const BASE_URL = __ENV.BASE_URL;
const API_TOKEN = __ENV.API_TOKEN;

export default function () {
  const res = http.get(`${BASE_URL}/api/v1/health`, {
    headers: {
      'Authorization': `Bearer ${API_TOKEN}`,
    },
  });

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 1s': (r) => r.timings.duration < 1000,
  });
}
```

---

## Running Tests

### Command Line

```bash
# Basic load test
k6 run tests/performance/api-basic.js

# With environment variables
k6 run -e BASE_URL=https://staging.agency.com -e API_TOKEN=xxx tests/performance/api-basic.js

# With output to file
k6 run --out json=results.json tests/performance/api-basic.js

# With InfluxDB output (for Grafana)
k6 run --out influxdb=http://localhost:8086/k6 tests/performance/api-basic.js
```

### CI/CD Integration

```yaml
# .github/workflows/performance.yml
name: Performance Tests

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM
  workflow_dispatch:

jobs:
  load-test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install k6
        run: |
          sudo gpg -k
          sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
          echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
          sudo apt-get update
          sudo apt-get install k6

      - name: Run load tests
        run: |
          k6 run -e BASE_URL=${{ secrets.STAGING_URL }} \
                 -e API_TOKEN=${{ secrets.STAGING_API_TOKEN }} \
                 tests/performance/api-basic.js

      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: k6-results
          path: results.json
```

---

## Database Performance

### Query Analysis

```sql
-- Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 0.5;  -- 500ms threshold
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';

-- Analyze slow queries
mysqldumpslow -s t -t 10 /var/log/mysql/slow.log
```

### Index Analysis

```sql
-- Find missing indexes
SELECT
  OBJECT_SCHEMA,
  OBJECT_NAME,
  INDEX_NAME,
  COUNT_STAR AS queries,
  SUM_TIMER_WAIT/1000000000 AS total_latency_ms
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE INDEX_NAME IS NULL
  AND OBJECT_SCHEMA = 'agency_platform'
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 20;

-- Index usage statistics
SELECT
  table_name,
  index_name,
  seq_in_index,
  column_name,
  cardinality
FROM information_schema.statistics
WHERE table_schema = 'agency_platform'
ORDER BY table_name, index_name, seq_in_index;
```

### Common Optimizations

```php
// Use eager loading
$projects = Project::with(['client', 'tasks'])->get();  // 3 queries
// Instead of
$projects = Project::all();  // N+1 queries

// Use chunking for large datasets
Project::chunk(1000, function ($projects) {
    foreach ($projects as $project) {
        // Process
    }
});

// Use database aggregation
$total = TimeEntry::where('project_id', $id)->sum('duration_minutes');
// Instead of
$total = TimeEntry::where('project_id', $id)->get()->sum('duration_minutes');
```

---

## Frontend Performance

### Lighthouse Audit

```bash
# Run Lighthouse audit
lighthouse https://app.agency.com --output=json --output-path=./lighthouse-report.json

# With specific categories
lighthouse https://app.agency.com \
  --only-categories=performance,accessibility \
  --output=html \
  --output-path=./lighthouse-report.html
```

### Key Metrics

| Metric | Target | Description |
|--------|--------|-------------|
| First Contentful Paint (FCP) | < 1.8s | First content visible |
| Largest Contentful Paint (LCP) | < 2.5s | Main content loaded |
| Time to Interactive (TTI) | < 3.8s | Page fully interactive |
| Cumulative Layout Shift (CLS) | < 0.1 | Visual stability |
| Total Blocking Time (TBT) | < 200ms | Main thread blocking |

### Optimization Checklist

- [ ] Images optimized and lazy loaded
- [ ] CSS/JS minified and compressed
- [ ] Unused CSS removed
- [ ] Fonts preloaded
- [ ] HTTP/2 or HTTP/3 enabled
- [ ] CDN configured for static assets
- [ ] Gzip/Brotli compression enabled
- [ ] Browser caching headers set

---

## Monitoring

### Key Metrics to Track

| Metric | Tool | Alert Threshold |
|--------|------|-----------------|
| Response time P95 | APM | > 500ms |
| Error rate | APM | > 1% |
| Apdex score | APM | < 0.9 |
| Database query time | APM | > 100ms avg |
| Queue wait time | Horizon | > 60s |
| Memory usage | Server | > 80% |

### Dashboards

Create monitoring dashboards for:
1. **API Performance** - Response times by endpoint
2. **Database Performance** - Query times, connections
3. **Queue Performance** - Job throughput, wait times
4. **Resource Utilization** - CPU, memory, disk

---

## Baseline and Benchmarks

### Establishing Baselines

1. Run tests on production-like environment
2. Collect data for at least 1 week
3. Calculate P50, P95, P99 for each endpoint
4. Document baseline in this file
5. Set alerts at 2x baseline

### Current Baselines

| Endpoint | P50 | P95 | P99 | Date |
|----------|-----|-----|-----|------|
| GET /api/v1/projects | TBD | TBD | TBD | - |
| GET /api/v1/projects/:id | TBD | TBD | TBD | - |
| POST /api/v1/time-entries | TBD | TBD | TBD | - |
| GET /api/v1/invoices | TBD | TBD | TBD | - |

*Baselines to be established after initial deployment*

---

## Related Documents

- [Testing Strategy](./testing-strategy.md)
- [ADR-0020: Performance Optimization](../03-decisions/adr-0020-performance-optimization.md)
- [Common Tasks Runbook](../07-operations/runbook-common-tasks.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial performance testing documentation |
