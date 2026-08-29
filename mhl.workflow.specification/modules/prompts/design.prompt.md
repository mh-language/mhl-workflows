Draft the SDD for this Specification run (blueprint 0004 §2/§3, **design** phase),
building on the accepted SRS.

The accepted SRS is on disk at `${srs_path}` (digest `${srs_digest}`). Read it.

${sources_block}

Source-backed design context:

- If a `<sources>` block is shown above, it is authoritative. Set `sourceDigest`
  to exactly `${source_digest}` and `sourceFiles` to exactly `[${source_files}]`,
  and populate `designContent` with the detailed Markdown design recovered from the
  source material — preserve headings, prose, tables, Mermaid diagrams, fenced code
  blocks and folder/file trees verbatim where possible. Do not include the top-level
  `# Software Design Document` heading; the renderer supplies it.
- If no sources are available, keep `sourceDigest` and `sourceFiles` null and still
  use `designContent` for any detailed Markdown design, preserving diagrams and
  code blocks instead of flattening them into ADRs.

Write a JSON OBJECT to the file `${proposal_path}` (a real file, written with your
file-write tool — NOT escaped or embedded in your reply) with this shape:

```json
{"schema":"${schema}","srsDigest":"${srs_digest}","sourceDigest":null,"sourceFiles":null,"designContent":"Markdown body","adrs":[{"id":"ADR-1","title":"...","decision":"...","rationale":"...","requirementIds":["RF-1"]}],"controls":[{"id":"IC-1","name":"...","description":"...","requirementIds":["RF-1"]}]}
```

Rules the SddEvaluator enforces:

- `schema` must be exactly `${schema}` and `srsDigest` must be exactly `${srs_digest}`.
- every functional + quality requirement from the accepted SRS is allocated to at
  least one ADR's `requirementIds`.
- ADR ids are unique; every ADR / control requirement reference points at a real
  SRS requirement id.
- when a source bundle exists, `sourceDigest`, `sourceFiles` and `designContent`
  are all required and must match the current accepted source bundle.

${retry_block}

When the file is written, stop. The harness validates it and either advances to
`review` or re-runs `design` with the reported violations.
