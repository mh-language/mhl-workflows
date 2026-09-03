# Readiness Handoff

## Verdict
READY

## Conflicts
_None._

## Residuals
_None._

## Slices
### SL-1 — infrastructure
- **Goal:** Provide the durable local Postgres foundation and safe database configuration.
- **In Scope:** Pinned Docker Compose Postgres service and healthcheck, Persistent volume contract, TODO\_DB\_CONNECTION with documented local default, Singleton NpgsqlDataSource, Idempotent tasks schema with identifier, title, and status constraints
- **Out of Scope:** Endpoint-specific HTTP behavior, Authentication, cloud deployment, backups, and schema migrations
- **Observable Outcome:** A fresh or retained Compose database becomes healthy, the API can connect using the configured connection, and startup creates the valid tasks schema without deleting retained data.
- **Requirements:** RF-7, RF-9, RQ-3
- **ADRs:** ADR-3, ADR-4, ADR-5, ADR-6, ADR-9
- **Depends On:** 
- **Contracts:** tasks table stores positive bigint id, trimmed non-empty title, and status in pendente or concluida, database connection comes from TODO\_DB\_CONNECTION or the documented local-only default, schema bootstrap is idempotent and API-only restarts retain the Compose volume
- **Happy Path:** Compose reports healthy Postgres, the API opens its configured data source, applies CREATE TABLE IF NOT EXISTS, and serves against the retained database.
- **Failure Path:** Unavailable or misconfigured Postgres fails through the sanitized dependency boundary; credentials and raw driver details are absent from responses and logs.
- **Acceptance Criterion:** Starting against both a fresh database and a retained volume succeeds deterministically, preserves existing tasks across an API-only restart, and never emits connection credentials or raw SQL details.
- **Suggested Target:** app/docker-compose.yml, app/src/TodoApp.Api/Infrastructure/Database/, app/src/TodoApp.Api/Program.cs
- **Suggested Verification Strategy:** Run Compose readiness and schema bootstrap twice, inspect the schema in real Postgres, override TODO\_DB\_CONNECTION, restart only the API, and assert retained rows and redacted failure output.

### SL-2 — feature
- **Goal:** Create pending tasks through the canonical HTTP contract.
- **In Scope:** POST /tasks, titulo trimming and validation, Positive identifier generation, Parameterized insert and explicit row mapping, 201 response and Location header
- **Out of Scope:** Listing, completion, editing, and removal, Generic service or repository layers
- **Observable Outcome:** A valid create request returns exactly the canonical task representation with normalized title and pending status, and the same row exists in Postgres.
- **Requirements:** RF-1, RQ-1, RQ-2
- **ADRs:** ADR-1, ADR-2, ADR-3, ADR-7, ADR-10
- **Depends On:** SL-1
- **Contracts:** POST /tasks accepts JSON titulo, success is 201 with id, titulo, and status=pendente, all client-supplied database values are parameterized
- **Happy Path:** The slice trims a valid title, inserts a pending row, maps only the public fields, and returns 201 with Location.
- **Failure Path:** Missing, empty-after-trim, or otherwise invalid titles are rejected before mutation with sanitized Problem Details.
- **Acceptance Criterion:** A real HTTP integration test verifies status, JSON shape, Location, normalization, and the corresponding real Postgres row; pure tests cover title rules.
- **Suggested Target:** app/src/TodoApp.Api/Features/AddTask/, app/tests/TodoApp.UnitTests/Features/AddTask/, app/tests/TodoApp.IntegrationTests/
- **Suggested Verification Strategy:** Exercise valid, whitespace, Unicode, and invalid-title requests through HttpClient and verify the database row and absence of sensitive diagnostics.

### SL-3 — feature
- **Goal:** List tasks in identifier order with an exact pending/completed filter.
- **In Scope:** GET /tasks, Optional status query validation, Ascending id ordering, Parameterized Postgres query and canonical array response
- **Out of Scope:** Pagination, sorting options, and task mutation, Additional task fields
- **Observable Outcome:** The list endpoint returns all tasks or exactly those matching the documented status filter, in ascending identifier order.
- **Requirements:** RF-2, RQ-1, RQ-2
- **ADRs:** ADR-1, ADR-2, ADR-3, ADR-7, ADR-10
- **Depends On:** SL-1, SL-2
- **Contracts:** GET /tasks returns 200 and a canonical task array, status accepts only pendente or concluida, invalid filters return 400 Problem Details without querying or mutating data
- **Happy Path:** The slice validates the optional filter, executes a parameterized ordered query, and maps each row to id, titulo, and status.
- **Failure Path:** An unsupported status value returns sanitized 400 Problem Details and leaves the database unchanged.
- **Acceptance Criterion:** Real HTTP/Postgres tests prove unfiltered listing, both exact filters, ordering, empty results, and invalid-filter behavior.
- **Suggested Target:** app/src/TodoApp.Api/Features/ListTasks/, app/tests/TodoApp.UnitTests/Features/ListTasks/, app/tests/TodoApp.IntegrationTests/
- **Suggested Verification Strategy:** Seed pending and completed rows in real Postgres, call each list variant through HttpClient, and assert exact membership, order, shape, and failure content type.

