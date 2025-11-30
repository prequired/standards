---
id: DEV-SETUP
title: Development Environment Setup Guide
version: 1.0.0
status: active
owner: Development Team
last_updated: 2025-11-29
---

# Development Environment Setup Guide

Complete guide for setting up a local development environment for the Agency Platform.

---

## Prerequisites

### Required Software

| Software | Minimum Version | Recommended | Purpose |
|----------|-----------------|-------------|---------|
| PHP | 8.2 | 8.3 | Runtime |
| Composer | 2.6 | Latest | PHP dependencies |
| Node.js | 20 LTS | 22 LTS | Frontend tooling |
| npm/pnpm | 9.0/8.0 | Latest | JS dependencies |
| MySQL | 8.0 | 8.0 | Database |
| Redis | 7.0 | 7.2 | Cache/queues |
| Git | 2.40 | Latest | Version control |

### Optional (Recommended)

| Software | Purpose |
|----------|---------|
| Docker | Containerized development |
| Laravel Herd / Valet | Local PHP server |
| TablePlus / DBeaver | Database GUI |
| Mailpit | Local email testing |

---

## Quick Start (Docker)

The fastest way to get started is using Docker:

```bash
# Clone the repository
git clone git@github.com:agency/platform.git
cd platform

# Copy environment file
cp .env.example .env

# Start containers
docker compose up -d

# Install dependencies
docker compose exec app composer install
docker compose exec app npm install

# Setup application
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate --seed
docker compose exec app npm run build

# Access the application
open http://localhost:8080
```

### Docker Services

| Service | Port | Description |
|---------|------|-------------|
| app | 8080 | Laravel application |
| mysql | 3306 | MySQL database |
| redis | 6379 | Redis cache |
| mailpit | 8025 | Email testing UI |
| minio | 9000 | S3-compatible storage |

---

## Manual Setup

### 1. Clone Repository

```bash
git clone git@github.com:agency/platform.git
cd platform
```

### 2. Install PHP Dependencies

```bash
composer install
```

If you encounter memory issues:

```bash
COMPOSER_MEMORY_LIMIT=-1 composer install
```

### 3. Install JavaScript Dependencies

```bash
npm install
# or using pnpm
pnpm install
```

### 4. Environment Configuration

```bash
# Copy example environment
cp .env.example .env

# Generate application key
php artisan key:generate
```

### 5. Configure Environment Variables

Edit `.env` with your local settings:

```env
# Application
APP_NAME="Agency Platform"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agency_platform
DB_USERNAME=root
DB_PASSWORD=

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Cache & Session
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Mail (use Mailpit for local testing)
MAIL_MAILER=smtp
MAIL_HOST=127.0.0.1
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null

# Filesystem
FILESYSTEM_DISK=local

# Stripe (test keys)
STRIPE_KEY=pk_test_...
STRIPE_SECRET=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 6. Database Setup

Create the database:

```bash
mysql -u root -e "CREATE DATABASE agency_platform"
```

Run migrations and seeders:

```bash
# Run migrations
php artisan migrate

# Seed with sample data
php artisan db:seed

# Or combined
php artisan migrate:fresh --seed
```

### 7. Build Assets

```bash
# Development build with HMR
npm run dev

# Production build
npm run build
```

### 8. Start Development Server

```bash
# PHP built-in server
php artisan serve

# Or with specific port
php artisan serve --port=8080
```

Access at: http://localhost:8000

---

## Development Services

### Queue Worker

Required for background jobs (emails, notifications, etc.):

```bash
# Single worker
php artisan queue:work

# With specific queue priority
php artisan queue:work --queue=high,default,low

# During development (restarts on code changes)
php artisan queue:listen
```

### Scheduler

For scheduled tasks (cron jobs):

```bash
# Run scheduler manually
php artisan schedule:work

# Or add to system cron (production)
* * * * * cd /path/to/platform && php artisan schedule:run >> /dev/null 2>&1
```

### Vite Development Server

For hot module replacement:

```bash
npm run dev
```

Assets will be served from `http://localhost:5173`.

---

## Database Seeding

### Default Users

After seeding, the following users are available:

| Email | Password | Role |
|-------|----------|------|
| admin@agency.test | password | Admin |
| manager@agency.test | password | Manager |
| staff@agency.test | password | Staff |

### Sample Data

Seeding creates:
- 5 sample clients
- 10 sample projects
- 50 sample tasks
- 100 time entries
- 20 invoices

### Custom Seeding

