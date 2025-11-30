---
id: "DEV-FILAMENT"
title: "Filament 3 Admin Panel Conventions"
version: "1.0.0"
status: "active"
owner: "Admin Development Lead"
last_updated: "2025-11-30"
---

# Filament 3 Admin Panel Conventions

Standards and best practices for building Filament 3 admin resources and pages.

---

## File Organization

```
app/Filament/
├── Resources/
│   ├── ProjectResource/
│   │   ├── Pages/
│   │   │   ├── CreateProject.php
│   │   │   ├── EditProject.php
│   │   │   ├── ListProjects.php
│   │   │   └── ViewProject.php
│   │   └── RelationManagers/
│   │       ├── TasksRelationManager.php
│   │       └── TimeEntriesRelationManager.php
│   ├── ProjectResource.php
│   ├── ClientResource.php
│   ├── InvoiceResource.php
│   └── UserResource.php
├── Pages/
│   ├── Dashboard.php
│   ├── Settings.php
│   └── Reports/
│       ├── RevenueReport.php
│       └── ProjectReport.php
├── Widgets/
│   ├── StatsOverview.php
│   ├── RevenueChart.php
│   └── LatestProjects.php
└── Clusters/
    └── Settings/
        ├── Resources/
        └── Pages/
```

---

## Resource Structure

### Basic Resource

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources;

use App\Filament\Resources\ProjectResource\Pages;
use App\Filament\Resources\ProjectResource\RelationManagers;
use App\Models\Project;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\SoftDeletingScope;

/**
 * Filament resource for managing Projects.
 *
 * @package App\Filament\Resources
 */
final class ProjectResource extends Resource
{
    protected static ?string $model = Project::class;

    protected static ?string $navigationIcon = 'heroicon-o-folder';

    protected static ?string $navigationGroup = 'Projects';

    protected static ?int $navigationSort = 1;

    protected static ?string $recordTitleAttribute = 'name';

    // Global search configuration
    public static function getGloballySearchableAttributes(): array
    {
        return ['name', 'client.name', 'description'];
    }

    public static function getGlobalSearchResultDetails($record): array
    {
        return [
            'Client' => $record->client->name,
            'Status' => $record->status->label(),
        ];
    }