### SL-4 — feature
- **Goal:** Complete tasks through an idempotent canonical state transition.
- **In Scope:** PATCH /tasks/{id}/complete, Positive id validation, Parameterized status update and affected-row handling, Repeated completion semantics
- **Out of Scope:** Concurrency guarantees beyond the local scope, Editing or removing tasks
- **Observable Outcome:** A pending task becomes concluida in the response and Postgres, while repeating completion returns the documented idempotent success.
- **Requirements:** RF-3, RQ-1, RQ-2
- **ADRs:** ADR-1, ADR-3, ADR-7, ADR-10
- **Depends On:** SL-1, SL-2
- **Contracts:** PATCH /tasks/{id}/complete returns 200 with the completed canonical task, invalid ids return 400 and missing ids return 404 Problem Details, completion is idempotent for an already completed task
- **Happy Path:** The slice validates the id, updates status to concluida, maps the task, and returns 200; a second call returns the same completed representation.
- **Failure Path:** Invalid identifiers are rejected before SQL and a missing task produces sanitized 404 without unintended mutation.
- **Acceptance Criterion:** Unit and real HTTP/Postgres tests verify pending-to-completed persistence, repeated completion, invalid ids, missing tasks, and sanitized errors.
- **Suggested Target:** app/src/TodoApp.Api/Features/CompleteTask/, app/tests/TodoApp.UnitTests/Features/CompleteTask/, app/tests/TodoApp.IntegrationTests/
- **Suggested Verification Strategy:** Create a task through the API, complete it twice, inspect both responses and the database, then exercise invalid and nonexistent identifiers.

### SL-5 — feature
- **Goal:** Edit an existing task title while preserving its identifier and status.
- **In Scope:** PUT /tasks/{id}, Identifier and titulo validation, Title normalization, Parameterized update and explicit mapping
- **Out of Scope:** Status changes, history, versioning, and concurrency guarantees, Additional editable fields
- **Observable Outcome:** A valid edit returns and persists the normalized replacement title without changing the task id or status.
- **Requirements:** RF-4, RQ-1, RQ-2
- **ADRs:** ADR-1, ADR-3, ADR-7, ADR-10
- **Depends On:** SL-1, SL-2
- **Contracts:** PUT /tasks/{id} accepts JSON titulo and returns 200 with the canonical task, valid status is preserved, invalid id/title returns 400 and missing task returns 404 Problem Details
- **Happy Path:** The slice validates and trims titulo, updates only title, and returns the existing id and status with the normalized replacement.
- **Failure Path:** Invalid input is rejected before mutation and a nonexistent task produces sanitized 404.
- **Acceptance Criterion:** Real HTTP/Postgres tests edit both pending and completed tasks and verify title normalization, status preservation, row state, and failure behavior.
- **Suggested Target:** app/src/TodoApp.Api/Features/EditTask/, app/tests/TodoApp.UnitTests/Features/EditTask/, app/tests/TodoApp.IntegrationTests/
- **Suggested Verification Strategy:** Create tasks in both states, submit valid and invalid replacements through HttpClient, and compare response and database records.