```bash
# Run specific seeder
php artisan db:seed --class=ClientSeeder

# Reset and reseed
php artisan migrate:fresh --seed
```

---

## IDE Configuration

### VS Code

Recommended extensions:
- PHP Intelephense
- Laravel Blade Snippets
- Tailwind CSS IntelliSense
- Prettier
- ESLint

Settings (`.vscode/settings.json`):

```json
{
  "php.suggest.basic": false,
  "editor.formatOnSave": true,
  "[php]": {
    "editor.defaultFormatter": "bmewburn.vscode-intelephense-client"
  },
  "[blade]": {
    "editor.defaultFormatter": "onecentlin.laravel-blade"
  },
  "files.associations": {
    "*.blade.php": "blade"
  }
}
```

### PHPStorm

1. Enable Laravel plugin
2. Configure PHP interpreter (8.2+)
3. Setup Composer path
4. Configure PHPUnit
5. Enable Blade template support

---

## Testing

### Run All Tests

```bash
php artisan test
```

### Run Specific Tests

```bash
# Feature tests
php artisan test --testsuite=Feature

# Unit tests
php artisan test --testsuite=Unit

# Specific file
php artisan test tests/Feature/ProjectTest.php

# Specific method
php artisan test --filter=test_can_create_project
```

### Test Coverage

```bash
php artisan test --coverage

# With HTML report
php artisan test --coverage-html=coverage
```

### Parallel Testing

```bash
php artisan test --parallel
```

---

## Code Quality

### Static Analysis

```bash
# PHPStan
./vendor/bin/phpstan analyse

# Psalm (if configured)
./vendor/bin/psalm
```

### Code Style

```bash
# Check style (Laravel Pint)
./vendor/bin/pint --test

# Fix style
./vendor/bin/pint
```

### Pre-commit Hooks

Install Husky for automatic checks:

```bash
npm run prepare
```

This runs before each commit:
- PHP linting
- Code style check
- PHPStan analysis
- JS/TS linting

---

## Troubleshooting

### Common Issues

#### Composer Memory Limit

```bash
COMPOSER_MEMORY_LIMIT=-1 composer install
```

#### Permission Denied on Storage

```bash
chmod -R 775 storage bootstrap/cache
chown -R $USER:www-data storage bootstrap/cache
```

#### Class Not Found After Composer Install

```bash
composer dump-autoload
php artisan cache:clear
php artisan config:clear
```

#### Vite Manifest Not Found

```bash
npm run build
# or for development
npm run dev
```

#### Redis Connection Refused

Ensure Redis is running:

```bash
# macOS with Homebrew
brew services start redis

# Linux
sudo systemctl start redis
```

#### Database Connection Error

1. Verify MySQL is running
2. Check credentials in `.env`
3. Ensure database exists:

```bash
mysql -u root -e "SHOW DATABASES LIKE 'agency_platform'"
```

### Reset Everything

Nuclear option - reset all caches and rebuild:

```bash
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
composer dump-autoload
npm run build
php artisan migrate:fresh --seed
```

---

## Environment-Specific Notes

### macOS

```bash
# Install PHP via Homebrew
brew install php@8.3

# Install MySQL
brew install mysql
brew services start mysql

# Install Redis
brew install redis
brew services start redis
```

Consider using [Laravel Herd](https://herd.laravel.com) for simplified setup.

### Ubuntu/Debian

```bash
# Add PHP repository
sudo add-apt-repository ppa:ondrej/php

# Install PHP and extensions
sudo apt install php8.3 php8.3-{mysql,redis,gd,zip,mbstring,xml,curl}

# Install MySQL
sudo apt install mysql-server

# Install Redis
sudo apt install redis-server
```

### Windows

Recommended approach: Use WSL2 with Ubuntu.

Alternatively, use [Laravel Herd](https://herd.laravel.com) for Windows.

---

## Next Steps

After setup is complete:

1. Review [Development Standards](./dev-standards.md)
2. Read [Git Workflow](./git-workflow.md)
3. Understand [Code Review Process](./code-review.md)
4. Explore [API Specification](../05-api/api-specification.md)

---

## Related Documents

- [Development Standards](./dev-standards.md)
- [Git Workflow](./git-workflow.md)
- [Testing Strategy](../06-testing/testing-strategy.md)
- [Configuration Management](./configuration-management.md)

---

## Change Log

| Date | Version | Author | Change Description |
|------|---------|--------|-------------------|
| 2025-11-29 | 1.0.0 | Claude | Initial setup guide |
