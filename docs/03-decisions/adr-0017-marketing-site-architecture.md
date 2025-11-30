---
id: "ADR-0017"
title: "Marketing Site Architecture"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-MKTG-001, REQ-MKTG-002, REQ-MKTG-003, REQ-MKTG-004, REQ-MKTG-007, REQ-MKTG-008, REQ-MKTG-009"
decision_makers: "Platform Team"
consulted: "Marketing, Design Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0017: Marketing Site Architecture

## Context and Problem Statement

The agency requires a public marketing site with:
- [REQ-MKTG-001](../01-requirements/req-mktg-001.md): Public Homepage
- [REQ-MKTG-002](../01-requirements/req-mktg-002.md): Services Pages
- [REQ-MKTG-003](../01-requirements/req-mktg-003.md): Portfolio/Case Studies
- [REQ-MKTG-004](../01-requirements/req-mktg-004.md): Contact Form
- [REQ-MKTG-007](../01-requirements/req-mktg-007.md): Testimonials Display
- [REQ-MKTG-008](../01-requirements/req-mktg-008.md): Pricing Page
- [REQ-MKTG-009](../01-requirements/req-mktg-009.md): Team Page

The marketing site is the public face of the agency and must be fast, SEO-optimized, and easy for non-technical staff to update.

## Decision Drivers

- **Performance:** Marketing pages must load fast (< 2 seconds)
- **SEO:** Full control over metadata, structured data, URLs
- **Content Management:** Non-technical staff can update pages
- **Design Flexibility:** Support custom layouts per page type
- **Integration:** Share authentication with main application
- **Cost:** Minimize additional infrastructure

## Considered Options

1. **Option A:** Statamic integrated with Laravel app (same codebase)
2. **Option B:** Separate static site (Next.js/Gatsby) with headless CMS
3. **Option C:** WordPress as marketing site
4. **Option D:** Laravel Blade templates (no CMS)
5. **Option E:** Statamic as separate installation

## Decision Outcome

**Chosen Option:** Option A - Statamic integrated with Laravel app

**Justification:** Building on ADR-0003 (CMS decision), the marketing site will be built using Statamic within the same Laravel application:
- Single deployment and codebase
- Shared authentication and user management
- Static caching for near-static performance
- Full SEO control via Statamic's SEO Pro addon
- Content editors use same admin as other content

### Consequences

#### Positive

- Single codebase reduces complexity
- Statamic's static caching delivers sub-second load times
- SEO-friendly URLs and metadata management built-in
- Page builder (Bard) enables custom layouts
- Can reuse Blade components across app
- No additional hosting costs

#### Negative

- Marketing site coupled to application deployments
- Statamic learning curve for marketers
- Less separation between marketing and app concerns
- Page builder less flexible than dedicated landing page tools

#### Risks

- **Risk:** Application issues affect marketing site
  - **Mitigation:** Implement static caching; marketing pages are pre-rendered
- **Risk:** Marketing team blocked by developers
  - **Mitigation:** Train team on Statamic; create reusable page blocks
- **Risk:** Performance degradation with complex pages
  - **Mitigation:** Use Statamic's half-measure static caching; optimize images

## Validation

- **Metric 1:** Homepage loads in under 2 seconds (Lighthouse)
- **Metric 2:** All pages score 90+ on Lighthouse Performance
- **Metric 3:** Marketing team can publish new page in under 30 minutes
- **Metric 4:** SEO score 90+ on technical SEO audit

## Pros and Cons of the Options

### Option A: Statamic Integrated

**Pros:**
- Single codebase
- Static caching for performance
- Full SEO control
- Shared components

**Cons:**
- Coupled deployments
- CMS learning curve

### Option B: Separate Static Site

**Pros:**
- Maximum performance (JAMstack)
- Independent deployments
- Modern tooling

**Cons:**
- Two codebases to maintain
- Separate hosting
- API integration needed
- More complex architecture

### Option C: WordPress

**Pros:**
- Familiar to marketers
- Huge plugin ecosystem
- Easy content editing

**Cons:**
- Security concerns
- Performance issues
- PHP version conflicts
- Separate system to maintain

### Option D: Laravel Blade Only

**Pros:**
- Simple implementation
- Maximum control

**Cons:**
- Developers required for all changes
- No content management
- Not scalable for marketing needs

### Option E: Separate Statamic

**Pros:**
- Independent from app
- Clean separation

**Cons:**
- Two Statamic installations
- Duplicate infrastructure
- No shared components

