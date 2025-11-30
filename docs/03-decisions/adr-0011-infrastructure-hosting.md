---
id: "ADR-0011"
title: "Infrastructure & Hosting Strategy"
status: "proposed"
date: 2025-11-29
implements_requirement: "REQ-PERF-003, REQ-PERF-007, REQ-PERF-008"
decision_makers: "Platform Team"
consulted: "DevOps, Development Team"
informed: "All stakeholders"
supersedes: ""
superseded_by: ""
---

# ADR-0011: Infrastructure & Hosting Strategy

## Context and Problem Statement

[REQ-PERF-003](../01-requirements/req-perf-003.md) requires 99.9% uptime. [REQ-PERF-007](../01-requirements/req-perf-007.md) requires auto-scaling infrastructure. [REQ-PERF-008](../01-requirements/req-perf-008.md) requires comprehensive monitoring and alerting.

The platform needs a hosting strategy that balances reliability, scalability, cost, and operational complexity. As an agency platform, it must handle variable loads (client logins, report generation) while maintaining consistent performance.

## Decision Drivers

- **Reliability:** 99.9% uptime requirement (8.76 hours downtime/year max)
- **Scalability:** Handle traffic spikes without manual intervention
- **Cost:** Predictable costs that scale with actual usage
- **Simplicity:** Minimize operational overhead for small team
- **Laravel Optimization:** Hosting optimized for Laravel applications
- **Deployment:** Easy deployment pipeline with zero-downtime deploys

## Considered Options

1. **Option A:** AWS (EC2 + RDS + ElastiCache + Load Balancer)
2. **Option B:** Laravel Forge + DigitalOcean
3. **Option C:** Laravel Vapor (Serverless on AWS Lambda)
4. **Option D:** Platform.sh
5. **Option E:** Render or Railway

## Decision Outcome

**Chosen Option:** Option B - Laravel Forge + DigitalOcean

**Justification:** Laravel Forge provides:
- Purpose-built for Laravel applications
- Simple server provisioning and management
- Zero-downtime deployments built-in
- Automatic SSL via Let's Encrypt
- Database and queue management
- Reasonable cost ($12/month Forge + $50-150/month DigitalOcean)

For an agency platform, Forge + DigitalOcean offers the right balance of simplicity and capability. Full AWS complexity isn't warranted, and serverless (Vapor) adds constraints that may complicate the application architecture.

### Consequences

#### Positive

- Laravel-optimized server configuration out of the box
- Simple deployment with Git push
- Automatic SSL certificate management
- Easy horizontal scaling (add droplets, load balancer)
- DigitalOcean's predictable pricing
- Built-in monitoring and alerts in Forge
- Team-friendly dashboard for deployments

#### Negative

- Manual scaling (not auto-scaling like Vapor)
- Less infrastructure-as-code than AWS/Terraform
- Tied to Forge for management (some vendor lock-in)
- DigitalOcean less feature-rich than AWS

#### Risks

- **Risk:** DigitalOcean region outage affects availability
  - **Mitigation:** Deploy to multiple regions; use DigitalOcean Spaces for assets (CDN-backed)
- **Risk:** Traffic spike exceeds server capacity
  - **Mitigation:** Set up load balancer with multiple droplets; monitor and scale proactively
- **Risk:** Forge service disruption blocks deployments
  - **Mitigation:** Forge provisions standard servers; can SSH manually if needed

## Validation

- **Metric 1:** 99.9% uptime measured over 30-day rolling window
- **Metric 2:** Deployment completes in under 5 minutes
- **Metric 3:** Zero-downtime deployments (no user-visible interruption)
- **Metric 4:** Monthly infrastructure cost under $200 at launch

## Pros and Cons of the Options

### Option A: AWS (Full Stack)

**Pros:**
- Maximum scalability and flexibility
- Auto-scaling groups available
- Enterprise-grade reliability
- Comprehensive service ecosystem