    public static function form(Form $form): Form
    {
        return $form->schema(self::getFormSchema());
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns(self::getTableColumns())
            ->filters(self::getTableFilters())
            ->actions(self::getTableActions())
            ->bulkActions(self::getBulkActions())
            ->defaultSort('created_at', 'desc');
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\TasksRelationManager::class,
            RelationManagers\TimeEntriesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListProjects::route('/'),
            'create' => Pages\CreateProject::route('/create'),
            'view' => Pages\ViewProject::route('/{record}'),
            'edit' => Pages\EditProject::route('/{record}/edit'),
        ];
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->withoutGlobalScopes([
                SoftDeletingScope::class,
            ]);
    }

    // Private helper methods for organization
    private static function getFormSchema(): array
    {
        return [
            Forms\Components\Section::make('Project Details')
                ->schema([
                    Forms\Components\TextInput::make('name')
                        ->required()
                        ->maxLength(255)
                        ->columnSpan(2),

                    Forms\Components\Select::make('client_id')
                        ->relationship('client', 'name')
                        ->searchable()
                        ->preload()
                        ->required()
                        ->createOptionForm(ClientResource::getFormSchema()),

                    Forms\Components\Select::make('status')
                        ->options(ProjectStatus::class)
                        ->required()
                        ->default(ProjectStatus::Draft),

                    Forms\Components\Textarea::make('description')
                        ->rows(3)
                        ->columnSpanFull(),
                ])
                ->columns(2),

            Forms\Components\Section::make('Budget & Timeline')
                ->schema([
                    Forms\Components\TextInput::make('budget_cents')
                        ->label('Budget')
                        ->numeric()
                        ->prefix('$')
                        ->formatStateUsing(fn (?int $state) => $state ? $state / 100 : null)
                        ->dehydrateStateUsing(fn (?float $state) => $state ? (int) ($state * 100) : null),

                    Forms\Components\TextInput::make('hourly_rate_cents')
                        ->label('Hourly Rate')
                        ->numeric()
                        ->prefix('$')
                        ->formatStateUsing(fn (?int $state) => $state ? $state / 100 : null)
                        ->dehydrateStateUsing(fn (?float $state) => $state ? (int) ($state * 100) : null),

                    Forms\Components\DatePicker::make('due_date')
                        ->native(false),
                ])
                ->columns(3),
        ];
    }

    private static function getTableColumns(): array
    {
        return [
            Tables\Columns\TextColumn::make('name')
                ->searchable()
                ->sortable()
                ->description(fn (Project $record) => $record->client->name),

            Tables\Columns\TextColumn::make('status')
                ->badge()
                ->sortable(),

            Tables\Columns\TextColumn::make('budget_cents')
                ->label('Budget')
                ->money('USD', divideBy: 100)
                ->sortable(),

            Tables\Columns\TextColumn::make('due_date')
                ->date()
                ->sortable()
                ->color(fn (Project $record) => $record->isOverdue() ? 'danger' : null),

            Tables\Columns\TextColumn::make('tasks_count')
                ->counts('tasks')
                ->label('Tasks'),

            Tables\Columns\TextColumn::make('created_at')
                ->dateTime()
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true),
        ];
    }

    private static function getTableFilters(): array
    {
        return [
            Tables\Filters\SelectFilter::make('status')
                ->options(ProjectStatus::class),

            Tables\Filters\SelectFilter::make('client')
                ->relationship('client', 'name')
                ->searchable()
                ->preload(),

            Tables\Filters\Filter::make('overdue')
                ->query(fn (Builder $query) => $query->overdue())
                ->toggle(),

            Tables\Filters\TrashedFilter::make(),
        ];
    }

    private static function getTableActions(): array
    {
        return [
            Tables\Actions\ViewAction::make(),
            Tables\Actions\EditAction::make(),
            Tables\Actions\Action::make('complete')
                ->icon('heroicon-o-check')
                ->color('success')
                ->requiresConfirmation()
                ->visible(fn (Project $record) => $record->canBeCompleted())
                ->action(fn (Project $record) => $record->markAsCompleted()),
        ];
    }

    private static function getBulkActions(): array
    {
        return [
            Tables\Actions\BulkActionGroup::make([
                Tables\Actions\DeleteBulkAction::make(),
                Tables\Actions\ForceDeleteBulkAction::make(),
                Tables\Actions\RestoreBulkAction::make(),
            ]),
        ];
    }
}
```

---

## Form Builder Patterns

### Common Field Configurations

```php
use Filament\Forms\Components;

// Text Input with Validation
Components\TextInput::make('name')
    ->required()
    ->maxLength(255)
    ->unique(ignoreRecord: true)
    ->autofocus()
    ->placeholder('Enter project name');

// Email with Real-time Validation
Components\TextInput::make('email')
    ->email()
    ->required()
    ->unique('users', 'email', ignoreRecord: true)
    ->live(onBlur: true)
    ->afterStateUpdated(fn ($state, $set) => $set('username', Str::before($state, '@')));

// Select with Search
Components\Select::make('client_id')
    ->label('Client')
    ->relationship('client', 'name')
    ->searchable()
    ->preload()
    ->required()
    ->createOptionForm([
        Components\TextInput::make('name')->required(),
        Components\TextInput::make('email')->email()->required(),
    ])
    ->editOptionForm([
        Components\TextInput::make('name')->required(),
        Components\TextInput::make('email')->email()->required(),
    ]);

// Multi-Select with Relationship
Components\Select::make('tags')
    ->relationship('tags', 'name')
    ->multiple()
    ->preload()
    ->createOptionForm([
        Components\TextInput::make('name')->required(),
        Components\ColorPicker::make('color'),
    ]);

// Rich Text Editor
Components\RichEditor::make('description')
    ->toolbarButtons([
        'bold', 'italic', 'underline', 'strike',
        'h2', 'h3',
        'bulletList', 'orderedList',
        'link',
        'blockquote', 'codeBlock',
    ])
    ->columnSpanFull();

