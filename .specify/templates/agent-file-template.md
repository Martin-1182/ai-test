# Laravel Application Development Guidelines

Auto-generated from all feature plans. Last updated: [DATE]

## Active Technologies
**Framework**: Laravel 12 (PHP 8.2+)
**Testing**: Pest 4.1
**API**: Sanctum for authentication
**Frontend**: Vite
**Formatting**: Laravel Pint
**Static Analysis**: PHPStan
[ADDITIONAL TECHNOLOGIES FROM PLAN.MD FILES]

## Project Structure
```
app/
├── Http/
│   ├── Controllers/Api/    # API controllers (thin, HTTP concerns only)
│   ├── Requests/           # FormRequest validation classes
│   ├── Resources/          # API response transformers
│   └── Middleware/         # Custom middleware
├── Models/                 # Eloquent models with business rules
├── Services/               # Business logic layer
└── Policies/               # Authorization policies

database/
├── migrations/             # Database schema with constraints
└── seeders/               # Test data seeders

tests/
├── Feature/               # Integration & API tests
└── Unit/                  # Unit tests for isolated logic

routes/
├── api.php               # API routes (/api/v1/*)
└── web.php               # Web routes

config/                   # Configuration files
docs/api/                # OpenAPI specifications
```

## Commands
**Development**: `composer dev` (starts server, queue, logs, vite)
**Testing**: `composer test` (runs Pest test suite)
**Formatting**: `./vendor/bin/pint` (Laravel Pint formatter)
**Static Analysis**: `./vendor/bin/phpstan analyse` (PHPStan level 6)
**Migrations**: `php artisan migrate` / `php artisan migrate:rollback`

## Code Style
**PHP Standards**: PSR-12, Laravel conventions
**Naming**:
  - Classes: PascalCase (UserController, CreateUserRequest)
  - Methods: camelCase (getUserById, validateInput)
  - Database: snake_case (user_id, created_at)
**Architecture**:
  - Controllers: HTTP only, inject services via constructor
  - Services: Business logic, transaction management
  - Models: Validation, relationships, accessors/mutators
  - Requests: Input validation rules

## Recent Changes
[LAST 3 FEATURES AND WHAT THEY ADDED]

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->