**Cons:**
- Complex setup and management
- Unpredictable costs (many billable components)
- Requires DevOps expertise
- Overkill for initial scale

### Option B: Laravel Forge + DigitalOcean

**Pros:**
- Laravel-optimized
- Simple management interface
- Predictable costs
- Zero-downtime deployments
- Easy SSL and server hardening

**Cons:**
- Manual scaling
- Less automation than IaC approaches
- Forge dependency

### Option C: Laravel Vapor

**Pros:**
- True auto-scaling (pay per request)
- No server management
- Laravel-native serverless
- Handles traffic spikes automatically

**Cons:**
- Higher cost at consistent load
- Lambda constraints (execution time, package size)
- Queue handling more complex
- Database connectivity challenges (RDS Proxy needed)

### Option D: Platform.sh

**Pros:**
- Git-based infrastructure
- Environment per branch
- Good for agencies (multiple projects)

**Cons:**
- Expensive ($50-200/month per environment)
- Less Laravel-specific
- Smaller community

### Option E: Render/Railway

**Pros:**
- Modern developer experience
- Simple pricing
- Good for startups

**Cons:**
- Less mature than alternatives
- Limited Laravel-specific features
- Scaling options more limited

## Implementation Notes

### Server Architecture

```
┌─────────────────────────────────────────────────────┐
│                   DigitalOcean                       │
├─────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────────────────┐    │
│  │ Load        │───▶│ Web Server 1 (Droplet)  │    │
│  │ Balancer    │    │ - Nginx + PHP-FPM       │    │
│  │             │───▶│ - Laravel Application   │    │
│  └─────────────┘    └─────────────────────────┘    │
│         │           ┌─────────────────────────┐    │
│         └──────────▶│ Web Server 2 (Droplet)  │    │
│                     │ (horizontal scaling)     │    │
│                     └─────────────────────────┘    │
│                                                     │
│  ┌─────────────┐    ┌─────────────────────────┐    │
│  │ Managed     │    │ Queue Worker (Droplet)  │    │
│  │ Database    │    │ - Laravel Horizon       │    │
│  │ (MySQL)     │    │ - Background jobs       │    │
│  └─────────────┘    └─────────────────────────┘    │
│                                                     │
│  ┌─────────────┐    ┌─────────────────────────┐    │
│  │ Redis       │    │ Spaces (S3-compatible)  │    │
│  │ (Managed)   │    │ - File storage          │    │
│  └─────────────┘    │ - CDN-backed            │    │
│                     └─────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### Initial Configuration

- **Web Server:** 2GB Droplet ($18/month) - upgradeable
- **Database:** Managed MySQL ($15/month)
- **Redis:** Managed Redis ($15/month)
- **Spaces:** $5/month + bandwidth
- **Load Balancer:** $12/month (when scaling)
- **Forge:** $12/month

### Deployment Pipeline

1. Push to `main` branch triggers Forge deployment
2. Forge runs deployment script:
   - `composer install --no-dev`
   - `php artisan migrate --force`
   - `php artisan config:cache`
   - `php artisan route:cache`
   - `php artisan view:cache`
3. Zero-downtime reload of PHP-FPM
4. Notification sent to Slack on completion

## Links

- [REQ-PERF-003](../01-requirements/req-perf-003.md) - 99.9% Uptime
- [REQ-PERF-007](../01-requirements/req-perf-007.md) - Auto-Scaling Infrastructure
- [REQ-PERF-008](../01-requirements/req-perf-008.md) - Application Monitoring
- [Laravel Forge Documentation](https://forge.laravel.com/docs)
- [DigitalOcean Documentation](https://docs.digitalocean.com)
- [SOP-000: Golden Thread](../00-governance/sop-000-master.md)

## Change Log

| Date       | Author       | Change Description                     |
|------------|--------------|----------------------------------------|
| 2025-11-29 | Claude       | Initial draft                          |
