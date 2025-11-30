# Code Review Guidelines

**Version:** 1.0.0
**Last Updated:** 2025-11-29

---

## 1. Overview

Code review is a critical quality gate in our development process. Every change to `main` must be reviewed and approved by at least one team member.

### 1.1 Goals

- **Catch defects** before they reach production
- **Share knowledge** across the team
- **Maintain consistency** in code style and patterns
- **Improve code quality** through collaborative feedback
- **Mentorship** opportunity for junior developers

### 1.2 Principles

1. **Be constructive** - Critique code, not people
2. **Be specific** - Point to exact issues with suggestions
3. **Be timely** - Review within 24 hours
4. **Be thorough** - Don't rubber-stamp
5. **Be humble** - You might be wrong too

---

## 2. Pull Request Guidelines

### 2.1 PR Template

```markdown
## Summary
<!-- Brief description of what this PR does -->

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Performance improvement

## Related Issues
<!-- Link to related issues: Fixes #123, Relates to #456 -->

## Changes Made
<!-- Bullet points of specific changes -->
-
-
-

## Testing
<!-- How was this tested? -->
- [ ] Unit tests added/updated
- [ ] Feature tests added/updated
- [ ] Manual testing performed
- [ ] Tested on staging environment

## Screenshots
<!-- If UI changes, add before/after screenshots -->

## Checklist
- [ ] My code follows the project's coding standards
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] I have updated documentation as needed
- [ ] My changes generate no new warnings
- [ ] Tests pass locally
- [ ] Any dependent changes have been merged

## Deployment Notes
<!-- Any special deployment considerations? -->
```

### 2.2 PR Size Guidelines

| Size | Lines Changed | Review Time | Recommendation |
|------|---------------|-------------|----------------|
| XS | < 50 | 15 min | Ideal |
| S | 50-200 | 30 min | Good |
| M | 200-400 | 1 hour | Acceptable |
| L | 400-800 | 2 hours | Split if possible |
| XL | > 800 | 4+ hours | Must split |

**Best Practices:**
- Aim for PRs under 400 lines
- Large PRs get superficial reviews
- Split by logical units, not arbitrary line counts
- Stack PRs if needed for large features

### 2.3 PR Title Format

Follow conventional commits:

```
<type>(<scope>): <description>

Examples:
feat(billing): add recurring invoice generation
fix(portal): correct invoice total calculation
docs(api): update authentication examples
refactor(projects): extract status calculation service
```

---

## 3. Review Process

### 3.1 Author Responsibilities

**Before Requesting Review:**

1. **Self-review first**
   - Read your own diff line by line
   - Check for typos, debug code, commented code
   - Ensure tests pass locally

2. **Write clear description**
   - Explain WHY, not just WHAT
   - Link related issues
   - Note any areas of uncertainty

3. **Keep it focused**
   - One logical change per PR
   - Don't mix refactoring with features
   - Separate formatting changes

4. **Make it reviewable**
   - Add inline comments for complex code
   - Highlight key changes
   - Provide testing instructions

**During Review:**

5. **Respond promptly**
   - Address feedback within 24 hours
   - Resolve conversations when done
   - Ask for clarification if needed

6. **Don't take it personally**
   - Feedback is about code, not you
   - Learn from suggestions
   - Thank reviewers for their time

### 3.2 Reviewer Responsibilities

**Review Checklist:**

```markdown
## Correctness
- [ ] Does the code do what it claims?
- [ ] Are edge cases handled?
- [ ] Is error handling appropriate?

## Design
- [ ] Does it follow project architecture?
- [ ] Is it in the right location?
- [ ] Are abstractions appropriate?

## Code Quality
- [ ] Is it readable and maintainable?
- [ ] Are names clear and consistent?
- [ ] Is there duplication that should be extracted?

## Testing
- [ ] Are tests adequate for the change?
- [ ] Do tests cover edge cases?
- [ ] Are tests readable?

## Security
- [ ] Is user input validated?
- [ ] Are authorization checks in place?
- [ ] Are secrets handled properly?

## Performance
- [ ] Are there N+1 query issues?
- [ ] Is caching used appropriately?
- [ ] Could this cause performance problems?

## Documentation
- [ ] Is complex code commented?
- [ ] Is documentation updated?
- [ ] Are PHPDoc blocks complete?
```

**Feedback Guidelines:**

1. **Be specific**
   ```
   ❌ "This is confusing"
   ✅ "The variable name `$x` doesn't convey its purpose. Consider `$projectCount`"
   ```

2. **Explain why**
   ```
   ❌ "Use early return here"
   ✅ "Use early return here to reduce nesting and make the happy path clearer"
   ```

3. **Offer solutions**
   ```
   ❌ "This won't work"
   ✅ "This will fail when $user is null. Consider using optional chaining: $user?->name"
   ```

4. **Use conventional comments**
   - `suggestion:` - Non-blocking improvement
   - `question:` - Seeking clarification
   - `issue:` - Must be addressed
   - `nitpick:` - Minor style preference
   - `praise:` - Positive feedback

### 3.3 Comment Prefixes