// File Upload
Components\FileUpload::make('attachment')
    ->disk('spaces')
    ->directory('project-attachments')
    ->visibility('private')
    ->acceptedFileTypes(['application/pdf', 'image/*'])
    ->maxSize(10240)  // 10MB
    ->downloadable()
    ->openable();

// Image Upload with Preview
Components\FileUpload::make('avatar')
    ->image()
    ->disk('spaces')
    ->directory('avatars')
    ->imageEditor()
    ->circleCropper()
    ->maxSize(2048);
```

### Dependent/Conditional Fields

```php
// Show field based on another field's value
Components\Select::make('billing_type')
    ->options([
        'hourly' => 'Hourly',
        'fixed' => 'Fixed Price',
        'retainer' => 'Monthly Retainer',
    ])
    ->live()
    ->required(),

Components\TextInput::make('hourly_rate')
    ->numeric()
    ->prefix('$')
    ->visible(fn (Get $get) => $get('billing_type') === 'hourly'),

Components\TextInput::make('fixed_price')
    ->numeric()
    ->prefix('$')
    ->visible(fn (Get $get) => $get('billing_type') === 'fixed'),

Components\TextInput::make('monthly_retainer')
    ->numeric()
    ->prefix('$')
    ->visible(fn (Get $get) => $get('billing_type') === 'retainer'),
```

### Repeater for Dynamic Items

```php
Components\Repeater::make('line_items')
    ->relationship()
    ->schema([
        Components\TextInput::make('description')
            ->required()
            ->columnSpan(3),

        Components\TextInput::make('quantity')
            ->numeric()
            ->default(1)
            ->required()
            ->columnSpan(1),

        Components\TextInput::make('unit_price_cents')
            ->label('Unit Price')
            ->numeric()
            ->prefix('$')
            ->required()
            ->columnSpan(1)
            ->formatStateUsing(fn (?int $state) => $state ? $state / 100 : null)
            ->dehydrateStateUsing(fn (?float $state) => $state ? (int) ($state * 100) : null),
    ])
    ->columns(5)
    ->defaultItems(1)
    ->addActionLabel('Add Line Item')
    ->reorderableWithButtons()
    ->collapsible()
    ->cloneable()
    ->itemLabel(fn (array $state) => $state['description'] ?? 'New Item'),
```

---

## Table Builder Patterns

### Column Types

```php
use Filament\Tables\Columns;

// Text with formatting
Columns\TextColumn::make('name')
    ->searchable()
    ->sortable()
    ->limit(50)
    ->tooltip(fn (Project $record) => $record->name)
    ->copyable()
    ->copyMessage('Name copied');

// Money formatting
Columns\TextColumn::make('amount_cents')
    ->label('Amount')
    ->money('USD', divideBy: 100)
    ->sortable()
    ->summarize(Sum::make()->money('USD', divideBy: 100));

// Badge with colors
Columns\TextColumn::make('status')
    ->badge()
    ->color(fn (string $state): string => match ($state) {
        'draft' => 'gray',
        'active' => 'success',
        'on_hold' => 'warning',
        'completed' => 'info',
        'cancelled' => 'danger',
    });

// Boolean icons
Columns\IconColumn::make('is_active')
    ->boolean()
    ->trueIcon('heroicon-o-check-circle')
    ->falseIcon('heroicon-o-x-circle')
    ->trueColor('success')
    ->falseColor('danger');

// Image
Columns\ImageColumn::make('avatar')
    ->disk('spaces')
    ->circular()
    ->defaultImageUrl(fn (User $record) => $record->getGravatarUrl());

// Relationship
Columns\TextColumn::make('client.name')
    ->label('Client')
    ->searchable()
    ->sortable()
    ->url(fn (Project $record) => ClientResource::getUrl('view', ['record' => $record->client]));

// Custom view
Columns\ViewColumn::make('progress')
    ->view('filament.tables.columns.progress-bar');
```

### Filter Patterns

```php
use Filament\Tables\Filters;

// Select filter
Filters\SelectFilter::make('status')
    ->options(ProjectStatus::class)
    ->multiple()
    ->preload();

