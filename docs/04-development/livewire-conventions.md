---
id: "DEV-LIVEWIRE"
title: "Livewire 3 Component Conventions"
version: "1.0.0"
status: "active"
owner: "Frontend Lead"
last_updated: "2025-11-30"
---

# Livewire 3 Component Conventions

Standards and best practices for building Livewire 3 components in the Agency Platform.

---

## Component Structure

### File Organization

```
app/Livewire/
├── Components/           # Reusable UI components
│   ├── Forms/
│   │   ├── DatePicker.php
│   │   └── FileUpload.php
│   └── Tables/
│       └── DataTable.php
├── Pages/                # Full-page components
│   ├── Projects/
│   │   ├── Index.php
│   │   ├── Show.php
│   │   └── Edit.php
│   └── Invoices/
│       └── Create.php
└── Widgets/              # Dashboard widgets
    ├── RevenueChart.php
    └── ActiveProjects.php
```

### Component Class Structure

```php
<?php

declare(strict_types=1);

namespace App\Livewire\Pages\Projects;

use App\Models\Project;
use Illuminate\Contracts\View\View;
use Livewire\Attributes\Computed;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Title;
use Livewire\Attributes\Url;
use Livewire\Component;
use Livewire\WithPagination;

/**
 * Project listing page component.
 *
 * @package App\Livewire\Pages\Projects
 */
#[Layout('layouts.app')]
#[Title('Projects')]
final class Index extends Component
{
    use WithPagination;

    // 1. URL-bound properties first
    #[Url]
    public string $search = '';

    #[Url]
    public string $status = '';

    // 2. Public properties (component state)
    public bool $showFilters = false;

    // 3. Protected/private properties
    protected int $perPage = 20;

    // 4. Lifecycle hooks
    public function mount(): void
    {
        // Initialize component state
    }

    public function updated(string $property): void
    {
        if (in_array($property, ['search', 'status'])) {
            $this->resetPage();
        }
    }

    // 5. Computed properties
    #[Computed]
    public function projects(): LengthAwarePaginator
    {
        return Project::query()
            ->when($this->search, fn ($q) => $q->search($this->search))
            ->when($this->status, fn ($q) => $q->where('status', $this->status))
            ->with('client:id,name')
            ->latest()
            ->paginate($this->perPage);
    }

    #[Computed]
    public function statusOptions(): array
    {
        return Project::getStatusOptions();
    }

    // 6. Actions (public methods)
    public function clearFilters(): void
    {
        $this->reset(['search', 'status']);
        $this->resetPage();
    }

    public function deleteProject(int $projectId): void
    {
        $this->authorize('delete', Project::findOrFail($projectId));

        Project::destroy($projectId);

        $this->dispatch('project-deleted');
    }

    // 7. Render method last
    public function render(): View
    {
        return view('livewire.pages.projects.index');
    }
}
```

---

## State Management

### Property Types

```php
// Simple state
public string $name = '';
public int $count = 0;
public bool $isActive = false;

// Array state
public array $selectedIds = [];
public array $filters = ['status' => '', 'date' => ''];

// Model binding (for forms)
public ?Project $project = null;

// URL-bound state (survives page refresh)
#[Url]
public string $tab = 'details';

#[Url(as: 'q')]  // Custom query parameter name
public string $search = '';

#[Url(history: true)]  // Use browser history
public string $page = '1';
```

### Resetting State

```php
// Reset specific properties
$this->reset(['search', 'status']);

// Reset all properties except specified
$this->resetExcept(['project']);

// Reset validation errors
$this->resetValidation();
$this->resetValidation('email');  // Specific field
```

---

## Computed Properties

Use computed properties for derived data that should be cached within a single request.

```php
use Livewire\Attributes\Computed;

// Basic computed property
#[Computed]
public function fullName(): string
{
    return "{$this->firstName} {$this->lastName}";
}

// Computed with caching hint
#[Computed(persist: true)]  // Persists across requests
public function expensiveCalculation(): array
{
    return $this->calculateMetrics();
}

// Access in Blade
// $this->fullName or $this->expensiveCalculation
```

