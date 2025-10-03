# Tasks: [FEATURE NAME]

**Input**: Design documents from `/specs/[###-feature-name]/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 3.1: Setup
- [ ] T001 Create project structure per implementation plan
- [ ] T002 Initialize [language] project with [framework] dependencies
- [ ] T003 [P] Configure linting and formatting tools

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3
**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**
- [ ] T004 [P] Contract test POST /api/v1/users in tests/Feature/Api/CreateUserTest.php
- [ ] T005 [P] Contract test GET /api/v1/users/{id} in tests/Feature/Api/GetUserTest.php
- [ ] T006 [P] Integration test user registration in tests/Feature/RegistrationTest.php
- [ ] T007 [P] Integration test auth flow in tests/Feature/AuthTest.php

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [ ] T008 [P] User model with validation in app/Models/User.php
- [ ] T009 [P] CreateUserRequest validation in app/Http/Requests/CreateUserRequest.php
- [ ] T010 [P] UserService business logic in app/Services/UserService.php
- [ ] T011 POST /api/v1/users endpoint in app/Http/Controllers/Api/UserController.php
- [ ] T012 GET /api/v1/users/{id} endpoint in app/Http/Controllers/Api/UserController.php
- [ ] T013 UserResource API transformation in app/Http/Resources/UserResource.php
- [ ] T014 Error handling middleware and logging

## Phase 3.4: Integration
- [ ] T015 Database migration for users table in database/migrations/*_create_users_table.php
- [ ] T016 API routes in routes/api.php
- [ ] T017 Sanctum authentication middleware configuration
- [ ] T018 Request/response logging middleware
- [ ] T019 CORS configuration in config/cors.php

## Phase 3.5: Polish
- [ ] T020 [P] Unit tests for validation in tests/Unit/ValidationTest.php
- [ ] T021 Performance tests (<200ms p95) in tests/Feature/PerformanceTest.php
- [ ] T022 [P] OpenAPI documentation in docs/api/openapi.yaml
- [ ] T023 Remove code duplication (run Laravel Pint)
- [ ] T024 PHPStan static analysis (level 6)

## Dependencies
- Tests (T004-T007) before implementation (T008-T014)
- T008 blocks T009, T015
- T016 blocks T018
- Implementation before polish (T019-T023)

## Parallel Example
```
# Launch T004-T007 together:
Task: "Contract test POST /api/users in tests/contract/test_users_post.py"
Task: "Contract test GET /api/users/{id} in tests/contract/test_users_get.py"
Task: "Integration test registration in tests/integration/test_registration.py"
Task: "Integration test auth in tests/integration/test_auth.py"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
   
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   
3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task