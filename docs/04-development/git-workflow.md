# Git Workflow

**Version:** 1.0.0
**Last Updated:** 2025-11-29

---

## 1. Overview

This document defines the Git workflow for the Agency Platform. We use a trunk-based development approach with short-lived feature branches.

### 1.1 Principles

1. **Small, frequent commits** - Easier to review and revert
2. **Short-lived branches** - Merge within 1-2 days
3. **Always deployable main** - Main branch is production-ready
4. **Code review required** - All changes via pull request
5. **Automated testing** - CI runs on every PR

---

## 2. Branch Strategy

### 2.1 Branch Types

| Branch | Purpose | Naming | Lifespan |
|--------|---------|--------|----------|
| `main` | Production-ready code | - | Permanent |
| `feature/*` | New features | `feature/add-time-tracking` | 1-2 days |
| `fix/*` | Bug fixes | `fix/invoice-calculation` | 1-2 days |
| `hotfix/*` | Urgent production fixes | `hotfix/payment-failure` | Hours |
| `chore/*` | Maintenance tasks | `chore/upgrade-laravel` | 1-2 days |
| `docs/*` | Documentation only | `docs/api-endpoints` | 1-2 days |

### 2.2 Branch Naming

```
<type>/<short-description>

# Examples
feature/client-portal-dashboard
fix/missing-invoice-pdf
hotfix/stripe-webhook-signature
chore/upgrade-php-83
docs/deployment-runbook
```

**Rules:**
- Use lowercase
- Use hyphens (not underscores)
- Keep descriptions short but meaningful
- Include ticket number if applicable: `feature/AP-123-time-tracking`

---

## 3. Workflow

### 3.1 Starting New Work

```bash
# 1. Start from main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/add-time-tracking

# 3. Make changes and commit frequently
git add .
git commit -m "feat: add time entry model and migration"

# 4. Push branch
git push -u origin feature/add-time-tracking
```

### 3.2 Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting (no code change) |
| `refactor` | Code restructuring |
| `perf` | Performance improvement |
| `test` | Adding/updating tests |
| `chore` | Maintenance tasks |
| `ci` | CI/CD changes |

**Examples:**

```bash
# Feature
git commit -m "feat(billing): add recurring invoice generation"

# Bug fix
git commit -m "fix(portal): correct invoice total calculation

The total was not including tax when displaying to clients.

Fixes #123"

# Breaking change
git commit -m "feat(api)!: change project status endpoint

BREAKING CHANGE: GET /api/projects now returns paginated results"
```

### 3.3 Keeping Branch Updated

```bash
# Rebase on main regularly (at least daily)
git fetch origin
git rebase origin/main

# Resolve conflicts if any
# Then force push (only your feature branch!)
git push --force-with-lease
```

### 3.4 Creating Pull Request

```bash
# Push your branch
git push -u origin feature/add-time-tracking

# Create PR via GitHub CLI
gh pr create --title "feat: add time tracking" --body "
## Summary
- Added TimeEntry model and migration
- Created time tracking Livewire component
- Added API endpoints for time entries

## Testing
- [ ] Unit tests for TimeEntry model
- [ ] Feature tests for API endpoints
- [ ] Manual testing in portal

## Screenshots
[Add screenshots if UI changes]
"
```

### 3.5 Code Review

**As Author:**
- Keep PR small (< 400 lines ideally)
- Provide clear description
- Respond to feedback promptly
- Don't merge your own PR

**As Reviewer:**
- Review within 24 hours
- Be constructive and specific
- Approve only when confident
- Use suggestions for minor changes

### 3.6 Merging

```bash
# After approval, squash and merge via GitHub UI
# Or via CLI:
gh pr merge --squash

# Delete the feature branch
git branch -d feature/add-time-tracking
git push origin --delete feature/add-time-tracking
```

---

## 4. Hotfix Process

For urgent production issues:

```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/payment-failure

# 2. Make minimal fix
git add .
git commit -m "fix(payments): handle Stripe webhook timeout"

# 3. Create PR with hotfix label
gh pr create --title "hotfix: payment webhook timeout" --label "hotfix"

# 4. Get expedited review and merge

# 5. Deploy immediately
```