// Date range filter
Filters\Filter::make('created_at')
    ->form([
        Forms\Components\DatePicker::make('from'),
        Forms\Components\DatePicker::make('until'),
    ])
    ->query(function (Builder $query, array $data): Builder {
        return $query
            ->when($data['from'], fn ($q, $date) => $q->whereDate('created_at', '>=', $date))
            ->when($data['until'], fn ($q, $date) => $q->whereDate('created_at', '<=', $date));
    })
    ->indicateUsing(function (array $data): array {
        $indicators = [];
        if ($data['from']) {
            $indicators['from'] = 'From ' . Carbon::parse($data['from'])->format('M j, Y');
        }
        if ($data['until']) {
            $indicators['until'] = 'Until ' . Carbon::parse($data['until'])->format('M j, Y');
        }
        return $indicators;
    });

// Ternary filter
Filters\TernaryFilter::make('is_active')
    ->label('Active')
    ->placeholder('All')
    ->trueLabel('Active Only')
    ->falseLabel('Inactive Only');

// Query scope filter
Filters\Filter::make('overdue')
    ->query(fn (Builder $query) => $query->where('due_date', '<', now())->where('status', '!=', 'completed'))
    ->toggle()
    ->label('Overdue Only');
```

---

## Custom Actions

### Table Row Actions

```php
Tables\Actions\Action::make('send_invoice')
    ->label('Send')
    ->icon('heroicon-o-paper-airplane')
    ->color('primary')
    ->requiresConfirmation()
    ->modalHeading('Send Invoice')
    ->modalDescription('Are you sure you want to send this invoice to the client?')
    ->modalSubmitActionLabel('Send Invoice')
    ->visible(fn (Invoice $record) => $record->canBeSent())
    ->action(function (Invoice $record) {
        $record->send();

        Notification::make()
            ->title('Invoice Sent')
            ->success()
            ->send();
    });

// Action with form
Tables\Actions\Action::make('add_payment')
    ->icon('heroicon-o-credit-card')
    ->form([
        Forms\Components\TextInput::make('amount')
            ->numeric()
            ->prefix('$')
            ->required(),
        Forms\Components\DatePicker::make('payment_date')
            ->default(now())
            ->required(),
        Forms\Components\Select::make('method')
            ->options([
                'stripe' => 'Stripe',
                'bank_transfer' => 'Bank Transfer',
                'check' => 'Check',
            ])
            ->required(),
    ])
    ->action(function (Invoice $record, array $data) {
        $record->recordPayment($data);
    });
```

### Bulk Actions

```php
Tables\Actions\BulkAction::make('export')
    ->label('Export Selected')
    ->icon('heroicon-o-arrow-down-tray')
    ->action(function (Collection $records) {
        return response()->streamDownload(function () use ($records) {
            echo $records->toCsv();
        }, 'projects.csv');
    });

Tables\Actions\BulkAction::make('update_status')
    ->label('Update Status')
    ->icon('heroicon-o-pencil')
    ->form([
        Forms\Components\Select::make('status')
            ->options(ProjectStatus::class)
            ->required(),
    ])
    ->action(function (Collection $records, array $data) {
        $records->each->update(['status' => $data['status']]);

        Notification::make()
            ->title('Status Updated')
            ->body(count($records) . ' projects updated.')
            ->success()
            ->send();
    })
    ->deselectRecordsAfterCompletion();
```

---

## Relation Managers

```php
<?php

declare(strict_types=1);

namespace App\Filament\Resources\ProjectResource\RelationManagers;

use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

final class TasksRelationManager extends RelationManager
{
    protected static string $relationship = 'tasks';

    protected static ?string $recordTitleAttribute = 'title';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\TextInput::make('title')
                ->required()
                ->maxLength(255),

            Forms\Components\Select::make('assignee_id')
                ->relationship('assignee', 'name')
                ->searchable()
                ->preload(),

            Forms\Components\Select::make('status')
                ->options(TaskStatus::class)
                ->required()
                ->default(TaskStatus::Pending),

            Forms\Components\Select::make('priority')
                ->options(TaskPriority::class)
                ->required()
                ->default(TaskPriority::Medium),

            Forms\Components\DatePicker::make('due_date'),

            Forms\Components\Textarea::make('description')
                ->rows(3)
                ->columnSpanFull(),
        ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->searchable()
                    ->limit(40),

