# Product Requirements Document

## Vision
Give local unauthenticated HTTP clients a dependable Todo API whose task data survives API-only restarts and whose behavior can be verified reproducibly against real Postgres.

## Goals
- **G-1:** Deliver a cohesive JSON HTTP API for creating, listing, filtering, completing, editing, and removing tasks.
- **G-2:** Persist task id, title, and status in local Postgres and preserve them across API-only restarts.
- **G-3:** Make local startup and verification reproducible, including automatic schema initialization and real HTTP/Postgres integration tests.
- **G-4:** Keep the implementation maintainable through Vertical Slice Architecture, minimal shared code, input validation, and sanitized dependency failures.

## Success Metrics
- **M-1** (G-1): Supported task-management operations that have documented request, response, and Problem Details behavior -> 6 of 6 operations implemented and covered by contract-level tests
- **M-2** (G-2): Task records retained after stopping and restarting only the API process while Postgres remains available -> 100% of verification runs retain id, title, and status for previously created tasks
- **M-3** (G-3): Clean local environment verification flow using Docker Compose and the documented database connection configuration -> One command or documented command sequence passes pure unit tests and isolated serial HTTP/Postgres integration tests
- **M-4** (G-4): Failure and validation cases exposed to clients without internal details -> All invalid-input and dependency-failure tests return stable Problem Details responses with no credentials, stack traces, or internal diagnostics

## Non-Goals
- Frontend or user interface development
- Users, authentication, authorization, or multi-tenant behavior
- Cloud, production, or deployment operational support
- Legacy or JSON-file data migration
- Regulated-data handling or compliance claims

## Scope
- A .NET/C\# ASP.NET Core Web API for unauthenticated local HTTP clients
- Six task operations: create, query/list, filter, complete, edit, and remove
- Stable JSON responses and Problem Details responses for validation and sanitized failures
- Postgres persistence with one Docker Compose local Postgres service and a persistent volume
- Automatic local schema initialization and connection configuration through TODO\_DB\_CONNECTION with a documented local default
- Vertical Slice Architecture with a minimal shared kernel and no generic Controller, Service, or Repository layers
- Pure unit tests plus isolated, serial integration tests using real Postgres and real HTTP

## Risks
- **R-1** (high): Local Postgres startup timing or connection configuration may make startup and tests flaky. — mitigation: Use Docker Compose health/readiness checks, bounded retry behavior, a persistent volume, and a documented TODO\_DB\_CONNECTION default; keep integration tests isolated and serial.
- **R-2** (medium): Inconsistent validation or error payloads could make HTTP clients and tests depend on implementation details. — mitigation: Define the JSON and Problem Details contract up front and cover success, invalid input, missing task, and dependency-failure cases in endpoint tests.
- **R-3** (medium): Over-generalized abstractions could dilute vertical-slice cohesion and increase maintenance cost. — mitigation: Keep each operation's request handling, validation, persistence interaction, and response mapping close to its slice; extract only genuinely shared kernel concerns.
- **R-4** (high): Configuration or database failures could accidentally disclose credentials or internal failure details. — mitigation: Log and return sanitized errors, redact connection secrets, and test that external responses never contain credentials, stack traces, or provider internals.

## Decisions
- **D-1:** Use .NET/C\#, ASP.NET Core, Postgres, and Docker Compose as the implementation baseline. — rationale: This matches the accepted idea's required local technology and infrastructure constraints.
- **D-2:** Use Vertical Slice Architecture with a minimal shared kernel and no generic Controller, Service, or Repository layers. — rationale: The operation-oriented API benefits from cohesive slices and avoids abstractions that obscure task behavior.
- **D-3:** Use real Postgres for integration tests and execute them in isolated, serial runs. — rationale: Persistence behavior and restart durability are core product outcomes and cannot be established by mocks or in-memory storage alone.
- **D-4:** Configure the database through TODO\_DB\_CONNECTION, documenting only a safe local default. — rationale: This supports reproducible local setup without committing credentials or exposing them through the API.
- **D-5:** Limit the product to greenfield local development and test use. — rationale: The accepted idea explicitly excludes frontend, identity, cloud or production deployment, migration, and regulated-data claims.

## Open Questions
_None._
