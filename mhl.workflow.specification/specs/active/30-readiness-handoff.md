# Readiness Handoff

## Verdict
READY

## Conflicts
_None._

## Residuals
- Pin and document the exact supported .NET SDK, Postgres image, and library versions during implementation.
- Prove concurrent/repeatable bootstrap, Unicode title handling, host recreation, test isolation, and Npgsql error redaction through the planned tests.
- Assign local platform owners and reviewers when development begins; future production, external exposure, regulated-data, backup, pagination, or strong-concurrency needs require a new refinement.

## Slices
### SL-1 — infrastructure
- **Goal:** Establish the reproducible local Postgres foundation and API startup path.
- **In Scope:** Pinned .NET and Postgres versions, Docker Compose with one Postgres service, healthcheck, and persistent volume, TODO\_DB\_CONNECTION configuration and safe local default, Idempotent schema bootstrap and bounded connection readiness behavior
- **Out of Scope:** Task business endpoints, Authentication, cloud, production deployment, and schema migration tooling
- **Observable Outcome:** A clean local environment can start a healthy Postgres, initialize the tasks schema automatically, and expose a database-ready API startup path without leaking credentials.
- **Requirements:** RF-6, RF-7, RF-8, RQ-1
- **ADRs:** ADR-002, ADR-004, ADR-005, ADR-009
- **Depends On:** 
- **Contracts:** Postgres is provided by exactly one Compose service with a persistent volume and positive readiness healthcheck., The API reads TODO\_DB\_CONNECTION, uses only the documented local default when explicitly local, and exposes sanitized dependency failures., Startup creates the required tasks schema safely when it is absent or already present.
- **Happy Path:** Compose starts Postgres and waits for health, the API connects using TODO\_DB\_CONNECTION, creates the tasks table idempotently, and becomes ready for database-dependent routes.
- **Failure Path:** If Postgres is unavailable or configuration is invalid, bounded retries end deterministically and startup or affected requests fail without credentials, stack traces, or provider details.
- **Acceptance Criterion:** Two successive documented startup runs succeed against a fresh and an already initialized database, and a configuration/dependency failure is sanitized and deterministic.
- **Suggested Target:** app/docker-compose.yml, app/src/TodoApp.Api/Infrastructure/Database, app/src/TodoApp.Api/Program.cs, app/init.sh
- **Suggested Verification Strategy:** Run Compose readiness and startup twice, exercise fresh-schema initialization, override TODO\_DB\_CONNECTION, and verify bounded failure behavior plus redacted logs.

### SL-2 — cross-cutting-contract
- **Goal:** Define the canonical HTTP/error boundary and preserve the vertical-slice architecture.
- **In Scope:** Stable task representation and status domain, Problem Details mapping for validation, not-found, and dependency failures, Minimal shared kernel and route composition, Validation-before-mutation and redacted structured logging rules
- **Out of Scope:** Endpoint-specific SQL and business behavior, Generic Controller, Service, or Repository layers
- **Observable Outcome:** Every endpoint can use one documented JSON representation and deterministic sanitized Problem Details behavior while operation-specific rules remain in their own slices.
- **Requirements:** RF-9, RQ-3, RQ-4
- **ADRs:** ADR-001, ADR-006, ADR-010
- **Depends On:** SL-1
- **Contracts:** Successful task payloads contain id, titulo, and pendente or concluida status., Errors use application/problem+json with stable public fields and no credentials, stack traces, SQL, hostnames, or provider messages., Each operation owns its request handling, validation, persistence interaction, and response mapping; shared code contains only cross-cutting primitives.
- **Happy Path:** Route composition dispatches a request to its owning feature slice, which returns the canonical task JSON or the shared sanitized error shape.
- **Failure Path:** Invalid input, missing resources, and database failures are classified at the boundary into deterministic 400, 404, or 503 Problem Details without logging sensitive payloads or raw exceptions.
- **Acceptance Criterion:** A structural review finds no generic layers or endpoint-specific rules in the shared kernel, and contract tests confirm deterministic JSON and sanitized Problem Details responses and logs.
- **Suggested Target:** app/src/TodoApp.Api/Infrastructure/Errors, app/src/TodoApp.Api/Domain, app/src/TodoApp.Api/Program.cs
- **Suggested Verification Strategy:** Run contract and negative-path tests, inspect response headers/bodies and captured logs for forbidden internal details, and review the feature/shared-code boundaries.