                Tables\Columns\TextColumn::make('assignee.name')
                    ->label('Assigned To'),

                Tables\Columns\TextColumn::make('status')
                    ->badge(),

                Tables\Columns\TextColumn::make('priority')
                    ->badge(),

                Tables\Columns\TextColumn::make('due_date')
                    ->date(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(TaskStatus::class),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->reorderable('position')
            ->defaultSort('position');
    }
}
```

---

## Custom Pages

### Dashboard Widgets

```php
<?php

declare(strict_types=1);

namespace App\Filament\Widgets;

use App\Models\Invoice;
use App\Models\Project;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

final class StatsOverview extends StatsOverviewWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        return [
            Stat::make('Active Projects', Project::active()->count())
                ->description('Currently in progress')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success')
                ->chart([7, 3, 4, 5, 6, 3, 5, 8]),

            Stat::make('Outstanding Invoices', Invoice::outstanding()->count())
                ->description(Invoice::outstanding()->sum('total_cents') / 100 . ' total')
                ->descriptionIcon('heroicon-m-currency-dollar')
                ->color('warning'),

            Stat::make('Revenue This Month', '$' . number_format(Invoice::paidThisMonth()->sum('total_cents') / 100, 2))
                ->description('12% increase from last month')
                ->descriptionIcon('heroicon-m-arrow-trending-up')
                ->color('success'),
        ];
    }
}
```

### Chart Widget

```php
<?php

declare(strict_types=1);

namespace App\Filament\Widgets;

use App\Models\Invoice;
use Filament\Widgets\ChartWidget;
use Flowframe\Trend\Trend;
use Flowframe\Trend\TrendValue;

final class RevenueChart extends ChartWidget
{
    protected static ?string $heading = 'Monthly Revenue';

    protected static ?int $sort = 2;

    protected function getData(): array
    {
        $data = Trend::model(Invoice::class)
            ->between(
                start: now()->subMonths(12),
                end: now(),
            )
            ->perMonth()
            ->sum('total_cents');

        return [
            'datasets' => [
                [
                    'label' => 'Revenue',
                    'data' => $data->map(fn (TrendValue $value) => $value->aggregate / 100),
                    'borderColor' => '#10B981',
                    'backgroundColor' => 'rgba(16, 185, 129, 0.1)',
                    'fill' => true,
                ],
            ],
            'labels' => $data->map(fn (TrendValue $value) => Carbon::parse($value->date)->format('M Y')),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
```

### Custom Settings Page

```php
<?php

declare(strict_types=1);

namespace App\Filament\Pages;

use App\Settings\GeneralSettings;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\SettingsPage;

final class ManageGeneralSettings extends SettingsPage
{
    protected static ?string $navigationIcon = 'heroicon-o-cog-6-tooth';

    protected static string $settings = GeneralSettings::class;

    protected static ?string $navigationGroup = 'Settings';

    public function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Company Information')
                ->schema([
                    Forms\Components\TextInput::make('company_name')
                        ->required(),

                    Forms\Components\TextInput::make('company_email')
                        ->email()
                        ->required(),

                    Forms\Components\TextInput::make('company_phone'),

                    Forms\Components\Textarea::make('company_address')
                        ->rows(3),
                ])
                ->columns(2),

            Forms\Components\Section::make('Invoice Settings')
                ->schema([
                    Forms\Components\TextInput::make('invoice_prefix')
                        ->default('INV-'),

                    Forms\Components\TextInput::make('default_payment_terms')
                        ->numeric()
                        ->suffix('days')
                        ->default(30),

                    Forms\Components\Textarea::make('invoice_footer')
                        ->rows(2),
                ]),
        ]);
    }
}
```

---

## Authorization with Filament Shield

```php
// Install: composer require bezhansalleh/filament-shield

// Generate permissions
// php artisan shield:install
// php artisan shield:generate --all

// In Resource
use BezhanSalleh\FilamentShield\Contracts\HasShieldPermissions;

