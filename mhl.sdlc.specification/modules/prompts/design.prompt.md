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

Identifier discipline (the `review` phase rejects the whole SDD otherwise, and a
rejection recascades the run back to `design`):

- Every requirement id you mention **anywhere** — including the prose in
  `designContent`, its requirement-allocation / traceability table and any
  diagram label — MUST be an id that literally appears in the accepted SRS at
  `${srs_path}`. Do not invent ids or carry them over from source material: if a
  source names something `RF-001`, `RNF-011`, `SEC-003`, `RN-002` or `ADR-007`
  and the accepted SRS calls the same thing `RF-1` / `RQ-2`, rewrite it to the
  accepted id. The accepted SRS has no `RNF-*`, `RN-*` or `SEC-*` families — those
  obligations live under `RF-*` / `RQ-*`. Never zero-pad (`RF-1`, not `RF-01`).
- `ADR-*` ids used in `designContent` MUST match the `id` values of your own
  `adrs` array exactly (`ADR-1`, not `ADR-01` / `ADR-001`).
- The requirement-to-component allocation in `designContent` MUST agree with the
  accepted SRS: allocate each SRS requirement to the component that actually
  implements it, with no off-by-one shift across the create / list / get-by-id /
  complete / edit / remove operations.

Contract consistency with the SRS (also a `review` rejection):

- Every operation the SRS defines needs a home in the design. If the SRS requires
  fetching a single task by id, `designContent` must specify that endpoint, its
  success/`404` flow, its vertical slice and its verification — not fold it into
  the list endpoint.
- Pick one canonical name for each public field and for the persisted column that
  backs it; `designContent` and the SRS must not disagree on a field name.
- HTTP method + path for every operation in `designContent` must match the SRS
  exactly, including any `/complete`-style suffix.
- If the SRS requires the API and its datastore to come up together as one local
  stack, the Compose topology described in `designContent` must include both.

${retry_block}

When the file is written, stop. The harness validates it and either advances to
`review` or re-runs `design` with the reported violations.