### SL-3 — vertical-slice-api
- **Goal:** Deliver task creation, listing, and status filtering against real Postgres.
- **In Scope:** POST /tasks with title normalization and pending status, GET /tasks ordered by id, Optional pendente/concluida status filtering, Parameterized SQL, explicit mapping, success and validation responses
- **Out of Scope:** Completion, editing, and deletion, Pagination, authentication, and external deployment
- **Observable Outcome:** A local HTTP client can create tasks and retrieve all or status-filtered tasks with persisted id, titulo, and status in stable JSON.
- **Requirements:** RF-1, RF-2, RF-3
- **ADRs:** ADR-001, ADR-003, ADR-010
- **Depends On:** SL-1, SL-2
- **Contracts:** POST /tasks returns 201 with the created task and Location; invalid or whitespace-only titulo returns 400 Problem Details., GET /tasks returns a 200 array ordered by ascending id and supports only pendente or concluida as status filters., All client values are validated before mutation and persisted through parameterized Npgsql commands.
- **Happy Path:** Posting a trimmed non-empty titulo returns a new pendente task, and subsequent unfiltered or filtered GET requests return the expected ordered records.
- **Failure Path:** A missing, empty, or whitespace-only title and an invalid status filter return 400 without mutation; a database outage returns sanitized 503 Problem Details.
- **Acceptance Criterion:** Real HTTP/Postgres tests prove creation, normalization, empty-list behavior, ordering, both valid filters, invalid input, persistence, and stable response shapes.
- **Suggested Target:** app/src/TodoApp.Api/Features/AddTask, app/src/TodoApp.Api/Features/ListTasks
- **Suggested Verification Strategy:** Use pure unit tests for validation/filter rules and real HttpClient plus Postgres integration tests for create, list, filtering, ordering, invalid input, and dependency failure.

### SL-4 — vertical-slice-api
- **Goal:** Deliver completion, title editing, and removal with correct mutation and not-found semantics.
- **In Scope:** PATCH /tasks/{id}/complete, PUT /tasks/{id} with title normalization, DELETE /tasks/{id}, Affected-row checks, status preservation, idempotent completion, and Problem Details failures
- **Out of Scope:** Reopening tasks, version history, soft deletion, audit, and strong concurrency guarantees
- **Observable Outcome:** A local HTTP client can complete, edit, and remove existing tasks, while repeated completion is safe and missing-task operations do not mutate data.
- **Requirements:** RF-4, RF-5, RF-10
- **ADRs:** ADR-001, ADR-003, ADR-010
- **Depends On:** SL-1, SL-2
- **Contracts:** PATCH /tasks/{id}/complete returns 200 with concluida for an existing task, including an already completed task., PUT /tasks/{id} returns 200 with the normalized replacement titulo and preserves status., DELETE /tasks/{id} returns 204 with no body; missing ids return 404 Problem Details.
- **Happy Path:** An existing task is completed idempotently, edited without changing status, or deleted, and each subsequent read reflects the persisted result.
- **Failure Path:** Invalid ids or titles and nonexistent tasks return deterministic 400 or 404 Problem Details with no unintended mutation; database failures return sanitized 503.
- **Acceptance Criterion:** Real HTTP/Postgres tests prove completion and repetition, editing of pending and completed tasks, deletion, missing-task behavior, and preservation of unaffected fields.
- **Suggested Target:** app/src/TodoApp.Api/Features/CompleteTask, app/src/TodoApp.Api/Features/EditTask, app/src/TodoApp.Api/Features/RemoveTask
- **Suggested Verification Strategy:** Combine pure tests for validation, state transitions, and affected-row decisions with serial real HttpClient/Postgres integration tests for all success and principal failure cases.

### SL-5 — verification
- **Goal:** Prove the complete local behavior, durability, isolation, and reproducibility contract.
- **In Scope:** Pure unit tests and serial real-HTTP/real-Postgres integration tests, Per-case cleanup and identity reset, API-host restart with Postgres and its volume retained, One aggregate verification command with correct exit status
- **Out of Scope:** Cloud CI, production operations, backups, high availability, and performance SLAs
- **Observable Outcome:** One documented verification flow demonstrates all six task operations, principal failures, schema/startup behavior, and task durability across an API-only restart.
- **Requirements:** RQ-2
- **ADRs:** ADR-007, ADR-008
- **Depends On:** SL-3, SL-4
- **Contracts:** The test command is successful only when both unit and integration suites pass., Integration tests use real HTTP and real Postgres, execute serially, and isolate each case without relying on ordering., The API can be recreated while the Postgres service and volume remain available, preserving id, titulo, and status.
- **Happy Path:** The aggregate command runs the pure and integration suites against Compose-managed Postgres, recreates the API host for the durability scenario, and passes repeatedly.
- **Failure Path:** A suite failure, state leak, unavailable dependency, failed restart durability check, or leaked diagnostic produces a non-zero result and an actionable sanitized failure category.
- **Acceptance Criterion:** Individual, full-suite, and two consecutive verification runs cover create, list, filter, complete, edit, remove, validation, not-found, dependency failure, schema initialization, isolation, and API-only restart durability with no gaps.
- **Suggested Target:** app/tests/TodoApp.UnitTests, app/tests/TodoApp.IntegrationTests, app/verify-feature.sh
- **Suggested Verification Strategy:** Run unit tests independently, then serial integration tests individually and as a suite, repeat the aggregate command twice, and inspect the persistence and sanitization assertions.

