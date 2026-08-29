Draft the SRS for this Specification run (blueprint 0004 §2/§3, **analysis** phase),
building on the accepted PRD.

The accepted PRD is on disk at `${prd_path}` (digest `${prd_digest}`). Read it.

Write a JSON OBJECT to the file `${proposal_path}` (a real file, written with your
file-write tool — NOT escaped or embedded in your reply) with this shape:

```json
{"schema":"${schema}","prdDigest":"${prd_digest}","functionalRequirements":[{"id":"RF-1","goalIds":["G-1"],"statement":"...","dependsOn":[],"acceptanceIds":["AC-1"]}],"qualityRequirements":[],"acceptanceCriteria":[{"id":"AC-1","requirementIds":["RF-1"],"given":"...","when":"...","then":"..."}],"interfaces":[],"dataRules":[],"delivery":{"target":"...","verificationStrategy":"...","isBootstrap":true}}
```

Rules the SrsEvaluator enforces:

- `schema` must be exactly `${schema}` and `prdDigest` must be exactly `${prd_digest}`.
- every PRD goal is covered by at least one requirement's `goalIds`.
- functional + quality requirement ids are unique; each requirement has a non-empty
  `statement` and at least one `acceptanceIds` entry that resolves to a real
  `acceptanceCriteria` id.
- every `dependsOn` id, and every acceptance / interface / data-rule requirement
  reference, points at a requirement id that actually exists.
- `delivery.target` and `delivery.verificationStrategy` are non-empty.

${retry_block}

When the file is written, stop. The harness validates it and either advances to
`design` or re-runs `analysis` with the reported violations.