### When to Use Computed vs Methods

| Use Case | Solution |
|----------|----------|
| Derived data accessed multiple times in template | Computed property |
| Data that changes rarely | Computed with `persist: true` |
| Data needed only once | Regular method |
| Data that must be fresh on every access | Regular method |

---

## Form Handling

### Real-Time Validation

```php
use Livewire\Attributes\Validate;

// Property-level validation
#[Validate('required|string|max:255')]
public string $name = '';

#[Validate('required|email|unique:users,email')]
public string $email = '';

#[Validate('required|min:8')]
public string $password = '';

// Validate on update
public function updated(string $property): void
{
    $this->validateOnly($property);
}

// Submit with validation
public function save(): void
{
    $validated = $this->validate();

    User::create($validated);

    $this->dispatch('user-created');
    $this->reset();
}
```

### Complex Validation Rules

```php
// Define rules in method for complex logic
protected function rules(): array
{
    return [
        'project.name' => ['required', 'string', 'max:255'],
        'project.client_id' => ['required', 'exists:clients,id'],
        'project.budget_cents' => ['nullable', 'integer', 'min:0'],
        'project.due_date' => ['nullable', 'date', 'after:today'],
    ];
}

// Custom messages
protected function messages(): array
{
    return [
        'project.name.required' => 'Please enter a project name.',
        'project.due_date.after' => 'Due date must be in the future.',
    ];
}

// Custom attribute names
protected function validationAttributes(): array
{
    return [
        'project.client_id' => 'client',
        'project.budget_cents' => 'budget',
    ];
}
```

### Form Object Pattern

For complex forms, extract to a Form object:

```php
use Livewire\Attributes\Validate;
use Livewire\Form;

final class ProjectForm extends Form
{
    #[Validate('required|string|max:255')]
    public string $name = '';

    #[Validate('required|exists:clients,id')]
    public int $client_id = 0;

    #[Validate('nullable|integer|min:0')]
    public ?int $budget_cents = null;

    public function setProject(Project $project): void
    {
        $this->name = $project->name;
        $this->client_id = $project->client_id;
        $this->budget_cents = $project->budget_cents;
    }
}

// In component
public ProjectForm $form;

public function save(): void
{
    Project::create($this->form->validate());
}
```

---

## Event Handling

### Dispatching Events

```php
// Dispatch to parent component
$this->dispatch('project-saved', projectId: $project->id);

// Dispatch to specific component
$this->dispatch('refresh')->to('project-list');

// Dispatch to all components
$this->dispatch('notification', message: 'Project saved!');

// Dispatch to self (for JS listeners)
$this->dispatch('open-modal');
```

### Listening for Events

```php
use Livewire\Attributes\On;

// Listen for event
#[On('project-saved')]
public function handleProjectSaved(int $projectId): void
{
    $this->refreshProjects();
}

// Listen for browser events
#[On('echo:projects,ProjectUpdated')]
public function handleBroadcast(array $event): void
{
    // Handle real-time update
}
```

### In Blade Templates

```blade
{{-- Dispatch from button --}}
<button wire:click="$dispatch('open-modal', { id: {{ $project->id }} })">
    Edit
</button>

{{-- Listen in Alpine --}}
<div x-data @project-saved.window="$refresh">
    ...
</div>
```

---

## Performance Optimization

### Lazy Loading

```php
use Livewire\Attributes\Lazy;

// Component loads placeholder first, then hydrates
#[Lazy]
final class ExpensiveWidget extends Component
{
    public function placeholder(): View
    {
        return view('livewire.placeholders.widget');
    }
}
```

### Deferred Updates

```blade
{{-- Only update on blur, not every keystroke --}}
<input wire:model.blur="email" type="email">

{{-- Debounce updates --}}
<input wire:model.debounce.500ms="search" type="text">

{{-- Throttle updates --}}
<input wire:model.throttle.1000ms="value" type="range">
```

### Wire:key for Lists

