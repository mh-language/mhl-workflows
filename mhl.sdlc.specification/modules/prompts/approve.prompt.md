Manual approval gate for the Specification run before publication (blueprint
0004 §5 / §6 "Publicação segura"). Codex must not approve on the human's behalf.

When `review` returns `READY` the run pauses at `awaiting_approval` / phase
`approve`. The four accepted documents are on disk:

- PRD: `${prd_path}`
- SRS: `${srs_path}`
- SDD: `${sdd_path}`
- Readiness: `${readiness_path}`

Review them. To publish, re-invoke the workflow with a single boolean input:

```json
{ "approved": true }
```

- `approved: true` runs the pre-publish development-readiness gate and, if it
  passes, renders and publishes the bundle to `specs/active/` (`00-prd.md`,
  `10-software-requirements-specification.md`, `20-software-design-document.md`,
  `30-readiness-handoff.md`, `40-development-plan.json`), then the run completes.
- Any other value (or omitting it) leaves the run parked at `awaiting_approval`
  so it can be re-invoked later. There is no in-flow "revise" route: to force
  another pass, start a fresh run.