| Prefix | Meaning | Blocking? |
|--------|---------|-----------|
| `issue:` | Must be fixed before merge | Yes |
| `question:` | Need clarification | Maybe |
| `suggestion:` | Consider this improvement | No |
| `nitpick:` | Minor preference | No |
| `praise:` | This is good! | No |
| `note:` | FYI, no action needed | No |

**Examples:**

```
issue: This SQL query is vulnerable to injection. Use parameterized queries.

question: Why did you choose to eager load all relationships here? Seems expensive.

suggestion: Consider extracting this to a service class for better testability.

nitpick: Prefer `$user->isAdmin()` over `$user->role === 'admin'` for readability.

praise: Great job handling the edge case where the project has no tasks!
```

---

## 4. Review Focus Areas

### 4.1 Security Review

**Always check:**
- SQL injection (use query builder/Eloquent)
- XSS (escape output with `{{ }}`)
- CSRF (forms have `@csrf`)
- Mass assignment (use `$fillable`)
- Authorization (check policies)
- Authentication (verify user access)
- File uploads (validate type/size)
- API authentication (token handling)

### 4.2 Performance Review

**Watch for:**
- N+1 queries (use eager loading)
- Missing indexes (check query plans)
- Large dataset handling (use chunking)
- Unnecessary database calls (use caching)
- Heavy operations in request cycle (use queues)
- Memory leaks (unset large arrays)

### 4.3 Architecture Review

**Verify:**
- Code is in correct layer (controller/service/model)
- Single responsibility principle
- Dependency injection used properly
- Interfaces for external dependencies
- Events for cross-cutting concerns
- Follows existing patterns in codebase

### 4.4 Testing Review

**Ensure:**
- Tests actually test the feature
- Edge cases are covered
- Tests are independent (no shared state)
- Mocks are used appropriately
- Tests are readable
- No flaky tests

---

## 5. Approval Criteria

### 5.1 When to Approve

- All blocking issues resolved
- Tests pass in CI
- Code follows standards
- You understand the change
- You would feel comfortable supporting this code

### 5.2 When to Request Changes

- Security vulnerabilities
- Obvious bugs
- Missing tests for critical paths
- Violations of coding standards
- Unclear or unmaintainable code
- Missing error handling

### 5.3 When to Comment (Not Block)

- Style preferences
- Minor improvements
- Suggestions for future work
- Questions for understanding
- Praise for good code

---

## 6. Special Cases

### 6.1 Hotfixes

- Expedited review (1-2 hours max)
- Focus on correctness over style
- Follow up with improvements if needed
- Document in PR why expedited

### 6.2 Refactoring

- Verify behavior is unchanged
- Check for test coverage before changes
- Prefer separate PRs for refactor vs feature
- Document motivation clearly

### 6.3 Dependencies

- Check for security advisories
- Verify license compatibility
- Test upgrade path
- Document breaking changes

### 6.4 Large Features

- Request incremental reviews
- Use draft PRs for early feedback
- Break into stacked PRs if possible
- Schedule dedicated review time

---

## 7. Tools and Automation

### 7.1 Automated Checks

PRs must pass:
- **Tests** - PHPUnit/Pest
- **Static Analysis** - PHPStan level 8
- **Code Style** - Laravel Pint
- **Security Scan** - Dependabot

### 7.2 Review Apps

For UI changes:
- Deploy preview automatically
- Include preview URL in PR
- Test functionality before approving

### 7.3 GitHub Features

Use:
- **Suggestions** - Propose code changes inline
- **Required reviewers** - Via CODEOWNERS
- **Review requests** - Assign specific reviewers
- **Labels** - Categorize PRs
- **Milestones** - Track releases

---

## 8. Metrics

### 8.1 Healthy Review Process

| Metric | Target | Warning |
|--------|--------|---------|
| Time to first review | < 4 hours | > 24 hours |
| Time to merge | < 48 hours | > 1 week |
| Review iterations | 1-2 | > 4 |
| Comments per PR | 3-10 | < 1 or > 20 |

### 8.2 Red Flags

- PRs sitting unreviewed for days
- Rubber-stamp approvals (no comments)
- Excessive back-and-forth
- Reviews taking longer than development
- Same issues appearing repeatedly

---

## 9. Resolving Disagreements

### 9.1 Escalation Path

1. **Discuss in PR** - Most issues resolve here
2. **Sync call** - For complex discussions
3. **Team decision** - Vote if needed
4. **Tech lead decision** - Final authority

### 9.2 When to Defer

- Style preferences (follow existing patterns)
- Bikeshedding (move on if not important)
- Out of scope (create follow-up issue)

### 9.3 Documentation

- Record significant decisions in ADRs
- Update coding standards if pattern emerges
- Share learnings in team retrospectives

---

## Links

- [Development Standards](./dev-standards.md)
- [Git Workflow](./git-workflow.md)
- [Google Code Review Guidelines](https://google.github.io/eng-practices/review/)
- [Conventional Comments](https://conventionalcomments.org/)

---

## Change Log

| Date | Version | Change |
|------|---------|--------|
| 2025-11-29 | 1.0.0 | Initial code review guidelines |
