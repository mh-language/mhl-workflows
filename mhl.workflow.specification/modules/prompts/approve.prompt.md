Review the bundle for this Specification run before publication (blueprint 0004 §5
ApprovalEvaluator, §6 Publicação segura).

${preview}

The four accepted documents are on disk:

- PRD: `${prd_path}`
- SRS: `${srs_path}`
- SDD: `${sdd_path}`
- Readiness: `${readiness_path}`

The current bundle digest is `${bundle_digest}`.

Write a JSON OBJECT to the file `${proposal_path}` (a real file, written with your
file-write tool — NOT escaped or embedded in your reply) with this shape:

```json
{"decision":"approved","bundleDigest":"${bundle_digest}","rationale":"...","approvedBy":"...","decidedAt":"2026-01-01T00:00:00Z"}
```

- `decision` must be exactly `approved` or `revise`.
- `bundleDigest` must be exactly `${bundle_digest}` — it is re-checked against the
  current accepted chain at evaluation time, so if any accepted document changed
  after this preview, resend with the freshly reported digest.
- `rationale` must state a real reason, not a placeholder.

If `decision` is `approved`: the four documents are rendered and published to
`specs/active/` as `00-prd.md`, `10-software-requirements-specification.md`,
`20-software-design-document.md`, `30-readiness-handoff.md`, plus the
`40-development-plan.json` consumed by the development workflow, and the run
completes.

If `decision` is `revise`: the run routes back to `review` for a fresh verdict
(including a `FAIL:*` one if a deeper phase needs rework).

${retry_block}

When the file is written, stop. The harness validates it and acts on the decision,
or re-runs `approve` with the reported violations.
