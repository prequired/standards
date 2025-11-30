---
id: SOP-001
title: Git Repository Standards and Workflow
version: 1.0.0
status: active
owner: Engineering Lead
last_updated: 2025-11-29
---

# SOP-001: Git Repository Standards and Workflow

## Purpose

Establish standardized Git practices aligned with open source community conventions. This SOP ensures consistent version control workflows, meaningful commit history, and seamless collaboration across teams.

## Scope

Applies to all repositories managed by the organization, including application code, infrastructure-as-code, and documentation repositories.

---

## Branch Strategy

### Primary Branches

| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Production-ready code | Protected: requires PR, passing CI, approvals |
| `develop` | Integration branch for features | Protected: requires PR, passing CI |

### Supporting Branches

| Branch Type | Naming Convention | Base Branch | Merge Target |
|-------------|-------------------|-------------|--------------|
| Feature | `feature/{ticket-id}-{short-description}` | `develop` | `develop` |
| Bugfix | `fix/{ticket-id}-{short-description}` | `develop` | `develop` |
| Hotfix | `hotfix/{ticket-id}-{short-description}` | `main` | `main` and `develop` |
| Release | `release/{version}` | `develop` | `main` and `develop` |
| Documentation | `docs/{short-description}` | `main` or `develop` | `main` or `develop` |

### Branch Naming Rules

1. **Use lowercase:** `feature/auth-login` not `Feature/Auth-Login`
2. **Use hyphens:** `feature/user-authentication` not `feature/user_authentication`
3. **Include ticket ID when applicable:** `feature/PROJ-123-add-mfa`
4. **Keep descriptions short:** 2-4 words maximum
5. **No special characters:** Only alphanumeric, hyphens, and forward slashes

**Examples:**
```
feature/PROJ-42-user-registration
fix/PROJ-99-null-pointer-exception
hotfix/PROJ-101-security-patch
release/v2.1.0
docs/update-api-guidelines
```

---

## Commit Standards

### Conventional Commits

