Assess readiness for this Specification run (blueprint 0004 §2/§7, blueprint 0006
**review** phase): judge whether the accepted idea / PRD / SRS / SDD chain is
internally consistent, or whether an earlier phase must be redone.

The accepted documents are on disk:

- SRS: `${srs_path}`
- SDD: `${sdd_path}`

Read them, plus `${idea_path}` and `${prd_path}` for context.

Write a JSON OBJECT to the file `${proposal_path}` (a real file, written with your
file-write tool — NOT escaped or embedded in your reply) with this shape:

```json
{"verdict":"READY","slices":[{"id":"SL-1","classification":"...","goal":"...","inScope":["..."],"outOfScope":["..."],"observableOutcome":"...","requirementIds":["RF-1"],"adrIds":["ADR-1"],"dependsOn":[],"contracts":["..."],"happyPath":"...","failurePath":"...","acceptanceCriterion":"...","suggestedTarget":"...","suggestedVerificationStrategy":"..."}],"conflicts":[],"residuals":[]}
```

- `verdict` must be exactly one of `READY`, `FAIL:product`, `FAIL:analysis`,
  `FAIL:design`.
- `conflicts` and `residuals` are always required arrays (use `[]` when empty).

If `verdict` is `READY`:

- propose at most 10 readiness slices, each with a unique id;
- every `requirementIds` entry references a real SRS requirement; every `adrIds`
  entry references a real SDD ADR;
- every `dependsOn` entry names another slice in this same list (never itself); the
  graph is acyclic and at least one slice has an empty `dependsOn`;
- every SRS requirement is covered by at least one slice — the slices form a
  complete cover.

If `verdict` starts with `FAIL:`: leave `slices` empty and explain the rejection
through `conflicts` / `residuals`.

${retry_block}

When the file is written, stop. The harness validates it and either pauses for
approval (`READY`), recascades to the failing phase (`FAIL:*`), or re-runs `review`
with the reported violations.
