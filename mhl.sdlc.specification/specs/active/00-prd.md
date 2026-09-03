# Product Requirements Document

## Vision
Provide a reproducible local TodoApp WebAPI that enables an HTTP client to manage tasks through a stable JSON and Problem Details contract, while retaining task data in Postgres across API-only restarts and remaining easy to verify.

## Goals
- **G-1:** Enable an HTTP client to create, list, filter, complete, edit, and remove tasks through cohesive canonical API endpoints.
- **G-2:** Persist each task's identifier, normalized title, and pending or completed status in local Postgres, including across API-only restarts.
- **G-3:** Make fresh setup and verification repeatable through Docker Compose, automatic schema initialization, isolated unit tests, and real HTTP/Postgres integration tests.
- **G-4:** Provide dependable failure behavior by validating inputs, externalizing configuration, parameterizing database operations, and returning sanitized Problem Details.

## Success Metrics
- **M-1** (G-1): Defined task lifecycle and query scenarios exercised against the API -> 100% of create, list, filter, complete, edit, and remove scenarios pass with the documented JSON contract and expected status codes
- **M-2** (G-2): Task records and status transitions verified in real Postgres -> Every persisted task contains an id, normalized title, and pending/completed status, and remains queryable after an API-only restart
- **M-3** (G-3): Repeatability of the local startup and verification flow -> One idempotent documented command starts or checks Postgres, initializes a fresh schema automatically, and runs all required unit and integration tests without manual sequencing
- **M-4** (G-4): Invalid-input, not-found, conflict, and database-failure responses inspected for safety -> Covered failures return stable sanitized Problem Details and expose neither credentials, task content, SQL details, stack traces, nor other internal failure information

## Non-Goals
- Frontend, browser UI, or client SDK.
- Authentication, authorization, multiple-user support, external exposure, or regulated data handling.
- Cloud or production deployment, production operations, or SLA commitments.
- Migration from legacy or JSON persistence.
- Pagination, backup and restore workflows, or strong-concurrency guarantees.

## Scope
- A .NET/C\# ASP.NET Core WebAPI with canonical endpoints for task creation, listing, filtering, completion, editing, and removal.
- Local Postgres persistence with automatic schema setup for a fresh database and a retained Docker Compose volume.
- Task title normalization and validation, valid identifier handling, and documented not-found or conflict behavior where applicable.
- One vertical slice per endpoint with only a minimal shared kernel; no generic Controller, Service, or Repository layers.
- External database configuration through TODO\_DB\_CONNECTION with a documented local default and no credentials in source-controlled responses or logs.
- Pure unit tests for rules and real HTTP/Postgres integration tests covering the lifecycle, restart durability, and sanitized failures.
- A single idempotent local startup and verification flow for database readiness, schema initialization, API execution, and tests.

## Risks
- **R-1** (high): Postgres readiness or version differences may make local startup and integration tests flaky. — mitigation: Pin the Postgres image and supported dependency versions, add readiness checks, and make the verification flow wait for a healthy database before proceeding.
- **R-2** (medium): A retained volume or repeated run may leave schema or test data in an unexpected state. — mitigation: Make schema initialization idempotent, define an explicit local database contract, and isolate test data without implicitly deleting the retained volume.
- **R-3** (medium): Inconsistent validation or status-transition rules could produce an unpredictable task contract. — mitigation: Document canonical task states and endpoint behavior, keep shared rules minimal and explicit, and cover success and failure paths with unit and integration tests.
- **R-4** (high): Configuration mistakes, injection-prone queries, or unhandled exceptions could leak secrets or internal details. — mitigation: Externalize the connection string, parameterize all database operations, validate before mutation, and map failures centrally to sanitized Problem Details with security-focused tests.
- **R-5** (low): Over-abstraction could weaken vertical-slice cohesion and increase maintenance cost. — mitigation: Review each endpoint as an independently traceable slice and allow shared code only for concerns proven to be cross-cutting.

## Decisions
- **D-1:** Use .NET/C\#, ASP.NET Core, Postgres, and Docker Compose as the required implementation and local verification stack. — rationale: These are accepted idea constraints and establish the intended reproducible HTTP-plus-relational boundary.
- **D-2:** Represent a task canonically by its identifier, normalized title, and pending or completed status. — rationale: This is the smallest persisted model that supports the requested task lifecycle and filtering behavior.
- **D-3:** Implement one vertical slice per endpoint and avoid generic Controller, Service, and Repository layers. — rationale: Endpoint-focused cohesion is an explicit constraint and keeps behavior, validation, persistence, and tests easy to trace.
- **D-4:** Use real HTTP and real Postgres for integration tests, complemented by pure unit tests, with no mocks or in-memory persistence substitutes. — rationale: The product must prove behavior at the same local boundaries that users and operators will exercise.
- **D-5:** Read the database connection from TODO\_DB\_CONNECTION and provide only a documented local default. — rationale: Externalized configuration supports local reproducibility without embedding environment-specific credentials.
- **D-6:** Use sanitized Problem Details as the failure contract and prevent sensitive or internal details from reaching clients or logs. — rationale: Clients need predictable diagnostics while the local API must avoid information leakage.

## Open Questions
_None._
