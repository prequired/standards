---
id: "ADR-0019"
title: "Notification System Architecture"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-COMM-001, REQ-COMM-003, REQ-COMM-005, REQ-COMM-006"
decision_makers: "Platform Team"
consulted: "Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0019: Notification System Architecture

## Context and Problem Statement

The platform needs a comprehensive notification system:
- [REQ-COMM-001](../01-requirements/req-comm-001.md): In-App Notifications
- [REQ-COMM-003](../01-requirements/req-comm-003.md): Project Comments/Feedback
- [REQ-COMM-005](../01-requirements/req-comm-005.md): @Mentions in Comments
- [REQ-COMM-006](../01-requirements/req-comm-006.md): Notification Preferences

Users need to be notified of important events through multiple channels (in-app, email, optionally push/SMS) with the ability to control their notification preferences.

## Decision Drivers

- **Multi-channel:** Support in-app, email, and future channels
- **Real-time:** In-app notifications appear instantly
- **Preferences:** Users control what notifications they receive
- **Scalability:** Handle high notification volume
- **Laravel Native:** Use Laravel's notification system
- **Persistence:** Store notifications for later viewing

## Considered Options

1. **Option A:** Laravel Notifications + Database + Broadcasting
2. **Option B:** Third-party service (OneSignal, Pusher Beams)
3. **Option C:** Custom notification system
4. **Option D:** Laravel Notifications + Redis
5. **Option E:** Event-driven with separate notification microservice

## Decision Outcome

**Chosen Option:** Option A - Laravel Notifications + Database + Broadcasting

**Justification:** Laravel's built-in notification system provides:
- Multi-channel support (mail, database, broadcast, SMS, Slack)
- Database storage for notification history
- Broadcasting via Pusher/Echo for real-time (ADR-0004)
- Notification preferences via user model
- Queueable notifications for performance
- Clean, maintainable code structure

### Consequences

#### Positive

- Laravel-native solution with excellent documentation
- Reuse Pusher setup from ADR-0004 (Messaging)
- Database notifications persist for user to view later
- Easy to add new channels (Slack, SMS) later
- Preferences can be stored per user
- Queueing prevents performance issues

#### Negative

- Database notifications table can grow large
- Must build notification preferences UI
- Real-time requires Pusher/WebSocket setup
- @mentions parsing must be custom built

#### Risks

- **Risk:** Notification flooding annoys users
  - **Mitigation:** Smart batching; respect user preferences; add frequency limits
- **Risk:** Database table grows too large
  - **Mitigation:** Archive/delete old notifications; implement retention policy
- **Risk:** Real-time notifications fail silently
  - **Mitigation:** Always store in database; broadcast is enhancement

## Validation

- **Metric 1:** In-app notification appears within 2 seconds of event
- **Metric 2:** Email notification sent within 5 minutes
- **Metric 3:** Users can configure preferences in under 1 minute
- **Metric 4:** Zero missed critical notifications

## Pros and Cons of the Options

### Option A: Laravel Notifications + Database + Broadcasting

**Pros:**
- Laravel-native
- Multi-channel built-in
- Database persistence
- Real-time via Echo

**Cons:**
- Database growth
- Custom preferences UI needed

### Option B: Third-Party Service

**Pros:**
- Push notifications built-in
- Mobile SDKs
- Analytics

**Cons:**
- Additional cost
- Vendor dependency
- Integration complexity

### Option C: Custom System

**Pros:**
- Maximum flexibility
- Exact requirements match

**Cons:**
- Significant development effort
- Reinventing the wheel
- Maintenance burden

### Option D: Redis-based

**Pros:**
- Fast
- Scalable

**Cons:**
- No persistence
- Complex setup

### Option E: Microservice

**Pros:**
- Scalable independently
- Language agnostic

**Cons:**
- Over-engineering for this scale
- Deployment complexity

## Implementation Notes

### Notification Types

```php
// app/Notifications/ProjectUpdated.php
class ProjectUpdated extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(
        public Project $project,
        public string $updateType,
        public ?User $actor = null
    ) {}

    public function via(object $notifiable): array
    {
        return $notifiable->notificationChannels('project_updates');
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject("Project Update: {$this->project->name}")
            ->line("{$this->actor->name} updated the project.")
            ->action('View Project', route('projects.show', $this->project));
    }

    public function toDatabase(object $notifiable): array
    {
        return [
            'type' => 'project_updated',
            'project_id' => $this->project->id,
            'project_name' => $this->project->name,
            'update_type' => $this->updateType,
            'actor_id' => $this->actor?->id,
            'actor_name' => $this->actor?->name,
        ];
    }

    public function toBroadcast(object $notifiable): BroadcastMessage
    {
        return new BroadcastMessage([
            'id' => $this->id,
            'type' => 'project_updated',
            'data' => $this->toDatabase($notifiable),
            'read_at' => null,
            'created_at' => now(),
        ]);
    }
}
```

### Notification Preferences

```php
// database/migrations - notification_preferences table
Schema::create('notification_preferences', function (Blueprint $table) {
    $table->id();
    $table->morphs('notifiable');
    $table->string('notification_type');
    $table->json('channels')->default('["database", "mail"]');
    $table->boolean('enabled')->default(true);
    $table->timestamps();
});

// app/Models/User.php
trait HasNotificationPreferences
{
    public function notificationPreferences(): HasMany
    {
        return $this->hasMany(NotificationPreference::class);
    }

    public function notificationChannels(string $type): array
    {
        $pref = $this->notificationPreferences()
            ->where('notification_type', $type)
            ->first();

        if (!$pref || !$pref->enabled) {
            return ['database']; // Always store, even if disabled
        }

        return $pref->channels;
    }

    public function wantsNotification(string $type): bool
    {
        $pref = $this->notificationPreferences()
            ->where('notification_type', $type)
            ->first();

        return $pref?->enabled ?? true;
    }
}
```