```blade
@foreach($projects as $project)
    {{-- Always use wire:key for dynamic lists --}}
    <div wire:key="project-{{ $project->id }}">
        <livewire:project-card :project="$project" :key="$project->id" />
    </div>
@endforeach
```

### Polling (Use Sparingly)

```blade
{{-- Poll every 5 seconds --}}
<div wire:poll.5s>
    {{ $this->notificationCount }}
</div>

{{-- Poll only when tab is visible --}}
<div wire:poll.5s.visible>
    {{ $this->activeUsers }}
</div>

{{-- Keep alive without full refresh --}}
<div wire:poll.keep-alive>
    ...
</div>
```

---

## Component Communication

### Parent to Child

```blade
{{-- Pass data via props --}}
<livewire:project-card
    :project="$project"
    :show-actions="true"
/>
```

```php
// Child component
public Project $project;
public bool $showActions = false;

public function mount(Project $project, bool $showActions = false): void
{
    $this->project = $project;
    $this->showActions = $showActions;
}
```

### Child to Parent

```php
// Child dispatches event
$this->dispatch('item-selected', itemId: $item->id);

// Parent listens
#[On('item-selected')]
public function handleItemSelected(int $itemId): void
{
    $this->selectedItemId = $itemId;
}
```

### Sibling Communication

```php
// Component A dispatches
$this->dispatch('filter-changed', filters: $this->filters);

// Component B listens
#[On('filter-changed')]
public function applyFilters(array $filters): void
{
    $this->filters = $filters;
    $this->resetPage();
}
```

---

## Modal Pattern

```php
final class ProjectModal extends Component
{
    public bool $show = false;
    public ?Project $project = null;

    #[On('open-project-modal')]
    public function open(?int $projectId = null): void
    {
        $this->project = $projectId
            ? Project::findOrFail($projectId)
            : new Project();
        $this->show = true;
    }

    public function close(): void
    {
        $this->show = false;
        $this->project = null;
        $this->resetValidation();
    }

    public function save(): void
    {
        $this->validate();
        $this->project->save();

        $this->dispatch('project-saved');
        $this->close();
    }
}
```

```blade
{{-- Modal template --}}
<div>
    @if($show)
        <div class="fixed inset-0 bg-black/50" wire:click="close"></div>
        <div class="fixed inset-0 flex items-center justify-center">
            <div class="bg-white rounded-lg p-6 max-w-lg w-full" @click.stop>
                <form wire:submit="save">
                    {{-- Form fields --}}
                    <button type="submit">Save</button>
                    <button type="button" wire:click="close">Cancel</button>
                </form>
            </div>
        </div>
    @endif
</div>
```

---

## File Uploads

```php
use Livewire\WithFileUploads;
use Livewire\Attributes\Validate;

final class DocumentUpload extends Component
{
    use WithFileUploads;

    #[Validate('required|file|mimes:pdf,doc,docx|max:10240')]  // 10MB
    public $document;

    #[Validate('array|max:5')]
    #[Validate('image|max:2048', as: 'images.*')]
    public array $images = [];

    public function save(): void
    {
        $this->validate();

        // Store single file
        $path = $this->document->store('documents', 'spaces');

        // Store multiple files
        foreach ($this->images as $image) {
            $image->store('images', 'spaces');
        }
    }
}
```

```blade
<form wire:submit="save">
    {{-- Single file --}}
    <input type="file" wire:model="document">
    @error('document') <span>{{ $message }}</span> @enderror

    {{-- Preview while uploading --}}
    @if ($document)
        <span>{{ $document->getClientOriginalName() }}</span>
    @endif

    {{-- Multiple files --}}
    <input type="file" wire:model="images" multiple>

    {{-- Image previews --}}
    @foreach($images as $image)
        <img src="{{ $image->temporaryUrl() }}" alt="Preview">
    @endforeach

    {{-- Loading state --}}
    <div wire:loading wire:target="document">Uploading...</div>

    <button type="submit">Upload</button>
</form>
```

---

