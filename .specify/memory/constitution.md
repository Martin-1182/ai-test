# Laravel Application Constitution

<!--
SYNC IMPACT REPORT - Constitution v1.0.0
========================================
Version Change: Initial version (v1.0.0)
Ratification Date: 2025-10-02

ADDED SECTIONS:
- Core Principles: Test-Driven Development, API-First Design, Model Integrity, Service Layer Architecture, Observability
- Development Standards: Code quality, security, performance requirements
- Quality Gates: Pre-commit, pre-deployment validation requirements
- Governance: Amendment procedures, version control, compliance review

TEMPLATE UPDATES REQUIRED:
✅ plan-template.md - Updated Constitution Check gates
✅ spec-template.md - Aligned with API-first principle
✅ tasks-template.md - Integrated TDD ordering requirements
✅ agent-file-template.md - Updated structure placeholders

FOLLOW-UP ACTIONS:
- None - all placeholders resolved for initial version
-->

## Core Principles

### I. Test-Driven Development (NON-NEGOTIABLE)
**Tests MUST be written and approved before implementation begins.**

Rules:
- Every feature starts with failing tests (Red-Green-Refactor cycle)
- Contract tests validate API endpoints against OpenAPI specifications
- Integration tests verify user story acceptance criteria
- Unit tests cover business logic and edge cases
- Tests are mandatory for all code changes - no exceptions

Rationale: TDD ensures requirements are clearly understood before coding, catches regressions early, and serves as living documentation. Laravel's Pest framework makes this efficient and readable.

### II. API-First Design
**Every feature exposes functionality through well-defined API contracts.**

Rules:
- OpenAPI/Swagger specifications created before implementation
- RESTful conventions followed (proper HTTP methods, status codes, resource naming)
- API contracts validated with contract tests
- JSON responses follow consistent structure: `{data, meta, errors}`
- Versioning strategy: URL-based (`/api/v1/`) for breaking changes

Rationale: API-first design enables frontend-backend parallel development, ensures clear interfaces, and facilitates future integrations. Laravel's API resources provide elegant transformation layer.

### III. Model Integrity
**Eloquent models MUST encapsulate all business rules and validation.**

Rules:
- Database validation in migration files (constraints, foreign keys, indexes)
- Application validation in FormRequest classes
- Business logic encapsulated in model methods, accessors, and mutators
- Relationships defined using Eloquent methods (hasMany, belongsTo, etc.)
- No raw SQL queries except for complex reporting (must be justified)

Rationale: Centralized validation prevents data corruption, Eloquent relationships provide type safety, and model methods ensure consistent business rule application across the application.

### IV. Service Layer Architecture
**Complex business logic MUST reside in dedicated service classes.**

Rules:
- Controllers handle HTTP concerns only (request/response transformation)
- Services contain business logic, orchestration, and transaction management
- Repositories abstract data access patterns when needed
- Services injected via constructor for testability
- Action classes for single-responsibility operations

Rationale: Thin controllers improve testability, services enable logic reuse, and clear separation adheres to SOLID principles. Laravel's service container makes dependency injection seamless.

### V. Observability
**All application behavior MUST be traceable and debuggable.**

Rules:
- Structured logging using Laravel's Log facade (debug, info, warning, error levels)
- Request/response logging for all API endpoints
- Database query logging in non-production environments
- Exception tracking with context (user, request data, stack trace)
- Performance monitoring for slow queries (>100ms threshold)

Rationale: Structured logs enable efficient debugging, request logging aids troubleshooting, and performance monitoring identifies bottlenecks before they impact users.

## Development Standards

### Code Quality
- **Static Analysis**: PHPStan level 6 minimum, Laravel Pint for formatting
- **Documentation**: PHPDoc blocks for all public methods, README for setup
- **Naming**: PascalCase classes, camelCase methods, snake_case database columns
- **Complexity**: Cyclomatic complexity <10, method length <50 lines (IDE warnings at 30)
- **Dependencies**: Minimize external packages, justify all additions

### Security Requirements
- **Authentication**: Laravel Sanctum for API authentication
- **Authorization**: Policy classes for all resource access control
- **Input Validation**: FormRequest classes, never trust user input
- **SQL Injection**: Use Eloquent ORM or parameterized queries exclusively
- **XSS Protection**: Blade escaping enabled by default, validate JSON responses
- **CSRF**: Enabled for web routes, exempted for API routes with Sanctum

### Performance Standards
- **API Response Time**: <200ms p95 for standard CRUD operations
- **Database Queries**: N+1 query detection enabled, eager loading mandatory
- **Caching**: Redis for session, cache, and queue drivers
- **Asset Optimization**: Vite for frontend bundling, lazy loading for routes
- **Scaling**: Stateless design for horizontal scaling, queue jobs for async tasks

## Quality Gates

### Pre-Commit Gates
- [ ] All tests pass (Pest test suite)
- [ ] Laravel Pint formatting applied
- [ ] PHPStan static analysis passes (level 6)
- [ ] No console warnings or errors
- [ ] Database migrations validated (up/down reversible)

### Pre-Deployment Gates
- [ ] Full test suite passes in CI/CD pipeline
- [ ] API documentation updated (OpenAPI specs)
- [ ] Database migrations tested on staging environment
- [ ] Performance benchmarks within thresholds (<200ms p95)
- [ ] Security scan completed (no critical vulnerabilities)
- [ ] Feature branch merged to main via pull request review

## Governance

### Amendment Procedure
1. **Proposal**: Document proposed change with rationale and impact analysis
2. **Review**: Technical lead evaluates alignment with project goals
3. **Approval**: Requires consensus from development team
4. **Migration**: Update dependent templates, agent guidance files, and active features
5. **Communication**: Announce changes in team meeting and update documentation

### Versioning Policy
- **MAJOR (X.0.0)**: Backward incompatible governance changes (e.g., removing a core principle)
- **MINOR (X.Y.0)**: New principles, sections, or material expansions
- **PATCH (X.Y.Z)**: Clarifications, wording improvements, non-semantic fixes

### Compliance Review
- Constitution supersedes all conflicting practices
- All pull requests MUST verify constitutional compliance
- Feature specs and plans MUST include Constitution Check section
- Complexity violations MUST be documented and justified
- Annual review to ensure principles remain relevant

### Development Guidance
- Runtime AI guidance stored in `.specify/templates/agent-file-template.md`
- Agent-specific context files maintained at repository root (e.g., `CLAUDE.md`)
- Templates updated via `.specify/scripts/bash/update-agent-context.sh`

**Version**: 1.0.0 | **Ratified**: 2025-10-02 | **Last Amended**: 2025-10-02