## Implementation Notes

### Site Structure

```
Marketing Site (Statamic Collections)
├── pages/                    # Static pages
│   ├── home.md              # Homepage
│   ├── about.md             # About page
│   ├── pricing.md           # Pricing page
│   └── contact.md           # Contact page
├── services/                 # Services collection
│   ├── web-development.md
│   ├── design.md
│   └── consulting.md
├── portfolio/                # Case studies collection
│   ├── project-alpha.md
│   └── project-beta.md
├── team/                     # Team members collection
│   ├── john-doe.md
│   └── jane-smith.md
└── testimonials/             # Testimonials collection
    ├── client-a.md
    └── client-b.md
```

### Page Blueprints

```yaml
# resources/blueprints/collections/pages/page.yaml
title: Page
sections:
  main:
    fields:
      - handle: hero_title
        field:
          type: text
          display: Hero Title
      - handle: hero_subtitle
        field:
          type: textarea
          display: Hero Subtitle
      - handle: content
        field:
          type: bard
          display: Content
          sets:
            - cta_block
            - feature_grid
            - testimonial_slider
  seo:
    fields:
      - handle: seo_title
        field: { type: text }
      - handle: seo_description
        field: { type: textarea }
      - handle: og_image
        field: { type: assets, max_files: 1 }
```

### Static Caching Configuration

```php
// config/statamic/static_caching.php
return [
    'strategy' => 'half',  // or 'full' for completely static
    'expiry' => 3600,      // 1 hour cache
    'exclude' => [
        '/contact*',       // Forms need dynamic handling
        '/app/*',          // Application routes
    ],
    'invalidation' => [
        'rules' => [
            'collections' => [
                'pages' => ['urls' => ['/*']],
                'services' => ['urls' => ['/services/*', '/']],
            ],
        ],
    ],
];
```

### Contact Form Implementation

```php
// Using Statamic Forms
// resources/blueprints/forms/contact.yaml
title: Contact Form
fields:
  - handle: name
    field: { type: text, validate: required }
  - handle: email
    field: { type: text, validate: [required, email] }
  - handle: company
    field: { type: text }
  - handle: message
    field: { type: textarea, validate: required }

// Form submission handling
// app/Listeners/ContactFormSubmission.php
class ContactFormSubmission
{
    public function handle(FormSubmitted $event)
    {
        if ($event->submission->form()->handle() === 'contact') {
            // Send notification email
            // Create lead in CRM
            // Trigger ConvertKit automation
        }
    }
}
```

### SEO Configuration

```php
// Install SEO Pro: composer require statamic/seo-pro

// config/statamic/seo-pro.php
return [
    'site_name' => 'Agency Name',
    'site_name_position' => 'after',
    'site_name_separator' => '|',
    'defaults' => [
        'title' => '@seo_title ?? title',
        'description' => '@seo_description',
        'og_image' => '@og_image',
    ],
];
```

### Responsive Images

```blade
{{-- Using Statamic's Glide for image optimization --}}
<picture>
    <source
        media="(min-width: 1024px)"
        srcset="{{ $image->url }}?w=1200&format=webp 1x,
                {{ $image->url }}?w=2400&format=webp 2x"
        type="image/webp">
    <source
        media="(min-width: 640px)"
        srcset="{{ $image->url }}?w=800&format=webp"
        type="image/webp">
    <img
        src="{{ $image->url }}?w=400"
        alt="{{ $image->alt }}"
        loading="lazy">
</picture>
```

## Links

- [REQ-MKTG-001](../01-requirements/req-mktg-001.md) - Public Homepage
- [REQ-MKTG-002](../01-requirements/req-mktg-002.md) - Services Pages
- [REQ-MKTG-003](../01-requirements/req-mktg-003.md) - Portfolio/Case Studies
- [REQ-MKTG-004](../01-requirements/req-mktg-004.md) - Contact Form
- [REQ-MKTG-007](../01-requirements/req-mktg-007.md) - Testimonials Display
- [REQ-MKTG-008](../01-requirements/req-mktg-008.md) - Pricing Page
- [REQ-MKTG-009](../01-requirements/req-mktg-009.md) - Team Page
- [ADR-0003](./adr-0003-cms-approach.md) - CMS Approach (Statamic)
- [ADR-0007](./adr-0007-email-marketing.md) - Email Marketing (ConvertKit)
- [Statamic Documentation](https://statamic.dev)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
