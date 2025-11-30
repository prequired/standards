---
id: "ADR-0013"
title: "Analytics & Reporting Strategy"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-ANLY-001, REQ-ANLY-002, REQ-ANLY-003, REQ-ANLY-004, REQ-ANLY-005, REQ-ANLY-006, REQ-ANLY-007"
decision_makers: "Platform Team"
consulted: "Business, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0013: Analytics & Reporting Strategy

## Context and Problem Statement

The platform requires comprehensive analytics and reporting:
- [REQ-ANLY-001](../01-requirements/req-anly-001.md): Admin Analytics Dashboard
- [REQ-ANLY-002](../01-requirements/req-anly-002.md): Client Reporting
- [REQ-ANLY-003](../01-requirements/req-anly-003.md): Revenue & Financial Reports
- [REQ-ANLY-004](../01-requirements/req-anly-004.md): Project Performance Metrics
- [REQ-ANLY-005](../01-requirements/req-anly-005.md): Team Productivity Analytics
- [REQ-ANLY-006](../01-requirements/req-anly-006.md): Data Export Functionality
- [REQ-ANLY-007](../01-requirements/req-anly-007.md): Scheduled Report Delivery

Analytics must serve both internal staff (business insights) and clients (project/account visibility).

## Decision Drivers

- **Integration:** Reports should pull from live application data
- **Real-time:** Dashboards show current state, not stale data
- **Export:** Support PDF, CSV, Excel export formats
- **Scheduling:** Automated report delivery via email
- **Performance:** Large dataset queries shouldn't impact application
- **Cost:** Avoid expensive BI tool subscriptions

## Considered Options

1. **Option A:** Build custom dashboards with Filament Widgets
2. **Option B:** Integrate Metabase (self-hosted)
3. **Option C:** Integrate Google Looker Studio (formerly Data Studio)
4. **Option D:** Integrate Tableau
5. **Option E:** Build with Laravel + Chart.js + Queued Reports

## Decision Outcome

**Chosen Option:** Option A - Build custom dashboards with Filament Widgets + Laravel Excel

**Justification:** Since the admin panel uses Filament (ADR-0010), leveraging Filament's widget system provides:
- Native integration with existing admin panel
- Same permission system and UI consistency
- No additional tools or data sync
- Full control over metrics and presentation
- No additional licensing costs

For exports and scheduled reports, Laravel Excel and DomPDF provide robust solutions.

### Consequences

#### Positive

- Single tool for all admin functionality (Filament)
- Real-time data from application database
- Full customization of metrics and visualizations
- No external BI tool costs or complexity
- Same authentication and permissions
- Exports use familiar Laravel patterns

#### Negative

- Must build all charts and visualizations
- Complex queries may impact database performance
- No drag-and-drop report builder
- Limited compared to dedicated BI tools

#### Risks

- **Risk:** Complex reports slow down database
  - **Mitigation:** Use database read replica; cache expensive queries; run reports off-peak
- **Risk:** Building every chart takes significant time
  - **Mitigation:** Use Filament Chart plugin; prioritize key metrics; iterate
- **Risk:** Report requirements grow beyond capabilities
  - **Mitigation:** Can migrate to dedicated BI tool later; data remains accessible

## Validation

- **Metric 1:** Dashboard loads in under 2 seconds
- **Metric 2:** Export completes for 10,000 rows in under 30 seconds
- **Metric 3:** Scheduled reports delivered within 1 hour of scheduled time
- **Metric 4:** 90% of reporting needs met without external tools

## Pros and Cons of the Options

### Option A: Filament Widgets + Laravel Excel

**Pros:**
- Native to admin panel
- No additional costs
- Full customization
- Real-time data
- Same permissions

**Cons:**
- Must build all visualizations
- No SQL query builder UI
- Limited chart types

### Option B: Metabase (Self-hosted)

**Pros:**
- Powerful query builder
- Good visualizations
- Free/open source
- SQL and no-code options

**Cons:**
- Separate application to host/maintain
- Separate authentication
- Data sync or direct DB access
- Resource overhead

### Option C: Google Looker Studio

**Pros:**
- Free
- Good visualizations
- Shareable dashboards

**Cons:**
- Requires data connector/export
- Google account dependency
- Limited real-time capability
- Data lives in Google

### Option D: Tableau

**Pros:**
- Industry-leading visualizations
- Powerful analytics
- Enterprise features

**Cons:**
- Expensive ($70+/user/month)
- Complex for simple needs
- Requires data pipeline
- Overkill for agency scale

### Option E: Laravel + Chart.js