### Comment System with @Mentions

```php
// app/Services/MentionParser.php
class MentionParser
{
    public function parse(string $content): ParsedContent
    {
        $mentions = [];

        // Match @username pattern
        $parsed = preg_replace_callback(
            '/@(\w+)/',
            function ($matches) use (&$mentions) {
                $user = User::where('username', $matches[1])->first();
                if ($user) {
                    $mentions[] = $user;
                    return "<mention user-id=\"{$user->id}\">@{$user->name}</mention>";
                }
                return $matches[0];
            },
            $content
        );

        return new ParsedContent($parsed, $mentions);
    }
}

// app/Models/Comment.php
class Comment extends Model
{
    protected static function booted()
    {
        static::created(function (Comment $comment) {
            // Parse mentions and notify
            $parsed = app(MentionParser::class)->parse($comment->body);

            foreach ($parsed->mentions as $user) {
                $user->notify(new MentionedInComment($comment));
            }

            // Notify other project watchers
            $comment->project->watchers
                ->except($parsed->mentions->pluck('id'))
                ->except($comment->user_id)
                ->each->notify(new NewProjectComment($comment));
        });
    }
}
```

### Real-time Notifications (Livewire)

```php
// app/Livewire/NotificationBell.php
class NotificationBell extends Component
{
    public int $unreadCount = 0;

    protected $listeners = [
        'echo-private:App.Models.User.{userId},notification' => 'handleNewNotification',
    ];

    public function mount()
    {
        $this->unreadCount = auth()->user()->unreadNotifications()->count();
    }

    public function handleNewNotification($notification)
    {
        $this->unreadCount++;
        $this->dispatch('notification-received', $notification);
    }

    public function markAsRead($notificationId)
    {
        auth()->user()->notifications()->find($notificationId)?->markAsRead();
        $this->unreadCount = max(0, $this->unreadCount - 1);
    }

    public function markAllAsRead()
    {
        auth()->user()->unreadNotifications->markAsRead();
        $this->unreadCount = 0;
    }

    public function render()
    {
        return view('livewire.notification-bell', [
            'notifications' => auth()->user()
                ->notifications()
                ->latest()
                ->take(10)
                ->get(),
        ]);
    }

    public function getUserIdProperty()
    {
        return auth()->id();
    }
}
```

### Notification Preferences UI

```php
// app/Livewire/NotificationSettings.php
class NotificationSettings extends Component
{
    public array $preferences = [];

    protected array $notificationTypes = [
        'project_updates' => 'Project Updates',
        'task_assigned' => 'Task Assignments',
        'comment_replies' => 'Comment Replies',
        'mentions' => 'Mentions',
        'invoice_sent' => 'Invoice Notifications',
        'payment_received' => 'Payment Confirmations',
        'message_received' => 'New Messages',
    ];

    protected array $channels = [
        'database' => 'In-App',
        'mail' => 'Email',
        'broadcast' => 'Real-time',
    ];

    public function mount()
    {
        $user = auth()->user();

        foreach ($this->notificationTypes as $type => $label) {
            $pref = $user->notificationPreferences()
                ->where('notification_type', $type)
                ->first();

            $this->preferences[$type] = [
                'enabled' => $pref?->enabled ?? true,
                'channels' => $pref?->channels ?? ['database', 'mail'],
            ];
        }
    }

    public function save()
    {
        $user = auth()->user();

        foreach ($this->preferences as $type => $settings) {
            $user->notificationPreferences()->updateOrCreate(
                ['notification_type' => $type],
                [
                    'enabled' => $settings['enabled'],
                    'channels' => $settings['channels'],
                ]
            );
        }

        $this->dispatch('saved');
    }

    public function render()
    {
        return view('livewire.notification-settings', [
            'notificationTypes' => $this->notificationTypes,
            'channels' => $this->channels,
        ]);
    }
}
```

### Notification Batching

```php
// app/Notifications/DigestNotification.php
class DigestNotification extends Notification
{
    public function __construct(
        public Collection $activities,
        public string $period = 'daily'
    ) {}

    public function via($notifiable): array
    {
        return ['mail'];
    }

    public function toMail($notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject("Your {$this->period} digest")
            ->markdown('emails.digest', [
                'activities' => $this->activities,
                'user' => $notifiable,
            ]);
    }
}

// Scheduled command for digest
// app/Console/Commands/SendDigestNotifications.php
class SendDigestNotifications extends Command
{
    public function handle()
    {
        User::where('digest_preference', 'daily')
            ->each(function ($user) {
                $activities = Activity::forUser($user)
                    ->since(now()->subDay())
                    ->get();

                if ($activities->isNotEmpty()) {
                    $user->notify(new DigestNotification($activities, 'daily'));
                }
            });
    }
}
```

## Links

- [REQ-COMM-001](../01-requirements/req-comm-001.md) - In-App Notifications
- [REQ-COMM-003](../01-requirements/req-comm-003.md) - Project Comments/Feedback
- [REQ-COMM-005](../01-requirements/req-comm-005.md) - @Mentions in Comments
- [REQ-COMM-006](../01-requirements/req-comm-006.md) - Notification Preferences
- [ADR-0004](./adr-0004-messaging-chat.md) - Messaging (Pusher/Echo setup)
- [ADR-0008](./adr-0008-transactional-email.md) - Email delivery (Postmark)
- [Laravel Notifications Documentation](https://laravel.com/docs/notifications)
- [Laravel Echo Documentation](https://laravel.com/docs/broadcasting)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