All commits MUST follow the [Conventional Commits](https://www.conventionalcommits.org/) specification (v1.0.0).

**Format:**
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add MFA verification endpoint` |
| `fix` | Bug fix | `fix(api): resolve null pointer in user lookup` |
| `docs` | Documentation only | `docs: update API authentication guide` |
| `style` | Formatting, no code change | `style: fix indentation in UserController` |
| `refactor` | Code change, no feature/fix | `refactor(db): optimize query performance` |
| `perf` | Performance improvement | `perf: cache user session lookups` |
| `test` | Adding/updating tests | `test(auth): add MFA unit tests` |
| `build` | Build system changes | `build: update composer dependencies` |
| `ci` | CI/CD configuration | `ci: add OpenAPI validation step` |
| `chore` | Maintenance tasks | `chore: update .gitignore` |
| `revert` | Revert previous commit | `revert: undo feat(auth) commit abc1234` |

### Commit Message Rules

1. **Subject line:**
   - Use imperative mood: "Add feature" not "Added feature"
   - Do not capitalize first letter after type
   - No period at the end
   - Maximum 72 characters

2. **Body (optional):**
   - Separate from subject with blank line
   - Wrap at 72 characters
   - Explain "what" and "why", not "how"

3. **Footer (optional):**
   - Reference issues: `Refs: #123`
   - Breaking changes: `BREAKING CHANGE: description`
   - Co-authors: `Co-authored-by: Name <email>`

**Good Examples:**
```
feat(api): add user profile retrieval endpoint

Implement GET /users/{id} endpoint per ADR-0042.
Returns user profile data including MFA status.

Refs: REQ-USER-105
Implements: ADR-0042
```

```
fix(auth): prevent session fixation vulnerability

Regenerate session ID after successful authentication
to mitigate session fixation attacks.

BREAKING CHANGE: existing sessions will be invalidated
Refs: SEC-2024-001
```

**Bad Examples:**
```
❌ Fixed bug
❌ WIP
❌ Updated stuff
❌ feat: Add User Authentication Feature.
❌ FEAT(AUTH): ADD MFA
```

### Atomic Commits

Each commit should represent a single logical change:

- ✅ One feature per commit
- ✅ One bug fix per commit
- ✅ Related changes grouped together
- ❌ Multiple unrelated changes in one commit
- ❌ Partial implementations (code that doesn't compile/work)

---

## Pull Request Standards

### PR Title Format

Follow the same Conventional Commits format:
```
<type>[optional scope]: <description>
```

**Examples:**
```
feat(auth): implement TOTP-based MFA
fix(api): resolve rate limiting bypass
docs: add ADR-0042 for message queue selection
```

### PR Description Template

```markdown
## Summary

Brief description of what this PR accomplishes.

## Changes

- Bullet point list of changes
- Include file names or components affected

## Related Issues

- Closes #123
- Refs: REQ-AUTH-101
- Implements: ADR-0008

## Testing

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed

## Documentation

- [ ] README updated (if applicable)
- [ ] API documentation updated (if applicable)
- [ ] ADR created (if architectural change)

## Screenshots (if applicable)

[Add screenshots for UI changes]
```

### PR Requirements

1. **Size limits:**
   - Ideal: < 400 lines changed
   - Maximum: 1000 lines (larger PRs require justification)

2. **Review requirements:**
   - Minimum 1 approval for standard changes
   - Minimum 2 approvals for architectural changes
   - CODEOWNERS approval when modifying owned files

3. **CI requirements:**
   - All status checks must pass
   - No merge conflicts
   - Branch must be up-to-date with base

4. **Documentation requirements:**
   - ADR required for architectural changes
   - API spec updated before implementation (SOP-004)
   - Traceability links established (SOP-000)

---

## Merge Strategy

### Squash and Merge (Default)

Use for feature branches merging to `develop`:

- Combines all commits into single commit
- Maintains clean linear history
- PR title becomes commit message

### Merge Commit

Use for release branches and hotfixes:

- Preserves full commit history
- Creates merge commit for traceability
- Used when merging `release/*` or `hotfix/*` to `main`

### Rebase and Merge

Use sparingly for small, clean PRs:

- Replays commits on top of base branch
- Requires clean commit history
- Avoid for PRs with many commits

### Merge Strategy by Branch Type

| Source Branch | Target Branch | Strategy |
|---------------|---------------|----------|
| `feature/*` | `develop` | Squash and Merge |
| `fix/*` | `develop` | Squash and Merge |
| `docs/*` | `main`/`develop` | Squash and Merge |
| `release/*` | `main` | Merge Commit |
| `release/*` | `develop` | Merge Commit |
| `hotfix/*` | `main` | Merge Commit |
| `hotfix/*` | `develop` | Merge Commit |

---

## Tagging and Versioning

### Semantic Versioning

All releases follow [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

| Component | When to Increment |
|-----------|-------------------|
| MAJOR | Breaking API changes |
| MINOR | New features (backward compatible) |
| PATCH | Bug fixes (backward compatible) |

### Tag Naming

```
v{MAJOR}.{MINOR}.{PATCH}
```

**Examples:**
```
v1.0.0      # Initial release
v1.1.0      # New feature
v1.1.1      # Bug fix
v2.0.0      # Breaking change
v2.0.0-rc.1 # Release candidate
v2.0.0-beta.1 # Beta release
```

### Creating Tags

```bash
# Create annotated tag (required for releases)
git tag -a v1.2.0 -m "Release v1.2.0: Add user authentication"

# Push tag to remote
git push origin v1.2.0

# Push all tags
git push origin --tags
```

### Release Notes

Every tag MUST have corresponding release notes in `docs/09-releases/`:

```
docs/09-releases/
├── v1.0.0.md
├── v1.1.0.md
└── v1.2.0.md
```

---

## Protected Branch Rules

### `main` Branch

| Rule | Setting |
|------|---------|
| Require pull request | ✅ Enabled |
| Required approvals | 2 |
| Dismiss stale reviews | ✅ Enabled |
| Require status checks | ✅ Enabled |
| Require branches up-to-date | ✅ Enabled |
| Required checks | `lint`, `test`, `security-scan` |
| Restrict push access | ✅ Only release managers |
| Allow force push | ❌ Disabled |
| Allow deletions | ❌ Disabled |

### `develop` Branch

| Rule | Setting |
|------|---------|
| Require pull request | ✅ Enabled |
| Required approvals | 1 |
| Dismiss stale reviews | ✅ Enabled |
| Require status checks | ✅ Enabled |
| Required checks | `lint`, `test` |
| Allow force push | ❌ Disabled |
| Allow deletions | ❌ Disabled |

---

## Git Configuration

### Required Global Configuration

```bash
# Set identity
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"

# Use rebase for pull (keeps history clean)
git config --global pull.rebase true

# Set default branch name
git config --global init.defaultBranch main

# Enable commit signing (recommended)
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_GPG_KEY_ID
```

### Repository-Level Configuration

```bash
# Enforce conventional commits via hooks
# (configured in .husky/ or .git/hooks/)
```

---

## .gitignore Standards

Every repository MUST include a comprehensive `.gitignore`:

1. **OS files:** `.DS_Store`, `Thumbs.db`
2. **IDE files:** `.idea/`, `.vscode/`, `*.swp`
3. **Dependencies:** `vendor/`, `node_modules/`
4. **Build artifacts:** `dist/`, `build/`, `*.log`
5. **Environment files:** `.env`, `.env.local`
6. **Secrets:** `*.pem`, `*.key`, `credentials.json`

**Template resource:** [gitignore.io](https://gitignore.io)

---

## Commit Signing

### Why Sign Commits

- Verifies author identity
- Prevents commit spoofing
- Required for verified badge on GitHub

### Setup GPG Signing

```bash
# Generate GPG key
gpg --full-generate-key

# List keys
gpg --list-secret-keys --keyid-format=long

# Export public key (add to GitHub)
gpg --armor --export YOUR_KEY_ID

# Configure Git
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

---

## Common Workflows

### Feature Development

```bash
# 1. Create feature branch
git checkout develop
git pull origin develop
git checkout -b feature/PROJ-123-add-mfa

# 2. Make changes and commit
git add .
git commit -m "feat(auth): add TOTP verification service"

# 3. Push branch
git push -u origin feature/PROJ-123-add-mfa

# 4. Create PR via GitHub/GitLab UI
# 5. After approval, squash and merge via UI
# 6. Delete feature branch
git branch -d feature/PROJ-123-add-mfa
```

### Hotfix Workflow

```bash
# 1. Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/PROJ-999-security-patch

# 2. Fix and commit
git add .
git commit -m "fix(auth): patch session fixation vulnerability"

# 3. Push and create PR to main
git push -u origin hotfix/PROJ-999-security-patch

# 4. After merge to main, also merge to develop
git checkout develop
git pull origin develop
git merge origin/main
git push origin develop
```

### Release Workflow

```bash
# 1. Create release branch
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# 2. Update version numbers, changelog
git commit -m "chore(release): prepare v1.2.0"

# 3. Create PR to main, merge
# 4. Tag the release
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# 5. Merge back to develop
git checkout develop
git merge origin/main
git push origin develop
```

---

## Forbidden Practices

| Practice | Reason |
|----------|--------|
| `git push --force` on protected branches | Destroys history, affects collaborators |
| Committing secrets/credentials | Security risk, permanent in history |
| Large binary files in repo | Bloats repository size |
| Merge commits in feature branches | Pollutes history (use rebase) |
| Direct commits to `main`/`develop` | Bypasses review process |
| Vague commit messages | Reduces traceability |
| Unsigned commits (for releases) | Cannot verify author |

---

## Tooling

### Recommended Tools

| Tool | Purpose |
|------|---------|
| [Commitizen](https://commitizen-tools.github.io/commitizen/) | Interactive commit message builder |
| [Husky](https://typicode.github.io/husky/) | Git hooks manager |
| [commitlint](https://commitlint.js.org/) | Lint commit messages |
| [semantic-release](https://semantic-release.gitbook.io/) | Automated versioning and releases |
| [git-cz](https://github.com/streamich/git-cz) | Conventional commits CLI |

### Pre-commit Hook Example

```bash
#!/bin/sh
# .husky/commit-msg

npx --no -- commitlint --edit "$1"
```

---

## Enforcement

### Automated Checks

1. **CI/CD pipeline** validates commit message format
2. **Branch protection** enforces PR requirements
3. **Pre-commit hooks** lint commits locally
4. **CODEOWNERS** file requires specific reviewers

### Manual Review

Pull requests are rejected if:

- Commit messages do not follow Conventional Commits
- PR description is incomplete
- Traceability links are missing (SOP-000)
- CI checks fail

---

## References

- [Conventional Commits v1.0.0](https://www.conventionalcommits.org/)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Git Branching Model (GitFlow)](https://nvie.com/posts/a-successful-git-branching-model/)
- [Angular Commit Message Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [SOP-000: Golden Thread](./sop-000-master.md)
- [SOP-004: API Guidelines](./sop-004-api-guidelines.md)

---

## Change Log

| Date       | Author       | Change Description           |
|------------|--------------|------------------------------|
| 2025-11-29 | Claude       | Initial version              |
