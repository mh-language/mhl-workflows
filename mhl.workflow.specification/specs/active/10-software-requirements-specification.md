# Software Requirements Specification

## Functional Requirements
- **RF-1** [G-1]: The API shall accept an unauthenticated JSON POST request to create a task with a non-empty title, persist the task with a generated identifier and initial incomplete status, and return the created task as stable JSON.
- **RF-2** [G-1]: The API shall accept an unauthenticated JSON GET request to list tasks and return stable JSON containing each task's id, title, and status.
- **RF-3** [G-1]: The API shall support filtering the task list by task status and shall return only tasks matching the requested valid status value.
- **RF-4** [G-1]: The API shall accept an unauthenticated request to complete an existing task, persist its status as complete, and return the updated task as stable JSON.
- **RF-5** [G-1]: The API shall accept an unauthenticated JSON request to edit an existing task title, persist the updated title, and return the updated task as stable JSON.
- **RF-6** [G-2]: The API shall persist each task's id, title, and status in Postgres and shall read those records from Postgres for subsequent requests, preserving them when only the API process is stopped and restarted.
- **RF-7** [G-3]: On local startup, the application shall initialize the required task schema in Postgres automatically and shall be safe to run against an already initialized schema.
- **RF-8** [G-3]: The application shall obtain its Postgres connection from TODO\_DB\_CONNECTION, document a safe local default without committing credentials, and fail startup or requests with a sanitized diagnostic when the dependency is unavailable.
- **RF-9** [G-4]: Each task operation shall expose a stable JSON success contract and stable Problem Details responses for invalid input, a missing task, and dependency failures, without credentials, stack traces, or provider-internal details.
- **RF-10** [G-1]: The API shall accept an unauthenticated request to remove an existing task and shall return the documented successful deletion response; attempting to remove a missing task shall return the documented Problem Details response.

## Quality Requirements
- **RQ-1** [G-3]: The local environment shall be reproducible through Docker Compose with one Postgres service, a persistent volume, readiness checks, bounded connection retry behavior, and documented commands for startup and verification.
- **RQ-2** [G-3]: Verification shall include pure unit tests and isolated, serial integration tests using real Postgres and real HTTP, covering all six task operations and their principal failure cases.
- **RQ-3** [G-4]: The implementation shall use Vertical Slice Architecture with operation-specific request handling, validation, persistence interaction, and response mapping, plus only a minimal shared kernel and no generic Controller, Service, or Repository layers.
- **RQ-4** [G-4]: All client-visible validation and dependency-failure responses shall be sanitized and deterministic, and logs shall redact connection secrets and other sensitive configuration values.

## Acceptance Criteria
- **AC-1** (RF-1) — Given The API and Postgres are available, When A client posts a valid non-empty task title, Then The API returns the created task with an id, the submitted title, and incomplete status, and the record is persisted
- **AC-2** (RF-2) — Given Persisted tasks exist, When A client requests the task list, Then The API returns every available task with id, title, and status in the documented JSON shape
- **AC-3** (RF-3) — Given Persisted tasks exist with more than one status, When A client requests a valid status filter, Then The response contains only tasks with that status
- **AC-4** (RF-4) — Given An incomplete task exists, When A client requests completion for that task, Then The API returns success and subsequent reads show the task as complete
- **AC-5** (RF-5) — Given An existing task and a valid replacement title exist, When A client submits the edit request, Then The API returns success and subsequent reads show the replacement title
- **AC-6** (RF-6) — Given A task has been created and Postgres remains available, When Only the API process is stopped and restarted, Then A subsequent list or get operation returns the same task id, title, and status
- **AC-7** (RF-1, RF-3, RF-9) — Given A client submits invalid task input or an invalid status filter, When The API validates the request, Then It returns a stable Problem Details response with an appropriate client error status and no internal diagnostic
- **AC-8** (RF-4, RF-5, RF-9) — Given A client references a task that does not exist, When The client requests completion or editing, Then The API returns the documented not-found Problem Details response
- **AC-9** (RF-6) — Given The Postgres service and its persistent volume are available, When The API is restarted without recreating the database volume, Then Previously persisted task data remains available
- **AC-10** (RF-7) — Given A clean local Postgres database is available, When The API starts, Then The required schema is created automatically and a second startup does not fail because the schema already exists
- **AC-11** (RF-8) — Given TODO\_DB\_CONNECTION is configured or the documented safe local default is used, When The application starts, Then It attempts to connect using that configuration and does not expose credentials in responses or logs
- **AC-12** (RF-8, RF-9, RQ-4) — Given Postgres is unavailable or a database operation fails, When A client invokes an affected endpoint, Then The API returns a stable sanitized Problem Details response containing no credentials, stack trace, or provider-internal detail
- **AC-13** (RF-10) — Given An existing task is available, When A client requests its removal, Then The API returns the documented deletion success response and subsequent list or get operations no longer return the task; a missing task returns not-found Problem Details
- **AC-14** (RQ-1) — Given A clean checkout with Docker available, When The documented Compose startup and verification sequence is run, Then Postgres becomes ready through the health check, the API connects with bounded retries, and the sequence completes reproducibly
- **AC-15** (RQ-2) — Given The project is checked out and local dependencies are available, When The documented test command is run, Then Pure unit tests and isolated serial real-HTTP/real-Postgres integration tests execute and cover create, list, filter, complete, edit, remove, validation, not-found, durability, and dependency-failure behavior
- **AC-16** (RQ-3) — Given The implementation is reviewed, When The task operation code is inspected, Then Each operation remains cohesive in its vertical slice and no generic Controller, Service, or Repository layer has been introduced
- **AC-17** (RQ-4) — Given Validation and dependency-failure tests are run, When Their responses and captured logs are inspected, Then The payloads and logs are deterministic and redact credentials, stack traces, and provider internals

## Interfaces
- **IF-1** (RF-1, RF-2, RF-3, RF-4, RF-5, RF-9, RF-10) Task JSON HTTP API: Unauthenticated local HTTP clients use JSON endpoints for create, list, status filtering, complete, edit, and remove operations.
- **IF-2** (RF-6, RF-7, RF-8) Local Postgres: The API reads and writes task records through the Postgres connection configured by TODO\_DB\_CONNECTION.
- **IF-3** (RF-6, RF-7, RQ-1, RQ-2) Docker Compose local runtime: Docker Compose provides the local Postgres service, readiness check, and persistent volume used by the API and integration tests.

## Data Rules
- **DR-1** (RF-1, RF-2, RF-3, RF-4, RF-5, RF-6, RF-9): Every task shall have a generated stable id, a non-empty title after trimming, and a status restricted to the documented incomplete or complete values.
- **DR-2** (RF-4, RF-5, RF-6, RF-10): Task mutations shall be persisted in Postgres; completion and editing shall update the existing record, while removal shall make the record unavailable to subsequent reads.
- **DR-3** (RF-8, RF-9, RQ-4): Client-visible failure payloads and logs shall not include connection credentials, stack traces, or provider-internal diagnostics.

## Delivery
- **Target:** A greenfield local .NET/C\# ASP.NET Core task-management Web API backed by Postgres and Docker Compose, with no frontend, identity, cloud deployment, migration, or regulated-data scope.
- **Verification Strategy:** Run the documented Docker Compose setup, verify automatic schema initialization and API-only restart durability, then run pure unit tests and isolated serial real-HTTP/real-Postgres integration tests for all six operations and failure contracts.
- **Bootstrap:** yes
