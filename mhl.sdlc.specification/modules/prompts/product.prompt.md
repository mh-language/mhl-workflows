Draft the PRD for this Specification run (blueprint 0004 §2/§3, **product** phase),
building on the accepted idea.

The accepted idea is on disk at `${idea_path}` (digest `${idea_digest}`). Read it.

Write a JSON OBJECT to the file `${proposal_path}` (a real file, written with your
file-write tool — NOT escaped or embedded in your reply) with this shape:

```json
{"schema":"${schema}","ideaDigest":"${idea_digest}","vision":"...","goals":[{"id":"G-1","statement":"..."}],"successMetrics":[{"id":"M-1","goalId":"G-1","measure":"...","target":"..."}],"nonGoals":["..."],"scope":["..."],"risks":[{"id":"R-1","description":"...","mitigation":"...","severity":"..."}],"decisions":[{"id":"D-1","statement":"...","rationale":"..."}],"openQuestions":[]}
```

Rules the PrdEvaluator enforces:

- `schema` must be exactly `${schema}` and `ideaDigest` must be exactly `${idea_digest}`.
- at least one `goals`, one `nonGoals`, one `scope` and one `successMetrics` entry.
- goal / metric / risk / decision ids are unique.
- every success metric has a `measure` and a `target` that are both present and distinct.
- no `openQuestions` entry may be left `blocking: true`.

${retry_block}

When the file is written, stop. The harness validates it and either advances to
`analysis` or re-runs `product` with the reported violations.
