# Software Requirements Specification

## Functional Requirements
- **RF-1** [G-1, G-2]: The API shall create a task from a valid title, assign a unique identifier, normalize and persist the title with pending status, and return the canonical task representation with the documented success status and JSON shape.
- **RF-2** [G-1, G-2]: The API shall list persisted tasks and support the documented pending/completed status filter, returning canonical task representations from Postgres in the documented JSON shape.
- **RF-3** [G-1, G-2]: The API shall complete an existing pending task through its canonical endpoint, persist the completed status, and return the updated canonical task; repeated completion shall follow the documented conflict or idempotency behavior.
- **RF-4** [G-1, G-2, G-4]: The API shall edit the title of an existing task only when the supplied identifier and title are valid, normalize and persist the new title, and return the updated canonical task.
- **RF-5** [G-1, G-2]: The API shall remove an existing task through its canonical endpoint and return the documented success response; subsequent retrieval or listing shall no longer expose the removed task.
- **RF-6** [G-1, G-4]: The API shall validate identifiers, required fields, title constraints, status-filter values, not-found conditions, and applicable state conflicts before mutation, using the documented HTTP status codes and sanitized Problem Details failure contract.
- **RF-7** [G-2, G-3]: The application shall store each task in Postgres with an identifier, normalized non-empty title, and pending/completed status, enforce the valid status representation, initialize the schema idempotently, and preserve task data across an API-only restart.
- **RF-8** [G-3]: The project shall provide one documented, repeatable Docker Compose startup and verification flow that waits for healthy pinned Postgres, initializes a fresh database automatically, starts the API, and runs unit and real HTTP/Postgres integration tests without manual sequencing.
- **RF-9** [G-4]: The application shall read its database connection from TODO\_DB\_CONNECTION, provide only a documented local default, parameterize every database operation, and avoid placing credentials in source-controlled responses or logs.

## Quality Requirements
- **RQ-1** [G-3]: Each endpoint shall be implemented as an independently traceable vertical slice, with only a minimal shared kernel for proven cross-cutting concerns and no generic Controller, Service, or Repository layers.
- **RQ-2** [G-3]: Automated verification shall include pure unit tests for normalization, validation, and state rules plus integration tests using real HTTP and real Postgres, with no mocks or in-memory persistence substitutes.
- **RQ-3** [G-3]: Local execution shall be repeatable and idempotent: readiness checks, schema initialization, and test setup shall tolerate a fresh database and a retained Compose volume without implicitly deleting retained data.
- **RQ-4** [G-4]: Failure handling shall map expected and unexpected failures to stable sanitized Problem Details and shall not expose credentials, task content beyond the response contract, SQL details, stack traces, or other internal failure information to clients or logs.

## Acceptance Criteria
- **AC-1** (RF-1) — Given The API and healthy Postgres are running and the client submits a valid task title, When The client calls the create-task endpoint, Then The response has the documented success status and canonical JSON task shape, with a unique identifier, normalized title, and pending status; the same record is present in Postgres
- **AC-2** (RF-2) — Given Postgres contains pending and completed tasks, When The client calls the list endpoint with no filter and with each documented status filter, Then Each response contains exactly the matching canonical tasks and excludes tasks with other statuses
- **AC-3** (RF-3) — Given A pending task exists, When The client calls the complete endpoint for its identifier, Then The response returns the task as completed, and a subsequent list or retrieval observes completed status persisted in Postgres; the documented repeated-completion behavior is returned on a second call
- **AC-4** (RF-4) — Given A task exists and the client submits a valid replacement title, When The client calls the edit endpoint for its identifier, Then The response and Postgres record contain the normalized replacement title while preserving the task identifier and valid status
- **AC-5** (RF-5) — Given A task exists, When The client calls the remove endpoint for its identifier and then lists or retrieves tasks, Then The remove response has the documented success status and the task is absent from subsequent results
- **AC-6** (RF-6) — Given The client submits an invalid identifier, invalid title or filter, a missing task identifier, or an invalid state transition, When The client calls the applicable endpoint, Then The API performs no unintended mutation and returns the documented status with sanitized Problem Details containing stable diagnostic fields and no stack trace or SQL/credential details
- **AC-7** (RF-7) — Given A fresh Postgres database or an existing database with tasks is available, When The API starts, initializes the schema, creates tasks, and is restarted without removing the database volume, Then Schema initialization succeeds idempotently, records satisfy the identifier/title/status rules, and previously created tasks remain queryable after restart
- **AC-8** (RF-8) — Given Docker Compose and the documented project prerequisites are available, When An operator runs the single documented verification command, Then The command waits for database readiness, starts the API, applies schema setup, executes all unit and real HTTP/Postgres integration tests, and reports success without manual ordering
- **AC-9** (RF-9) — Given TODO\_DB\_CONNECTION is set or the documented local default is used, When The API and tests connect to Postgres and execute database operations, Then The configured connection is used, all database values are parameterized, and credentials do not appear in source-controlled output, client responses, or logs
- **AC-10** (RQ-1) — Given The implementation is reviewed endpoint by endpoint, When A reviewer traces an endpoint from HTTP input through validation, persistence, response, and tests, Then The behavior is contained in one vertical slice, with only justified shared cross-cutting code and no generic Controller, Service, or Repository layer
- **AC-11** (RQ-2) — Given The test suite is run through the documented verification flow, When Unit and integration tests execute, Then Pure rule tests run without external dependencies and lifecycle/failure integration tests use real HTTP and real Postgres with no mocks or in-memory persistence
- **AC-12** (RQ-3) — Given The verification flow is run once against a fresh database and again against a retained Compose volume, When Both runs perform readiness, schema initialization, and tests, Then Both runs complete deterministically, schema setup is idempotent, and retained data is not implicitly deleted
- **AC-13** (RQ-4) — Given Validation, not-found, conflict, database, and unexpected failures are induced in a local run, When The API returns errors and writes diagnostics, Then Clients receive only the documented sanitized Problem Details and neither clients nor logs contain credentials, SQL details, stack traces, or unrelated internal data

## Interfaces
_None._

## Data Rules
_None._

## Delivery
- **Target:** A .NET/C\# ASP.NET Core WebAPI task-management vertical slice backed by local Postgres and Docker Compose, with canonical JSON and sanitized Problem Details contracts.
- **Verification Strategy:** Run the documented Docker Compose flow with readiness checks, idempotent schema initialization, pure unit tests, and real HTTP/Postgres integration tests covering the complete lifecycle, restart durability, validation, conflicts, and sanitized failures.
- **Bootstrap:** yes