**Pros:**
- Full control
- No dependencies
- Lightweight

**Cons:**
- More manual than Filament widgets
- Must build dashboard framework
- Duplicates Filament functionality

## Implementation Notes

### Dashboard Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Filament Admin Panel               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │           Admin Dashboard (Staff)            │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │
│  │  │ Revenue │ │ Projects│ │ Tasks   │       │   │
│  │  │ Widget  │ │ Widget  │ │ Widget  │       │   │
│  │  └─────────┘ └─────────┘ └─────────┘       │   │
│  │  ┌─────────────────────────────────┐       │   │
│  │  │     Revenue Chart (Monthly)      │       │   │
│  │  └─────────────────────────────────┘       │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │          Client Dashboard (Portal)           │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │
│  │  │Projects │ │ Invoices│ │ Hours   │       │   │
│  │  │ Status  │ │ Due     │ │ Logged  │       │   │
│  │  └─────────┘ └─────────┘ └─────────┘       │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Key Dashboards

1. **Admin Analytics Dashboard (REQ-ANLY-001)**
   - Total revenue (MTD, YTD, trends)
   - Active projects count
   - Outstanding invoices
   - Team utilization rate
   - New leads/clients

2. **Client Dashboard (REQ-ANLY-002)**
   - Project status summary
   - Hours logged this month
   - Invoices due
   - Recent activity

3. **Financial Reports (REQ-ANLY-003)**
   - Revenue by month/quarter
   - Revenue by client
   - Revenue by service type
   - Outstanding receivables aging
   - Profit margins by project

4. **Project Reports (REQ-ANLY-004)**
   - Project profitability (budget vs actual)
   - Timeline adherence
   - Scope changes
   - Resource utilization

5. **Team Reports (REQ-ANLY-005)**
   - Hours by team member
   - Billable vs non-billable ratio
   - Utilization rate
   - Project assignments

### Export Implementation

```php
// Using Laravel Excel (maatwebsite/excel)
use Maatwebsite\Excel\Concerns\FromQuery;
use Maatwebsite\Excel\Concerns\WithHeadings;

class ProjectsExport implements FromQuery, WithHeadings
{
    public function query()
    {
        return Project::query()
            ->with(['client', 'tasks'])
            ->select(['id', 'name', 'status', 'budget', 'created_at']);
    }

    public function headings(): array
    {
        return ['ID', 'Name', 'Status', 'Budget', 'Created'];
    }
}

// Export route
Route::get('/exports/projects', function () {
    return Excel::download(new ProjectsExport, 'projects.xlsx');
});
```

### Scheduled Reports

```php
// app/Console/Kernel.php
$schedule->job(new SendWeeklyRevenueReport)->weeklyOn(1, '8:00');
$schedule->job(new SendMonthlyClientReports)->monthlyOn(1, '9:00');

// Job handles: generate PDF, email to subscribers
class SendWeeklyRevenueReport implements ShouldQueue
{
    public function handle()
    {
        $data = $this->generateReportData();
        $pdf = PDF::loadView('reports.revenue', $data);

        Mail::to(config('reports.recipients'))
            ->send(new WeeklyRevenueReport($pdf));
    }
}
```

### Filament Widget Example

```php
// app/Filament/Widgets/RevenueOverview.php
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class RevenueOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Revenue (MTD)', money(Invoice::paidThisMonth()))
                ->description('12% increase')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success'),
            Stat::make('Outstanding', money(Invoice::outstanding()))
                ->description('5 invoices overdue')
                ->color('warning'),
            Stat::make('Active Projects', Project::active()->count())
                ->description('3 due this week'),
        ];
    }
}
```

## Links

- [REQ-ANLY-001](../01-requirements/req-anly-001.md) - Admin Analytics Dashboard
- [REQ-ANLY-002](../01-requirements/req-anly-002.md) - Client Reporting
- [REQ-ANLY-003](../01-requirements/req-anly-003.md) - Revenue & Financial Reports
- [REQ-ANLY-004](../01-requirements/req-anly-004.md) - Project Performance Metrics
- [REQ-ANLY-005](../01-requirements/req-anly-005.md) - Team Productivity Analytics
- [REQ-ANLY-006](../01-requirements/req-anly-006.md) - Data Export Functionality
- [REQ-ANLY-007](../01-requirements/req-anly-007.md) - Scheduled Report Delivery
- [ADR-0010](./adr-0010-admin-panel.md) - Admin Panel (Filament)
- [Filament Widgets Documentation](https://filamentphp.com/docs/widgets)
- [Laravel Excel Documentation](https://docs.laravel-excel.com)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
