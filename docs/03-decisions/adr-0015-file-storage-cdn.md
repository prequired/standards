---
id: "ADR-0015"
title: "File Storage & CDN Strategy"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-INTG-003, REQ-PERF-004"
decision_makers: "Platform Team"
consulted: "Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0015: File Storage & CDN Strategy

## Context and Problem Statement

[REQ-INTG-003](../01-requirements/req-intg-003.md) requires cloud storage (S3-compatible) for file uploads. [REQ-PERF-004](../01-requirements/req-perf-004.md) requires CDN for static assets to improve page load performance.

The platform handles various files:
- Project deliverables (designs, documents, code)
- Client uploads (briefs, assets)
- Invoice PDFs
- Profile images and media library
- Static assets (CSS, JS, images)

## Decision Drivers

- **Scalability:** Handle growing file storage without server constraints
- **Performance:** Fast file delivery globally
- **Security:** Private files accessible only to authorized users
- **Cost:** Reasonable storage and bandwidth costs
- **Laravel Integration:** Native filesystem driver support
- **Infrastructure Alignment:** Consistent with ADR-0011 (DigitalOcean)

## Considered Options

1. **Option A:** AWS S3 + CloudFront
2. **Option B:** DigitalOcean Spaces + CDN
3. **Option C:** Cloudflare R2 + Cloudflare CDN
4. **Option D:** Backblaze B2 + Cloudflare
5. **Option E:** Local storage with rsync backup

## Decision Outcome

**Chosen Option:** Option B - DigitalOcean Spaces + Built-in CDN

**Justification:** Since infrastructure is on DigitalOcean (ADR-0011), Spaces provides:
- S3-compatible API (Laravel works out of the box)
- Built-in CDN with edge caching
- Predictable pricing ($5/month for 250GB + $0.02/GB transfer)
- Same dashboard as servers
- No additional vendor to manage

### Consequences

#### Positive

- Single vendor for infrastructure (DigitalOcean)
- S3-compatible means standard Laravel filesystem driver
- Built-in CDN included in Spaces pricing
- Simple configuration and management
- Predictable costs

#### Negative

- Less feature-rich than AWS S3
- Fewer regions than AWS/Cloudflare
- CDN less configurable than CloudFront
- No Lambda@Edge equivalent for edge functions

#### Risks

- **Risk:** Spaces outage affects file access
  - **Mitigation:** Critical files also stored in database or backup location
- **Risk:** CDN cache invalidation delays
  - **Mitigation:** Use versioned filenames or cache-busting query strings
- **Risk:** Bandwidth costs spike with large files
  - **Mitigation:** Monitor usage; set budget alerts; consider video/large file alternatives

## Validation

- **Metric 1:** File upload completes within 10 seconds for files under 50MB
- **Metric 2:** CDN cache hit ratio >90% for static assets
- **Metric 3:** Global file delivery under 500ms (p95)
- **Metric 4:** Monthly storage costs under $50 at launch scale

## Pros and Cons of the Options

### Option A: AWS S3 + CloudFront

**Pros:**
- Industry standard
- Most feature-rich
- Global edge locations
- Lambda@Edge for dynamic processing

**Cons:**
- Complex pricing
- Adds AWS to vendor mix
- More configuration required

### Option B: DigitalOcean Spaces + CDN

**Pros:**
- S3-compatible
- Simple pricing
- CDN included
- Same vendor as hosting
- Laravel native support

**Cons:**
- Fewer features
- Less global presence
- Basic CDN options

### Option C: Cloudflare R2 + CDN

**Pros:**
- Zero egress fees
- Cloudflare's global network
- S3-compatible

**Cons:**
- Newer service
- Adds Cloudflare to stack
- Less Laravel-specific tooling

### Option D: Backblaze B2 + Cloudflare

**Pros:**
- Very low storage costs
- Zero egress via Cloudflare
- Good for large files

**Cons:**
- Two services to manage
- Less integrated experience
- Smaller ecosystem

### Option E: Local Storage

**Pros:**
- No external dependency
- No bandwidth costs
- Simple implementation

