---
id: "ADR-0018"
title: "Client Portal Architecture"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-PORT-001, REQ-PORT-002, REQ-PORT-003, REQ-PORT-004, REQ-PORT-005, REQ-PORT-006, REQ-PORT-008, REQ-PORT-009"
decision_makers: "Platform Team"
consulted: "Development Team, Client Success"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0018: Client Portal Architecture

## Context and Problem Statement

The agency needs a client-facing portal where clients can:
- [REQ-PORT-001](../01-requirements/req-port-001.md): View dashboard with project overview
- [REQ-PORT-002](../01-requirements/req-port-002.md): See project status and progress
- [REQ-PORT-003](../01-requirements/req-port-003.md): View invoices
- [REQ-PORT-004](../01-requirements/req-port-004.md): Make payments
- [REQ-PORT-005](../01-requirements/req-port-005.md): Download deliverables
- [REQ-PORT-006](../01-requirements/req-port-006.md): Submit feedback
- [REQ-PORT-008](../01-requirements/req-port-008.md): View contracts
- [REQ-PORT-009](../01-requirements/req-port-009.md): Approve project milestones

The portal is separate from the staff admin panel but shares the same data.

## Decision Drivers

- **Simplicity:** Clean, focused interface for clients
- **Security:** Strict data isolation (clients only see their data)
- **Real-time:** Project updates visible immediately
- **Mobile:** Responsive design for mobile access
- **Integration:** Shares data with admin panel (ADR-0010)
- **Performance:** Fast load times for client satisfaction

## Considered Options

1. **Option A:** Separate Livewire portal within Laravel app
2. **Option B:** Vue.js SPA with Laravel API
3. **Option C:** Filament tenant panel (multi-panel)
4. **Option D:** Separate Laravel application
5. **Option E:** Third-party portal solution

## Decision Outcome

**Chosen Option:** Option A - Separate Livewire portal within Laravel app

**Justification:** Building a dedicated portal using Livewire (separate from Filament admin):
- Same codebase, same deployment
- Livewire provides real-time updates without SPA complexity
- Full control over client-facing UI/UX
- Shared Eloquent models ensure data consistency
- Can be styled independently from admin panel
- Server-side rendering for SEO (if needed) and performance

### Consequences

#### Positive

- Single codebase reduces complexity
- Livewire enables real-time updates
- Full design freedom (not constrained by Filament)
- Shared authentication system with different guards
- Can leverage existing models and business logic
- Easy to add client-specific features

#### Negative

- Must build all portal UI components
- Separate from Filament ecosystem (no plugin reuse)
- More frontend development work
- Must maintain two UI systems (admin + portal)

#### Risks

- **Risk:** UI inconsistency between admin and portal
  - **Mitigation:** Create shared Blade components; establish design system
- **Risk:** Authorization logic duplication
  - **Mitigation:** Use Laravel Policies consistently; test thoroughly
