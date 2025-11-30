---
id: TEST-E2E
title: End-to-End Test Scenarios
version: 1.0.0
status: active
owner: QA Team
last_updated: 2025-11-29
---

# End-to-End Test Scenarios

Comprehensive E2E test scenarios covering critical user journeys through the Agency Platform.

---

## Overview

E2E tests verify complete user workflows from start to finish, testing the full stack including UI, API, database, and integrations.

### Testing Stack

| Component | Tool |
|-----------|------|
| Browser Automation | Playwright |
| API Testing | Playwright API |
| Visual Testing | Playwright Screenshots |
| CI Integration | GitHub Actions |

---

## Critical User Journeys

### 1. User Authentication Flow

**Priority:** Critical
**Requirements:** REQ-AUTH-001, REQ-AUTH-002, REQ-AUTH-003

#### Scenario: Standard Login

```gherkin
Feature: User Authentication

  Scenario: User logs in with valid credentials
    Given I am on the login page
    When I enter "user@agency.test" as email
    And I enter "password" as password
    And I click the "Sign In" button
    Then I should be redirected to the dashboard
    And I should see "Welcome back" message
    And the session cookie should be set

  Scenario: User logs in with invalid credentials
    Given I am on the login page
    When I enter "user@agency.test" as email
    And I enter "wrongpassword" as password
    And I click the "Sign In" button
    Then I should see "Invalid credentials" error
    And I should remain on the login page

  Scenario: User logs in with MFA enabled
    Given I am on the login page
    And my account has MFA enabled
    When I enter valid credentials
    And I click the "Sign In" button
    Then I should see the MFA code input
    When I enter a valid MFA code
    Then I should be redirected to the dashboard
```

#### Test Implementation

```typescript
// tests/e2e/auth/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('successful login redirects to dashboard', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[name="email"]', 'user@agency.test');
    await page.fill('[name="password"]', 'password');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('text=Welcome back')).toBeVisible();
  });

  test('invalid credentials show error', async ({ page }) => {
    await page.goto('/login');

    await page.fill('[name="email"]', 'user@agency.test');
    await page.fill('[name="password"]', 'wrongpassword');
    await page.click('button[type="submit"]');

    await expect(page.locator('text=Invalid credentials')).toBeVisible();
    await expect(page).toHaveURL('/login');
  });
});
```

---

### 2. Project Management Flow

**Priority:** Critical
**Requirements:** REQ-PROJ-001 through REQ-PROJ-006

#### Scenario: Create and Manage Project

```gherkin
Feature: Project Management

  Background:
    Given I am logged in as a manager
    And I have at least one client

  Scenario: Create a new project
    Given I am on the projects page
    When I click "New Project"
    Then I should see the project creation form
    When I fill in the project details:
      | Field       | Value            |
      | Name        | Website Redesign |
      | Client      | Acme Corp        |
      | Description | Full redesign    |
      | Budget      | 50000            |
      | Due Date    | 2025-06-30       |
    And I click "Create Project"
    Then I should see "Project created successfully"
    And I should be on the project detail page
    And the project should appear in the projects list

  Scenario: Add tasks to project
    Given I have a project "Website Redesign"
    When I navigate to the project
    And I click "Add Task"
    And I fill in:
      | Field       | Value              |
      | Title       | Design homepage    |
      | Assignee    | John Designer      |
      | Due Date    | 2025-02-15         |
      | Estimate    | 8 hours            |
    And I click "Save Task"
    Then the task should appear in the task list
    And the assignee should receive a notification

  Scenario: Complete project workflow
    Given I have a project with all tasks completed
    When I navigate to the project
    And I change status to "Completed"
    Then I should see a confirmation dialog
    When I confirm the status change
    Then the project status should be "Completed"
    And the client should receive a completion notification
```

#### Test Implementation

```typescript
// tests/e2e/projects/project-lifecycle.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Project Lifecycle', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
    await page.fill('[name="email"]', 'manager@agency.test');
    await page.fill('[name="password"]', 'password');
    await page.click('button[type="submit"]');
    await expect(page).toHaveURL('/dashboard');
  });

  test('complete project creation flow', async ({ page }) => {
    // Navigate to projects
    await page.click('nav >> text=Projects');
    await expect(page).toHaveURL('/projects');

    // Create new project
    await page.click('text=New Project');
    await page.fill('[name="name"]', 'E2E Test Project');
    await page.selectOption('[name="client_id"]', { label: 'Test Client' });
    await page.fill('[name="description"]', 'Created by E2E test');
    await page.fill('[name="budget"]', '10000');
    await page.fill('[name="due_date"]', '2025-06-30');
    await page.click('button:has-text("Create Project")');

    // Verify creation
    await expect(page.locator('text=Project created')).toBeVisible();
    await expect(page.locator('h1:has-text("E2E Test Project")')).toBeVisible();

    // Add a task
    await page.click('text=Add Task');
    await page.fill('[name="title"]', 'Test Task');
    await page.click('button:has-text("Save")');
    await expect(page.locator('text=Test Task')).toBeVisible();
  });
});
```

---

### 3. Time Tracking Flow

**Priority:** High
**Requirements:** REQ-TIME-001 through REQ-TIME-005

#### Scenario: Track Time on Tasks

