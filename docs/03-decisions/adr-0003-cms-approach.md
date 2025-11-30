---
id: "ADR-0003"
title: "CMS Approach Selection"
status: "accepted"
date: "2025-11-29"
implements_requirement: "REQ-CMS-001, REQ-CMS-008"
decision_makers: "Platform Team"
consulted: "Marketing, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0003: CMS Approach Selection

## Context and Problem Statement

[REQ-CMS-001](../01-requirements/req-cms-001.md) requires blog post management with creation, editing, publishing, and archiving. [REQ-CMS-008](../01-requirements/req-cms-008.md) requires static page management for landing pages and content pages.

The marketing site needs a content management system for the blog, services pages, portfolio, and other dynamic content. The CMS must support rich text editing, media management, SEO metadata, and scheduled publishing.

## Decision Drivers

- **Developer Experience:** Laravel-native solution preferred
- **Content Editing:** Non-technical staff must be able to edit content
- **SEO:** Full control over metadata, URLs, and structured data
- **Performance:** Static-like performance for public pages
- **Media Management:** Image uploads, optimization, and organization
- **Flexibility:** Support custom content types beyond blog posts

## Considered Options

1. **Option A:** Build custom CMS in Laravel
2. **Option B:** Integrate WordPress (headless via REST API)
3. **Option C:** Use Statamic (Laravel-based CMS)
4. **Option D:** Use Filament + custom models
5. **Option E:** Integrate Contentful (headless CMS)

## Decision Outcome

**Chosen Option:** Option C - Statamic

**Justification:** Statamic is a Laravel-native CMS that provides:
- Full Laravel integration (same codebase, same deployment)
- Flat-file or database storage options
- Built-in rich text editor (Bard) with block-based editing
- Asset management with image transformations
- SEO addon ecosystem
- Multi-user with granular permissions
- Git-based content versioning (flat-file mode)

As a Laravel package, Statamic integrates seamlessly with the existing platform while providing a polished content editing experience out of the box.

### Consequences

#### Positive

- Laravel-native: uses Blade templates, Eloquent optional, same deployment
- Excellent editor experience with live preview
- Built-in asset pipeline with image transformations
- Fieldtype system for custom content structures
- Active community and addon ecosystem
- One-time license cost ($259/site) vs recurring SaaS fees

#### Negative

- Learning curve for Statamic-specific concepts (collections, blueprints)
- Some features require Pro license
- Less conventional than standard Laravel models/controllers
- Smaller ecosystem than WordPress

#### Risks

- **Risk:** Content structure changes require developer involvement
  - **Mitigation:** Design flexible blueprints upfront; train content team on structure
- **Risk:** Performance at scale with flat-file storage
  - **Mitigation:** Use database driver for high-traffic sites; implement caching
- **Risk:** Team unfamiliarity with Statamic
  - **Mitigation:** Allocate training time; Statamic docs are excellent

## Validation

- **Metric 1:** Content editor can publish blog post in under 5 minutes
- **Metric 2:** Page load time under 500ms with caching enabled
- **Metric 3:** All pages score 90+ on Lighthouse SEO audit
- **Metric 4:** Media uploads processed (resized, optimized) in under 10 seconds

## Pros and Cons of the Options

### Option A: Build Custom CMS

**Pros:**
- Full control over every feature
- No license costs
- Exactly what's needed, nothing more

**Cons:**
- Significant development time (8-12 weeks for full CMS)
- Must build rich text editor integration
- Must build media management
- Ongoing maintenance burden

### Option B: WordPress (Headless)

**Pros:**
- Mature, well-known platform
- Huge plugin ecosystem
- Content editors likely familiar
- Free/open source

**Cons:**
- Separate deployment and infrastructure
- PHP version/security management
- REST API adds latency
- Two systems to maintain
- Security concerns (WordPress is highly targeted)

### Option C: Statamic

**Pros:**
- Laravel-native (same codebase)
- Excellent editing experience
- Flexible content modeling
- One-time license cost
- Active development

**Cons:**
- License cost ($259 one-time)
- Learning curve
- Smaller ecosystem than WordPress

### Option D: Filament + Custom Models

**Pros:**
- Beautiful admin panel
- Full Laravel integration
- Free/open source
- Maximum flexibility

**Cons:**
- Must build content modeling from scratch
- No built-in rich text editor (needs integration)
- No asset management (must build or integrate)
- More assembly required than Statamic

### Option E: Contentful (Headless)

**Pros:**
- Powerful content modeling
- CDN-backed API
- Multi-language support
- Enterprise features

**Cons:**
- Expensive ($489+/month for team use)
- External API dependency
- Vendor lock-in
- Overkill for agency blog/pages

## Implementation Notes

- Install Statamic as Laravel package: `composer require statamic/cms`
- Use database driver for production (better for multi-server)
- Create collections: `blog`, `pages`, `services`, `portfolio`
- Configure blueprints with SEO fields (title, description, OG image)
- Install `statamic/seo-pro` addon for advanced SEO
- Use Statamic's asset containers for media organization
- Implement static caching for public pages (near-static performance)
- Create custom fieldtypes if needed for agency-specific content

## Links

- [REQ-CMS-001](../01-requirements/req-cms-001.md) - Blog Post Management
- [REQ-CMS-008](../01-requirements/req-cms-008.md) - Static Page Management
- [REQ-CMS-002](../01-requirements/req-cms-002.md) - Rich Text Editor
- [REQ-CMS-003](../01-requirements/req-cms-003.md) - Media Library
- [REQ-CMS-004](../01-requirements/req-cms-004.md) - SEO Metadata Management
- [Statamic Documentation](https://statamic.dev)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