### SL-6 — feature
- **Goal:** Remove an existing task through the canonical delete contract.
- **In Scope:** DELETE /tasks/{id}, Identifier validation, Parameterized delete and affected-row check, 204 empty-body success
- **Out of Scope:** Soft deletion, audit history, restore, and bulk operations, Backup and retention workflows
- **Observable Outcome:** Deleting an existing task returns 204 with no body and the task is absent from later results.
- **Requirements:** RF-5, RQ-1, RQ-2
- **ADRs:** ADR-1, ADR-3, ADR-7, ADR-10
- **Depends On:** SL-1, SL-2, SL-3
- **Contracts:** DELETE /tasks/{id} returns 204 with no response body, invalid ids return 400 and missing ids return sanitized 404, successful deletion is visible in subsequent listing or retrieval
- **Happy Path:** The slice validates the id, deletes one row, checks the affected count, and returns 204.
- **Failure Path:** Invalid or nonexistent identifiers do not mutate data and return the documented sanitized Problem Details.
- **Acceptance Criterion:** A real HTTP/Postgres test proves 204 no-body behavior, physical absence after deletion, invalid-id rejection, and missing-task handling.
- **Suggested Target:** app/src/TodoApp.Api/Features/RemoveTask/, app/tests/TodoApp.UnitTests/Features/RemoveTask/, app/tests/TodoApp.IntegrationTests/
- **Suggested Verification Strategy:** Create a task, delete it through HttpClient, assert the exact response and query real Postgres through the API, then test invalid and missing ids.

### SL-7 — cross-cutting contract
- **Goal:** Enforce the shared validation and sanitized failure boundary across all slices.
- **In Scope:** Stable application/problem+json fields, Expected validation, not-found, conflict, dependency, and unexpected failure mapping, Redaction of credentials, SQL, driver details, stack traces, and unintended task content, Validation-before-mutation policy
- **Out of Scope:** Authentication and authorization, Production observability, external secret management, and public exposure
- **Observable Outcome:** Every documented failure returns stable sanitized Problem Details and no sensitive or internal details reach clients or logs.
- **Requirements:** RF-6, RQ-4
- **ADRs:** ADR-1, ADR-3, ADR-6, ADR-9, ADR-10
- **Depends On:** SL-1
- **Contracts:** Errors use application/problem+json with type, title, status, detail, and instance, Validation occurs before mutable database operations, Public and logged diagnostics omit credentials, SQL, stack traces, raw driver details, and unrelated task content
- **Happy Path:** Endpoint slices return canonical success responses while the shared boundary consistently serializes expected failures.
- **Failure Path:** Induced validation, missing-task, dependency, and unexpected failures are mapped to stable sanitized responses and redacted diagnostics.
- **Acceptance Criterion:** Failure-focused unit and integration tests verify status/content type/stable fields, no unintended mutation, and absence of forbidden details in response and logs.
- **Suggested Target:** app/src/TodoApp.Api/Infrastructure/Errors/, app/src/TodoApp.Api/Program.cs, app/tests/TodoApp.UnitTests/, app/tests/TodoApp.IntegrationTests/
- **Suggested Verification Strategy:** Induce each documented failure class against real HTTP and Postgres, capture response/log output, and assert the redaction and pre-mutation guarantees.

### SL-8 — verification and delivery
- **Goal:** Provide one repeatable local command that verifies the complete application lifecycle.
- **In Scope:** Documented init.sh or equivalent aggregate command, Compose readiness and startup sequencing, Pure unit suite, Real HTTP/Postgres integration suite, Serial isolation, repeated runs, and API-host restart durability
- **Out of Scope:** CI/CD, production deployment, cloud operations, and SLA measurement, Implicit deletion of retained volumes
- **Observable Outcome:** One documented command waits for healthy Postgres, starts the API with schema ready, runs both suites, propagates failures, and succeeds on fresh and retained-volume runs.
- **Requirements:** RF-8, RQ-2, RQ-3
- **ADRs:** ADR-2, ADR-4, ADR-5, ADR-7, ADR-8
- **Depends On:** SL-2, SL-3, SL-4, SL-5, SL-6, SL-7
- **Contracts:** The aggregate verification command waits for database health and returns nonzero on any failed suite, Unit tests have no external dependency; integration tests use real HTTP and real Postgres, Integration setup is serial and idempotent without deleting the retained Compose volume
- **Happy Path:** The command brings up the local stack, runs isolated unit and integration coverage, repeats successfully, and verifies API-host recreation with retained data.
- **Failure Path:** Readiness or test failure stops the aggregate flow with a nonzero exit code and does not falsely report success from textual output.
- **Acceptance Criterion:** Fresh-database and retained-volume executions both complete deterministically, cover the complete lifecycle and failures, and demonstrate restart durability with real infrastructure.
- **Suggested Target:** app/init.sh, app/verify-feature.sh, app/tests/TodoApp.IntegrationTests/Fixtures/, app/README.md
- **Suggested Verification Strategy:** Run the single documented command twice against a fresh then retained volume, run suites individually and together, and assert exit-code propagation, isolation, and restart coverage.

