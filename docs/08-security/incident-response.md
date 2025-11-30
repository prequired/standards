---
id: SEC-IR
title: Security Incident Response Plan
version: 1.0.0
status: active
owner: Security Team
last_updated: 2025-11-29
classification: internal
---

# Security Incident Response Plan

Procedures for detecting, responding to, and recovering from security incidents.

---

## Quick Reference

| Severity | Response Time | Escalation | Examples |
|----------|---------------|------------|----------|
| **SEV-1 Critical** | < 15 minutes | Immediate exec notification | Data breach, ransomware, system compromise |
| **SEV-2 High** | < 1 hour | Security lead + management | Unauthorized access, credential leak |
| **SEV-3 Medium** | < 4 hours | Security team | Suspicious activity, policy violation |
| **SEV-4 Low** | < 24 hours | Security analyst | Failed attacks, minor violations |

---

## Incident Response Phases

```
┌──────────┐    ┌──────────┐    ┌───────────┐    ┌─────────┐    ┌─────────┐
│ Prepare  │───▶│  Detect  │───▶│  Contain  │───▶│Eradicate│───▶│ Recover │
└──────────┘    └──────────┘    └───────────┘    └─────────┘    └─────────┘
                                                                      │
                                                                      ▼
                                                               ┌─────────────┐
                                                               │Post-Incident│
                                                               │   Review    │
                                                               └─────────────┘
```

---

## Phase 1: Preparation

### Incident Response Team

| Role | Responsibility | Contact |
|------|----------------|---------|
| Incident Commander | Overall coordination, decisions | On-call rotation |
| Security Lead | Technical investigation | Security team |
| Communications Lead | Stakeholder updates | Management |
| Technical Lead | System remediation | Engineering |
| Legal/Compliance | Regulatory requirements | Legal counsel |

### Preparation Checklist

- [ ] IR team contact list current
- [ ] Communication channels established (secure)
- [ ] Runbooks accessible offline
- [ ] Backup access credentials secured
- [ ] Legal/compliance contacts confirmed
- [ ] Forensic tools ready
- [ ] External IR firm on retainer (optional)

### Tools and Access

| Tool | Purpose | Access |
|------|---------|--------|
| Flare | Error and exception monitoring | Security team |
| Server logs | System access logs | DevOps, Security |
| Database audit logs | Data access tracking | DBA, Security |
| Cloudflare | WAF and DDoS logs | DevOps |
| Git history | Code change tracking | All engineers |

---

## Phase 2: Detection and Analysis

### Detection Sources

| Source | Monitoring | Alert Threshold |
|--------|------------|-----------------|
| Error monitoring (Flare) | Real-time | Any security exception |
| Failed login attempts | Real-time | > 10 failures/minute |
| Unusual API access | Hourly | > 3x baseline |
| Database queries | Real-time | Unauthorized table access |
| File integrity | Daily | Any change to core files |
| User reports | As received | Any security concern |

### Initial Triage

When an incident is detected:

1. **Acknowledge alert** within 5 minutes
2. **Assess severity** using criteria below
3. **Document initial findings** in incident log
4. **Notify appropriate personnel** per severity
5. **Begin containment** if active threat

### Severity Classification

| Criteria | SEV-1 | SEV-2 | SEV-3 | SEV-4 |
|----------|-------|-------|-------|-------|
| Data exposure | Customer PII | Internal data | Logs only | None |
| System compromise | Production | Staging | Dev only | None |
| Active threat | Yes | Possible | No | No |
| Regulatory impact | Yes | Possible | No | No |
| Customer impact | Yes | Limited | No | No |

### Documentation Template

```markdown
## Incident Log: INC-YYYY-MM-DD-NNN

**Detected:** [timestamp]
**Severity:** [SEV-1/2/3/4]
**Status:** [Active/Contained/Resolved]
**Commander:** [name]

### Timeline
- HH:MM - [Event description]
- HH:MM - [Action taken]

### Affected Systems
- [System 1]
- [System 2]

### Impact Assessment
- Data affected: [description]
- Users affected: [count]
- Services affected: [list]

### Actions Taken
1. [Action]
2. [Action]

### Evidence Preserved
- [Log files]
- [Screenshots]
- [Memory dumps]
```

---

## Phase 3: Containment

### Immediate Actions by Severity

#### SEV-1: Critical

```bash
# 1. Isolate affected systems (don't power off - preserve evidence)
# Network isolation via firewall rules
iptables -I INPUT -s <attacker_ip> -j DROP
iptables -I OUTPUT -d <attacker_ip> -j DROP

# 2. Revoke compromised credentials immediately
php artisan tinker
>>> User::where('email', 'compromised@example.com')->update(['password' => bcrypt(Str::random(64))]);
>>> PersonalAccessToken::where('tokenable_id', $userId)->delete();

# 3. Enable enhanced logging
# Add to .env temporarily
LOG_LEVEL=debug

# 4. Capture system state
mysqldump --single-transaction agency_platform > /secure/incident_backup_$(date +%s).sql
tar -czvf /secure/logs_$(date +%s).tar.gz storage/logs/
```

#### SEV-2: High

1. Reset affected user credentials
2. Review access logs for lateral movement
3. Enable additional monitoring
4. Prepare customer notification (if needed)

#### SEV-3/4: Medium/Low

1. Document the incident
2. Review logs for root cause
3. Implement preventive measures
4. Update monitoring rules

### Evidence Preservation