final class ProjectResource extends Resource implements HasShieldPermissions
{
    public static function getPermissionPrefixes(): array
    {
        return [
            'view',
            'view_any',
            'create',
            'update',
            'delete',
            'delete_any',
            'force_delete',
            'force_delete_any',
            'restore',
            'restore_any',
            'replicate',
            'reorder',
        ];
    }
}

// Custom permission check in action
Tables\Actions\Action::make('approve')
    ->visible(fn () => auth()->user()->can('approve_projects'));
```

---

## Testing Filament

### Resource Tests

```php
use App\Filament\Resources\ProjectResource;
use App\Filament\Resources\ProjectResource\Pages\CreateProject;
use App\Filament\Resources\ProjectResource\Pages\EditProject;
use App\Filament\Resources\ProjectResource\Pages\ListProjects;
use App\Models\Project;
use App\Models\User;
use Filament\Actions\DeleteAction;

beforeEach(function () {
    $this->actingAs(User::factory()->admin()->create());
});

test('can render list page', function () {
    $this->get(ProjectResource::getUrl('index'))->assertSuccessful();
});

test('can list projects', function () {
    $projects = Project::factory(10)->create();

    Livewire::test(ListProjects::class)
        ->assertCanSeeTableRecords($projects);
});

test('can create project', function () {
    $client = Client::factory()->create();

    Livewire::test(CreateProject::class)
        ->fillForm([
            'name' => 'Test Project',
            'client_id' => $client->id,
            'status' => 'draft',
        ])
        ->call('create')
        ->assertHasNoFormErrors();

    expect(Project::where('name', 'Test Project')->exists())->toBeTrue();
});

test('can validate required fields', function () {
    Livewire::test(CreateProject::class)
        ->fillForm([
            'name' => '',
        ])
        ->call('create')
        ->assertHasFormErrors(['name' => 'required']);
});

test('can edit project', function () {
    $project = Project::factory()->create();

    Livewire::test(EditProject::class, ['record' => $project->id])
        ->fillForm([
            'name' => 'Updated Name',
        ])
        ->call('save')
        ->assertHasNoFormErrors();

    expect($project->fresh()->name)->toBe('Updated Name');
});

test('can delete project', function () {
    $project = Project::factory()->create();

    Livewire::test(EditProject::class, ['record' => $project->id])
        ->callAction(DeleteAction::class);

    expect(Project::find($project->id))->toBeNull();
});

test('can filter by status', function () {
    $active = Project::factory()->active()->create();
    $completed = Project::factory()->completed()->create();

    Livewire::test(ListProjects::class)
        ->filterTable('status', 'active')
        ->assertCanSeeTableRecords([$active])
        ->assertCanNotSeeTableRecords([$completed]);
});

test('can search projects', function () {
    $matching = Project::factory()->create(['name' => 'Alpha Project']);
    $notMatching = Project::factory()->create(['name' => 'Beta Project']);

    Livewire::test(ListProjects::class)
        ->searchTable('Alpha')
        ->assertCanSeeTableRecords([$matching])
        ->assertCanNotSeeTableRecords([$notMatching]);
});
```

---

## Performance Tips

### Eager Loading in Tables

```php
public static function getEloquentQuery(): Builder
{
    return parent::getEloquentQuery()
        ->with(['client', 'tasks'])
        ->withCount('tasks');
}
```

### Defer Expensive Widgets

```php
protected static bool $isLazy = true;

public function placeholder(): View
{
    return view('filament.widgets.loading-placeholder');
}
```

### Optimize Select Queries

```php
Forms\Components\Select::make('client_id')
    ->relationship('client', 'name')
    ->getOptionLabelFromRecordUsing(fn (Client $record) => $record->name)
    ->searchable(['name', 'email'])  // Limit search columns
    ->preload()  // Preload options
    ->optionsLimit(50);  // Limit dropdown size
```

---

## Related Documentation

- [Livewire Conventions](./livewire-conventions.md) - Livewire patterns
- [ADR-0010: Admin Panel](../03-decisions/adr-0010-admin-panel.md) - Why Filament
- [Testing Strategy](../06-testing/testing-strategy.md) - Test organization
- [Authorization Guide](./auth-guide.md) - Permissions and policies

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-30 | 1.0.0 | Claude | Initial Filament 3 conventions |