**Cons:**
- Server disk limits
- No CDN benefit
- Scaling requires migration
- Backup complexity

## Implementation Notes

### Filesystem Configuration

```php
// config/filesystems.php
'disks' => [
    'spaces' => [
        'driver' => 's3',
        'key' => env('DO_SPACES_KEY'),
        'secret' => env('DO_SPACES_SECRET'),
        'region' => env('DO_SPACES_REGION', 'nyc3'),
        'bucket' => env('DO_SPACES_BUCKET'),
        'endpoint' => env('DO_SPACES_ENDPOINT'),
        'url' => env('DO_SPACES_CDN_URL'), // CDN URL
        'visibility' => 'private',
    ],
],

// .env
DO_SPACES_KEY=xxx
DO_SPACES_SECRET=xxx
DO_SPACES_REGION=nyc3
DO_SPACES_BUCKET=agency-files
DO_SPACES_ENDPOINT=https://nyc3.digitaloceanspaces.com
DO_SPACES_CDN_URL=https://agency-files.nyc3.cdn.digitaloceanspaces.com
```

### File Organization

```
agency-files (Spaces Bucket)
├── projects/
│   ├── {project_id}/
│   │   ├── deliverables/
│   │   ├── uploads/
│   │   └── attachments/
├── invoices/
│   └── {invoice_id}.pdf
├── media/
│   ├── images/
│   └── documents/
├── avatars/
│   └── {user_id}.jpg
└── backups/
    └── {date}/
```

### Upload Handling

```php
// File upload with private visibility
public function uploadDeliverable(Request $request, Project $project)
{
    $path = $request->file('file')->store(
        "projects/{$project->id}/deliverables",
        'spaces'
    );

    return Deliverable::create([
        'project_id' => $project->id,
        'path' => $path,
        'filename' => $request->file('file')->getClientOriginalName(),
        'size' => $request->file('file')->getSize(),
    ]);
}
```

### Secure File Access (Signed URLs)

```php
// Generate temporary signed URL for private files
public function download(Deliverable $deliverable)
{
    $this->authorize('view', $deliverable->project);

    $url = Storage::disk('spaces')->temporaryUrl(
        $deliverable->path,
        now()->addMinutes(60)
    );

    return redirect($url);
}
```

### Public Assets (CDN)

```php
// For public assets like media library images
// Use public visibility and CDN URL
Storage::disk('spaces')->setVisibility($path, 'public');
$cdnUrl = Storage::disk('spaces')->url($path);

// In Blade templates
<img src="{{ Storage::disk('spaces')->url($image->path) }}" alt="">
```

### Static Assets (Vite + CDN)

```js
// vite.config.js - for production static assets
export default defineConfig({
    build: {
        manifest: true,
        outDir: 'public/build',
    },
});

// Can also upload build assets to Spaces for CDN delivery
// Or use DigitalOcean's App Platform static site feature
```

### Image Optimization

```php
// Using Spatie Laravel-MediaLibrary for image processing
// Generates responsive images, stores in Spaces

use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;

class Project extends Model implements HasMedia
{
    use InteractsWithMedia;

    public function registerMediaConversions(Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(200)
            ->height(200);

        $this->addMediaConversion('preview')
            ->width(800);
    }
}
```

## Links

- [REQ-INTG-003](../01-requirements/req-intg-003.md) - Cloud Storage (S3)
- [REQ-PERF-004](../01-requirements/req-perf-004.md) - CDN for Static Assets
- [REQ-PROJ-007](../01-requirements/req-proj-007.md) - File Attachments per Project
- [REQ-SEC-008](../01-requirements/req-sec-008.md) - Secure File Access
- [ADR-0011](./adr-0011-infrastructure-hosting.md) - Infrastructure (DigitalOcean)
- [ADR-0012](./adr-0012-security-data-protection.md) - Security (signed URLs)
- [Laravel Filesystem Documentation](https://laravel.com/docs/filesystem)
- [DigitalOcean Spaces Documentation](https://docs.digitalocean.com/products/spaces/)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