## Testing Livewire Components

### Basic Component Test

```php
use App\Livewire\Pages\Projects\Index;
use App\Models\Project;
use Livewire\Livewire;

test('can render project index', function () {
    $project = Project::factory()->create();

    Livewire::test(Index::class)
        ->assertSee($project->name)
        ->assertStatus(200);
});
```

### Testing State Changes

```php
test('can filter projects by status', function () {
    $active = Project::factory()->active()->create();
    $completed = Project::factory()->completed()->create();

    Livewire::test(Index::class)
        ->set('status', 'active')
        ->assertSee($active->name)
        ->assertDontSee($completed->name);
});
```

### Testing Actions

```php
test('can delete project', function () {
    $user = User::factory()->admin()->create();
    $project = Project::factory()->create();

    Livewire::actingAs($user)
        ->test(Index::class)
        ->call('deleteProject', $project->id)
        ->assertDispatched('project-deleted');

    expect(Project::find($project->id))->toBeNull();
});
```

### Testing Validation

```php
test('validates required fields', function () {
    Livewire::test(ProjectForm::class)
        ->set('name', '')
        ->call('save')
        ->assertHasErrors(['name' => 'required']);
});

test('validates email format', function () {
    Livewire::test(UserForm::class)
        ->set('email', 'not-an-email')
        ->call('save')
        ->assertHasErrors(['email' => 'email']);
});
```

### Testing Events

```php
test('dispatches event on save', function () {
    $project = Project::factory()->create();

    Livewire::test(ProjectEdit::class, ['project' => $project])
        ->set('name', 'Updated Name')
        ->call('save')
        ->assertDispatched('project-saved', projectId: $project->id);
});

test('listens for refresh event', function () {
    Livewire::test(ProjectList::class)
        ->dispatch('project-created')
        ->assertSet('refreshCount', 1);
});
```

---

## Common Anti-Patterns

### ❌ Don't: Query in Render

```php
// BAD: Queries on every render
public function render(): View
{
    return view('livewire.projects', [
        'projects' => Project::all(),  // Runs every time!
    ]);
}
```

### ✅ Do: Use Computed Properties

```php
// GOOD: Cached within request
#[Computed]
public function projects(): Collection
{
    return Project::all();
}

public function render(): View
{
    return view('livewire.projects');
    // Access via $this->projects in Blade
}
```

### ❌ Don't: Store Eloquent Models in Session

```php
// BAD: Serializes entire model
public $user;  // Will serialize and bloat session
```

### ✅ Do: Store IDs and Reload

```php
// GOOD: Store ID, load when needed
public int $userId;

#[Computed]
public function user(): User
{
    return User::find($this->userId);
}
```

### ❌ Don't: Mutate Props Directly

```php
// BAD: Modifying passed-in model
public function updateStatus(): void
{
    $this->project->status = 'active';  // Risky
    $this->project->save();
}
```

### ✅ Do: Use Explicit Actions

```php
// GOOD: Clear intent
public function markActive(): void
{
    $this->project->markAsActive();
    $this->dispatch('project-updated');
}
```

---

## Alpine.js Integration

```blade
<div
    x-data="{
        open: false,
        count: @entangle('count'),        {{-- Two-way binding --}}
        items: @entangle('items').live,   {{-- Live sync --}}
    }"
    @keydown.escape="open = false"
>
    <button @click="open = !open">Toggle</button>

    <div x-show="open" x-transition>
        {{-- Livewire action from Alpine --}}
        <button @click="$wire.increment()">+</button>
        <span x-text="count"></span>

        {{-- Call Livewire method with args --}}
        <button @click="$wire.setCount(10)">Set to 10</button>
    </div>
</div>
```

---

## Related Documentation

- [Development Standards](./dev-standards.md) - General coding standards
- [Blade Components Guide](./blade-components.md) - Component patterns
- [Testing Strategy](../06-testing/testing-strategy.md) - Test organization
- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md) - Filament integration

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-30 | 1.0.0 | Claude | Initial Livewire 3 conventions |