**DO:**
- Capture logs before rotation
- Screenshot active sessions
- Document all actions with timestamps
- Preserve original files (copy, don't modify)
- Record network connections

**DON'T:**
- Power off systems (lose volatile memory)
- Modify affected files
- Alert attacker (if still active)
- Delete anything

---

## Phase 4: Eradication

### Root Cause Analysis

| Question | Investigation |
|----------|---------------|
| How did attacker gain access? | Review access logs, auth logs |
| What vulnerability was exploited? | Code review, CVE check |
| What systems were accessed? | Database logs, file access |
| Was data exfiltrated? | Network logs, query logs |
| Are there backdoors? | File integrity, user audit |

### Remediation Steps

1. **Patch vulnerability** that allowed access
2. **Remove malicious code** or backdoors
3. **Reset all credentials** that may be compromised
4. **Update firewall rules** to block attack vectors
5. **Apply security updates** to all systems
6. **Review and update** access controls

### Credential Reset Procedure

```bash
# Force password reset for all users
php artisan tinker
>>> User::query()->update(['force_password_reset' => true]);

# Revoke all API tokens
>>> PersonalAccessToken::truncate();

# Clear all sessions
redis-cli KEYS "agency_platform:session:*" | xargs redis-cli DEL

# Regenerate application key (invalidates encrypted data!)
# CAUTION: Only if encryption key may be compromised
# php artisan key:generate
```

---

## Phase 5: Recovery

### Recovery Checklist

- [ ] All malicious access removed
- [ ] Vulnerabilities patched
- [ ] Credentials rotated
- [ ] Systems validated clean
- [ ] Backups verified uncompromised
- [ ] Monitoring enhanced
- [ ] Recovery tested

### Staged Recovery

1. **Restore from clean backup** (if needed)
2. **Apply all security patches**
3. **Enable with enhanced monitoring**
4. **Gradually restore user access**
5. **Monitor for 48-72 hours**

### Validation Testing

```bash
# Verify system integrity
php artisan about

# Check for unauthorized changes
git status
git diff HEAD~10..HEAD

# Verify user accounts
php artisan tinker
>>> User::where('created_at', '>', now()->subDays(7))->get(['id', 'email', 'created_at']);

# Check API tokens
>>> PersonalAccessToken::where('created_at', '>', now()->subDays(7))->count();
```

---

## Phase 6: Post-Incident Review

### Timeline Requirements

| Severity | Review Deadline | Participants |
|----------|-----------------|--------------|
| SEV-1 | Within 48 hours | Full IR team + executives |
| SEV-2 | Within 1 week | IR team + management |
| SEV-3 | Within 2 weeks | Security team |
| SEV-4 | Monthly batch | Security analyst |

### Post-Mortem Template

```markdown
## Post-Incident Review: INC-YYYY-MM-DD-NNN

### Summary
- **Incident:** [Brief description]
- **Duration:** [Start to resolution]
- **Impact:** [Systems, users, data affected]
- **Root Cause:** [What allowed this to happen]

### Timeline
[Detailed timeline of events and actions]

### What Went Well
- [Positive observations]

### What Could Be Improved
- [Areas for improvement]

### Action Items
| Item | Owner | Due Date | Status |
|------|-------|----------|--------|
| [Action] | [Name] | [Date] | [Status] |

### Lessons Learned
[Key takeaways for future prevention]
```

### Required Actions

- [ ] Post-mortem document completed
- [ ] Action items assigned with deadlines
- [ ] Runbooks updated with lessons learned
- [ ] Training scheduled if needed
- [ ] Detection rules updated
- [ ] Management briefed

---

## Communication Templates

### Internal Notification (SEV-1/2)

```
Subject: [SECURITY INCIDENT] Severity [X] - [Brief Description]

A security incident has been detected and the IR team has been activated.

**Status:** [Active/Contained/Resolved]
**Severity:** [SEV-X]
**Impact:** [Brief impact description]
**Current Actions:** [What we're doing]
**Next Update:** [Time]

Do NOT discuss this incident outside of authorized channels.

Incident Commander: [Name]
```

### Customer Notification (if required)

```
Subject: Security Notice from Agency Platform

Dear [Customer],

We are writing to inform you of a security incident that may have affected
your account.

**What Happened:**
[Brief, factual description]

**What Information Was Involved:**
[Specific data types]

**What We Are Doing:**
[Actions taken]

**What You Can Do:**
[Customer actions recommended]

We take security seriously and apologize for any concern this may cause.

[Contact information for questions]
```

---

## Regulatory Reporting

### GDPR Requirements (if applicable)

| Requirement | Timeline | Action |
|-------------|----------|--------|
| DPA notification | 72 hours | Report to supervisory authority |
| User notification | Without undue delay | If high risk to rights |
| Documentation | Ongoing | Maintain incident records |

### Notification Checklist

- [ ] Assess if personal data was breached
- [ ] Determine notification requirements by jurisdiction
- [ ] Prepare notification to supervisory authority
- [ ] Prepare customer notification (if required)
- [ ] Document decision rationale

---

## Emergency Contacts

| Role | Primary | Backup |
|------|---------|--------|
| Security Lead | [Phone/Email] | [Phone/Email] |
| CTO | [Phone/Email] | [Phone/Email] |
| Legal Counsel | [Phone/Email] | [Phone/Email] |
| External IR Firm | [Phone/Email] | N/A |
| Hosting Support | [Laravel Forge Support] | [DigitalOcean Support] |

---

## Related Documents

- [Security Policies](./security-policies.md)
- [Incident Runbook](../07-operations/runbook-incidents.md)
- [ADR-0012: Security](../03-decisions/adr-0012-security-compliance.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial incident response plan |