```gherkin
Feature: Time Tracking

  Background:
    Given I am logged in as staff
    And I am assigned to a project task

  Scenario: Start and stop timer
    Given I am on my timesheet page
    When I click "Start Timer"
    And I select project "Website Redesign"
    And I select task "Design homepage"
    Then the timer should start
    And I should see the elapsed time updating
    When I work for 2 hours (simulated)
    And I click "Stop Timer"
    Then a time entry should be created
    And the duration should be approximately 2 hours

  Scenario: Manual time entry
    Given I am on my timesheet page
    When I click "Add Entry"
    And I fill in:
      | Field       | Value            |
      | Project     | Website Redesign |
      | Task        | Design homepage  |
      | Date        | Today            |
      | Duration    | 2:30             |
      | Description | Design work      |
      | Billable    | Yes              |
    And I click "Save"
    Then the entry should appear in my timesheet
    And the project hours should be updated

  Scenario: Weekly timesheet view
    Given I have time entries for the current week
    When I navigate to the weekly timesheet
    Then I should see entries grouped by day
    And I should see the total hours for the week
    And I should see billable vs non-billable breakdown
```

---

### 4. Invoice Generation Flow

**Priority:** Critical
**Requirements:** REQ-BILL-001 through REQ-BILL-005

#### Scenario: Generate and Send Invoice

```gherkin
Feature: Invoicing

  Background:
    Given I am logged in as a manager
    And I have a project with billable time entries

  Scenario: Generate invoice from time entries
    Given project "Website Redesign" has 40 hours of billable time
    When I navigate to the project
    And I click "Generate Invoice"
    Then I should see an invoice preview
    And the line items should reflect the time entries
    And the total should calculate correctly with tax
    When I click "Create Invoice"
    Then an invoice should be created with status "Draft"

  Scenario: Send invoice to client
    Given I have a draft invoice for "Acme Corp"
    When I navigate to the invoice
    And I review the details
    And I click "Send to Client"
    Then I should see a confirmation dialog
    When I confirm sending
    Then the invoice status should change to "Sent"
    And the client should receive an email with the invoice
    And the invoice should show in the client portal

  Scenario: Record payment
    Given I have a sent invoice
    When the client pays via Stripe
    Then the invoice status should change to "Paid"
    And a payment record should be created
    And I should receive a payment notification
```

---

### 5. Client Portal Flow

**Priority:** High
**Requirements:** REQ-PORT-001 through REQ-PORT-010

#### Scenario: Client Views Project Progress

```gherkin
Feature: Client Portal

  Background:
    Given I am logged in as a client user
    And I have an active project

  Scenario: View project dashboard
    When I access the client portal
    Then I should see my active projects
    And I should see recent activity
    And I should see pending invoices

  Scenario: View project details
    When I click on my project
    Then I should see the project progress
    And I should see completed milestones
    And I should see pending deliverables
    But I should not see internal notes or costs

  Scenario: Approve deliverable
    Given my project has a deliverable pending approval
    When I view the deliverable
    And I click "Approve"
    Then the deliverable status should change to "Approved"
    And the team should receive a notification

  Scenario: Pay invoice online
    Given I have an unpaid invoice
    When I click "Pay Now"
    Then I should see the Stripe payment form
    When I enter valid payment details
    And I submit the payment
    Then the invoice should be marked as paid
    And I should receive a payment confirmation
```

---

## Test Data Setup

### Seed Data for E2E Tests

```typescript
// tests/e2e/fixtures/seed-data.ts
export const testData = {
  users: {
    admin: { email: 'admin@agency.test', password: 'password', role: 'admin' },
    manager: { email: 'manager@agency.test', password: 'password', role: 'manager' },
    staff: { email: 'staff@agency.test', password: 'password', role: 'staff' },
    client: { email: 'client@agency.test', password: 'password', role: 'client' },
  },
  clients: [
    { name: 'Test Client', email: 'contact@testclient.com' },
    { name: 'Acme Corp', email: 'billing@acme.com' },
  ],
  projects: [
    { name: 'Website Redesign', client: 'Acme Corp', status: 'active' },
    { name: 'Mobile App', client: 'Test Client', status: 'draft' },
  ],
};
```

### Database Reset Between Tests

```typescript
// tests/e2e/global-setup.ts
import { FullConfig } from '@playwright/test';

async function globalSetup(config: FullConfig) {
  // Reset database to known state
  const { execSync } = require('child_process');
  execSync('php artisan migrate:fresh --seed --env=testing');
}

export default globalSetup;
```

---

## Test Configuration

### Playwright Config

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',

  use: {
    baseURL: 'http://localhost:8000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },

  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile', use: { ...devices['iPhone 13'] } },
  ],

  webServer: {
    command: 'php artisan serve --env=testing',
    url: 'http://localhost:8000',
    reuseExistingServer: !process.env.CI,
  },
});
```

---

## Running E2E Tests

### Local Development

```bash
# Run all E2E tests
npm run test:e2e

# Run with UI mode (for debugging)
npm run test:e2e -- --ui

# Run specific test file
npm run test:e2e -- tests/e2e/auth/login.spec.ts

# Run in headed mode (see browser)
npm run test:e2e -- --headed
```

### CI/CD Pipeline

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on: [push, pull_request]

jobs:
  e2e:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: testing
          MYSQL_ROOT_PASSWORD: password
        ports:
          - 3306:3306

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'

      - name: Install dependencies
        run: |
          composer install
          npm install

      - name: Setup application
        run: |
          cp .env.ci .env
          php artisan key:generate
          php artisan migrate --seed
          npm run build

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npm run test:e2e

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
```

---

## Test Coverage Matrix

| Journey | Scenarios | Priority | Status |
|---------|-----------|----------|--------|
| Authentication | 5 | Critical | Defined |
| Project Management | 8 | Critical | Defined |
| Time Tracking | 6 | High | Defined |
| Invoicing | 7 | Critical | Defined |
| Client Portal | 6 | High | Defined |
| User Management | 4 | Medium | Pending |
| Reporting | 3 | Medium | Pending |
| Integrations | 4 | Low | Pending |

---

## Related Documents

- [Testing Strategy](./testing-strategy.md)
- [Test Templates](./test-templates.md)
- [Requirements](../01-requirements/README.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial E2E scenarios |
