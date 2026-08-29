Frame the idea for this Specification run (blueprint 0004 §2/§3, **discover** phase).

${sources_block}

Ground the idea in the material above when present — do not invent facts it does not
support, and prefer citing or summarizing it over guessing.

Write a JSON OBJECT to the file `${proposal_path}` (a real file, written with your
file-write tool — NOT escaped or embedded in your reply) with this shape:

```json
{"schema":"${schema}","title":"...","problem":"...","users":["..."],"desiredOutcomes":["..."],"constraints":["..."],"openQuestions":[{"id":"OQ-1","question":"...","blocking":false}]}
```

Rules the IdeaEvaluator enforces:

- `schema` must be exactly `${schema}`.
- `title` and `problem` are required and non-empty.
- at least one `users` entry and one `desiredOutcomes` entry.
- every open question needs a unique `id`.
- keep the canonical JSON reasonably small (a runaway paste is rejected).

${retry_block}

When the file is written, stop. The harness validates it and either advances to
`product` or re-runs `discover` with the reported violations.