---

## 5. Release Process

### 5.1 Semantic Versioning

```
MAJOR.MINOR.PATCH

1.0.0 - Initial release
1.1.0 - New feature (backward compatible)
1.1.1 - Bug fix
2.0.0 - Breaking change
```

### 5.2 Creating Release

```bash
# 1. Ensure main is ready
git checkout main
git pull origin main

# 2. Create release tag
git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Added time tracking (#45)
- Client portal dashboard (#52)

Fixes:
- Invoice PDF generation (#61)
- Login redirect loop (#63)"

# 3. Push tag
git push origin v1.2.0

# 4. Create GitHub release
gh release create v1.2.0 --generate-notes
```

---

## 6. Git Configuration

### 6.1 Recommended Settings

```bash
# Set default branch
git config --global init.defaultBranch main

# Set pull strategy
git config --global pull.rebase true

# Set push strategy
git config --global push.autoSetupRemote true

# Enable rerere (reuse recorded resolution)
git config --global rerere.enabled true

# Set editor
git config --global core.editor "code --wait"
```

### 6.2 Git Aliases

```bash
# Add to ~/.gitconfig
[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    lg = log --oneline --graph --decorate -10
    undo = reset HEAD~1 --soft
    amend = commit --amend --no-edit
    wip = commit -am "WIP"
    pr = "!gh pr create"
```

---

## 7. Protected Branch Rules

### 7.1 Main Branch Protection

Configure in GitHub repository settings:

- [x] Require pull request before merging
  - [x] Require 1 approval
  - [x] Dismiss stale reviews on new commits
  - [x] Require review from code owners
- [x] Require status checks to pass
  - [x] CI / Tests
  - [x] CI / Static Analysis
  - [x] CI / Code Style
- [x] Require linear history (squash merge)
- [x] Do not allow bypassing settings

### 7.2 CODEOWNERS

```
# .github/CODEOWNERS

# Default owners for everything
* @team-lead

# Specific areas
/app/Domain/Billing/ @billing-team
/app/Domain/Projects/ @projects-team
/docs/ @tech-writer
/.github/ @devops-team
```

---

## 8. Continuous Integration

### 8.1 Required Checks

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
      - run: composer install
      - run: ./vendor/bin/pest --parallel

  static-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
      - run: composer install
      - run: ./vendor/bin/phpstan analyse

  code-style:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
      - run: composer install
      - run: ./vendor/bin/pint --test
```

---

## 9. Common Scenarios

### 9.1 Undoing Commits

```bash
# Undo last commit (keep changes staged)
git reset --soft HEAD~1

# Undo last commit (keep changes unstaged)
git reset HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo a pushed commit (creates new commit)
git revert <commit-hash>
```

### 9.2 Stashing Work

```bash
# Stash current changes
git stash push -m "WIP: time tracking form"

# List stashes
git stash list

# Apply and remove stash
git stash pop

# Apply specific stash
git stash apply stash@{2}
```

### 9.3 Cherry Picking

```bash
# Apply specific commit to current branch
git cherry-pick <commit-hash>

# Cherry pick without committing
git cherry-pick --no-commit <commit-hash>
```

### 9.4 Interactive Rebase

```bash
# Rebase last 3 commits
git rebase -i HEAD~3

# In editor, change 'pick' to:
# - 'squash' to combine with previous
# - 'reword' to change message
# - 'drop' to remove commit
# - 'edit' to modify commit
```

---

## 10. Troubleshooting

### 10.1 Merge Conflicts

```bash
# During rebase, conflicts occur
# 1. Edit conflicting files
# 2. Stage resolved files
git add <file>

# 3. Continue rebase
git rebase --continue

# Or abort if needed
git rebase --abort
```

### 10.2 Detached HEAD

```bash
# Create branch from detached state
git checkout -b recovery-branch

# Or return to main
git checkout main
```

### 10.3 Recover Lost Commits

```bash
# Find lost commits
git reflog

# Recover commit
git checkout <commit-hash>
git checkout -b recovered-branch
```

---

## Links

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)
- [Git Documentation](https://git-scm.com/doc)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial Git workflow documentation |