- **Risk:** Feature parity issues (admin has it, portal doesn't)
  - **Mitigation:** Define portal scope clearly; prioritize client-facing features

## Validation

- **Metric 1:** Portal pages load in under 2 seconds
- **Metric 2:** Client can find project status in under 3 clicks
- **Metric 3:** Payment completion rate from portal >90%
- **Metric 4:** Client satisfaction score >4/5 for portal usability

## Pros and Cons of the Options

### Option A: Livewire Portal

**Pros:**
- Same codebase
- Real-time updates
- Full design control
- Server-side rendering

**Cons:**
- Build UI from scratch
- Two UI systems to maintain

### Option B: Vue.js SPA

**Pros:**
- Rich interactivity
- Modern frontend
- Decoupled from backend

**Cons:**
- Separate build process
- API development overhead
- More complex auth flow
- Slower initial load

### Option C: Filament Tenant Panel

**Pros:**
- Reuse Filament components
- Multi-panel built-in
- Faster development

**Cons:**
- Client sees "admin" interface
- Limited design customization
- May feel too technical for clients

### Option D: Separate Application

**Pros:**
- Complete independence
- Can use different stack

**Cons:**
- Data sync complexity
- Multiple deployments
- Duplicated logic

### Option E: Third-Party Portal

**Pros:**
- Ready-made solution
- Potentially faster

**Cons:**
- Integration complexity
- Limited customization
- Recurring costs
- Data lives elsewhere

## Implementation Notes

### Portal Routes and Authentication

```php
// routes/portal.php
Route::middleware(['auth:client', 'verified'])->prefix('portal')->name('portal.')->group(function () {
    Route::get('/', DashboardController::class)->name('dashboard');
    Route::get('/projects', ProjectsController::class)->name('projects');
    Route::get('/projects/{project}', ProjectController::class)->name('projects.show');
    Route::get('/invoices', InvoicesController::class)->name('invoices');
    Route::get('/invoices/{invoice}', InvoiceController::class)->name('invoices.show');
    Route::get('/files', FilesController::class)->name('files');
    Route::get('/messages', MessagesController::class)->name('messages');
    Route::get('/support', SupportController::class)->name('support');
});

// config/auth.php - Separate guard for clients
'guards' => [
    'web' => ['driver' => 'session', 'provider' => 'users'],
    'client' => ['driver' => 'session', 'provider' => 'clients'],
],
'providers' => [
    'users' => ['driver' => 'eloquent', 'model' => App\Models\User::class],
    'clients' => ['driver' => 'eloquent', 'model' => App\Models\ClientUser::class],
],
```

### Dashboard Component

```php
// app/Livewire/Portal/Dashboard.php
class Dashboard extends Component
{
    public function render()
    {
        $client = auth('client')->user()->client;

        return view('livewire.portal.dashboard', [
            'activeProjects' => $client->projects()->active()->get(),
            'pendingInvoices' => $client->invoices()->pending()->get(),
            'recentActivity' => $client->activities()->recent()->take(10)->get(),
            'unreadMessages' => $client->messages()->unread()->count(),
        ]);
    }
}
```

### Project Status Component (Real-time)

```php
// app/Livewire/Portal/ProjectStatus.php
class ProjectStatus extends Component
{
    public Project $project;

    protected $listeners = ['projectUpdated' => '$refresh'];

    public function render()
    {
        return view('livewire.portal.project-status', [
            'tasks' => $this->project->tasks()->with('assignee')->get(),
            'milestones' => $this->project->milestones,
            'progress' => $this->project->calculateProgress(),
            'timeline' => $this->project->activities()->recent()->get(),
        ]);
    }
}

// Broadcasting project updates
// app/Events/ProjectUpdated.php
class ProjectUpdated implements ShouldBroadcast
{
    public function broadcastOn()
    {
        return new PrivateChannel('client.' . $this->project->client_id);
    }
}
```

### Invoice Payment Flow

```php
// app/Livewire/Portal/InvoicePayment.php
class InvoicePayment extends Component
{
    public Invoice $invoice;

    public function pay()
    {
        // Redirect to Stripe Checkout (ADR-0014)
        return redirect()->to(
            $this->invoice->client->checkout([
                'line_items' => [[
                    'price_data' => [
                        'currency' => 'usd',
                        'product_data' => ['name' => "Invoice #{$this->invoice->number}"],
                        'unit_amount' => $this->invoice->amount_cents,
                    ],
                    'quantity' => 1,
                ]],
                'mode' => 'payment',
                'success_url' => route('portal.invoices.paid', $this->invoice),
                'cancel_url' => route('portal.invoices.show', $this->invoice),
                'metadata' => ['invoice_id' => $this->invoice->id],
            ])->url
        );
    }
}
```

### Feedback Submission

```php
// app/Livewire/Portal/FeedbackForm.php
class FeedbackForm extends Component
{
    public Project $project;
    public ?Deliverable $deliverable = null;

    public string $feedback = '';
    public string $status = 'pending'; // approved, revision_requested

    public function submit()
    {
        $this->validate(['feedback' => 'required|min:10']);

        $this->project->feedback()->create([
            'client_user_id' => auth('client')->id(),
            'deliverable_id' => $this->deliverable?->id,
            'content' => $this->feedback,
            'status' => $this->status,
        ]);

        // Notify project team
        $this->project->team->each->notify(new ClientFeedbackReceived($this->project));

        $this->reset('feedback');
        $this->dispatch('feedbackSubmitted');
    }
}
```

### Approval Workflow

```php
// app/Livewire/Portal/MilestoneApproval.php
class MilestoneApproval extends Component
{
    public Milestone $milestone;

    public function approve()
    {
        $this->authorize('approve', $this->milestone);

        $this->milestone->update([
            'approved_at' => now(),
            'approved_by' => auth('client')->id(),
        ]);

        // Trigger next phase or invoice
        event(new MilestoneApproved($this->milestone));
    }

    public function requestRevision(string $notes)
    {
        $this->milestone->revisionRequests()->create([
            'requested_by' => auth('client')->id(),
            'notes' => $notes,
        ]);

        // Notify project team
    }
}
```

### Portal Layout

```blade
{{-- resources/views/layouts/portal.blade.php --}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title ?? 'Client Portal' }} - Agency Name</title>
    @vite(['resources/css/portal.css', 'resources/js/portal.js'])
    @livewireStyles
</head>
<body class="bg-gray-50">
    <div class="min-h-screen flex">
        {{-- Sidebar --}}
        <aside class="w-64 bg-white border-r">
            <div class="p-6">
                <img src="/logo.svg" alt="Agency" class="h-8">
            </div>
            <nav class="px-4">
                <a href="{{ route('portal.dashboard') }}" class="nav-link">
                    Dashboard
                </a>
                <a href="{{ route('portal.projects') }}" class="nav-link">
                    Projects
                </a>
                <a href="{{ route('portal.invoices') }}" class="nav-link">
                    Invoices
                </a>
                <a href="{{ route('portal.files') }}" class="nav-link">
                    Files
                </a>
                <a href="{{ route('portal.messages') }}" class="nav-link">
                    Messages
                    @if($unreadCount > 0)
                        <span class="badge">{{ $unreadCount }}</span>
                    @endif
                </a>
                <a href="{{ route('portal.support') }}" class="nav-link">
                    Support
                </a>
            </nav>
        </aside>

        {{-- Main content --}}
        <main class="flex-1 p-8">
            {{ $slot }}
        </main>
    </div>

    @livewireScripts
</body>
</html>
```

### Data Isolation Policy

```php
// app/Policies/ProjectPolicy.php
class ProjectPolicy
{
    public function view(ClientUser $clientUser, Project $project): bool
    {
        return $project->client_id === $clientUser->client_id;
    }
}

// Global scope for client context
// app/Scopes/ClientScope.php
class ClientScope implements Scope
{
    public function apply(Builder $builder, Model $model): void
    {
        if (auth('client')->check()) {
            $builder->where('client_id', auth('client')->user()->client_id);
        }
    }
}
```

## Links

- [REQ-PORT-001](../01-requirements/req-port-001.md) - Client Dashboard
- [REQ-PORT-002](../01-requirements/req-port-002.md) - Project Status Visibility
- [REQ-PORT-003](../01-requirements/req-port-003.md) - Invoice Viewing
- [REQ-PORT-004](../01-requirements/req-port-004.md) - Payment from Portal
- [REQ-PORT-005](../01-requirements/req-port-005.md) - File/Deliverable Downloads
- [REQ-PORT-006](../01-requirements/req-port-006.md) - Feedback Submission
- [REQ-PORT-008](../01-requirements/req-port-008.md) - Contract/Agreement Viewing
- [REQ-PORT-009](../01-requirements/req-port-009.md) - Project Approval Workflow
- [ADR-0001](./adr-0001-project-management-tool.md) - Project Management
- [ADR-0002](./adr-0002-invoicing-solution.md) - Invoicing
- [ADR-0010](./adr-0010-admin-panel.md) - Admin Panel (Filament)
- [ADR-0014](./adr-0014-payment-processing.md) - Payment Processing
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
