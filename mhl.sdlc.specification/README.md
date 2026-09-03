# Specification Workflow

An MHL pipeline that turns a raw idea (or a folder of source material) into an
approved, publishable specification bundle: **idea → PRD → SRS → SDD → readiness →
human approval → publish**. It is the MHL port of the `dotnet/Flows.Specification`
harness flow, and it produces exactly the inputs the
[development workflow](../mhl.workflow.development/README.md) consumes.

> [!WARNING]
> Execution grants Codex autonomy to read the source folder and write proposal
> files under `.mhl/specification/`. On approval it also writes five files into
> `specs/active/`. Run it in a version-controlled directory and review the
> prompts first.

## State machine

```text
start ─▶ discover ─▶ product ─▶ analysis ─▶ design ─▶ review ─┬─▶ (awaiting_approval) ─▶ approve ─▶ publish ─▶ completed
                     ▲          ▲           ▲                 │                          (opts.approved = true)
                     └──────────┴───────────┴─── FAIL:* ◀─────┘
                        (recascade, at most twice per run)
```

Each documental phase asks Codex for a JSON **proposal**, then runs a
deterministic **evaluator**. A structural failure retries the same phase in place
(up to `max_attempts`, default 3) with the violation codes fed back into the
prompt. On success the proposal is frozen as `<phase>.accepted.json` and its
`sha256:` content digest is recorded; the next phase must echo the parent digest,
so a stale parent is caught mechanically.

`review` emits one of `READY`, `FAIL:product`, `FAIL:analysis`, `FAIL:design`. A
`FAIL:*` verdict recascades the run to that phase (capped at two recascades per
run; a third is a terminal `needs_human_decision`). A `READY` verdict freezes the
readiness slices and moves to `approve`.

`approve` takes a single human input, `opts.approved`. `true` runs a pre-publish
development-readiness gate and then the safe publisher; any other value leaves the
run parked at `awaiting_approval` for a later re-run. There is no in-flow
`revise` route — start a fresh run to force another pass.

## Terminal states

| Status | Meaning |
| --- | --- |
| `completed` | The bundle was published to `specs/active/` and read back intact. |
| `awaiting_approval` | `review` reached `READY`; the run pauses until a human re-invokes it with `opts.approved = true`. |
| `needs_human_decision` | A phase exhausted its retries, or the recascade limit was hit. |
| `publish_blocked` | Approved, but the readiness gate failed or the destination held unrecognized files. |

## Inputs

The human-curated folder `specs/sources/` is the primary input — every file
directly inside it is concatenated into the run at `start` so `discover` grounds
the idea in real material. An empty folder is fine; `discover` then works from
whatever the operator tells Codex in conversation.

There are no CLI inputs.

## Prerequisites

- [MHL CLI](https://github.com/mh-language/mhl-core-runtime) `v0.4.3-alpha` or newer as `mhl` on the `PATH`;
- [Codex CLI](https://github.com/openai/codex) installed and authenticated;
- `bash` with `sha256sum` or `shasum` (used for content digests);
- Git and a version-controlled working directory.

## Running

Run from this directory:

```bash
cd mhl.workflow.specification
mhl lint .
mhl run main.mh
```

The `READY` verdict parks the run at `awaiting_approval`. The approval is an
intentional human action and is not created by Codex. Reproduce it as follows:

### Manual approval procedure

1. Confirm that the run is waiting for approval. Run state lives in the
   `mhl_store` extension table (key `<session>/run`), not a local file; the
   expected values are `"status": "awaiting_approval"` and `"phase": "approve"`.

2. Review the accepted documents before approving:

   ```text
   .mhl/specification/<session>/prd.accepted.json
   .mhl/specification/<session>/srs.accepted.json
   .mhl/specification/<session>/sdd.accepted.json
   .mhl/specification/<session>/readiness.accepted.json
   ```

3. Re-invoke the workflow with the single boolean input, reusing the same
   session so it resumes the paused run:

   ```bash
   mhl run main.mh --session <session> --resume --input opts='{"approved":true}'
   ```

   `opts.approved = true` runs the pre-publish development-readiness gate and,
   if it passes, publishes to `specs/active/`. Any other value leaves the run at
   `awaiting_approval`. There is no `revise` route — start a fresh run
   (`mhl run main.mh`) to force another pass.

A `completed` or blocked run starts over on the next `mhl run`.

## Outputs

On a completed run, `specs/active/` holds:

| File | Source |
| --- | --- |
| `00-prd.md` | rendered from `prd.accepted.json` |
| `10-software-requirements-specification.md` | rendered from `srs.accepted.json` |
| `20-software-design-document.md` | rendered from `sdd.accepted.json` (raw Markdown body preserved) |
| `30-readiness-handoff.md` | rendered from `readiness.accepted.json` |
| `40-development-plan.json` | one feature per readiness slice — the contract the development workflow imports |

The publisher only ever writes those five names, refuses to run if the directory
contains anything it does not own from a previous publish, and re-reads every file
after writing to confirm it matches.

## Generated state

Per-run artifacts live under `.mhl/specification/<session>/`; run state lives in
the `mhl_store` extension table.

| Path | Contents |
| --- | --- |
| `mhl_store` table, key `<session>/run` | step, status, phase, recascade counter, terminal reason |
| `<session>/sources.accepted.json` | ingested source material (files + concatenated content) |
| `<session>/<phase>.proposal.json` | Codex's latest not-yet-validated draft |
| `<session>/<phase>.accepted.json` | the evaluator-passed version (canonical JSON) |
| `<session>/recascade.note.txt` | review's rejection reason, handed to the phase it recascades to |
| `<session>/publish-manifest.json` | the publisher's ownership ledger for `specs/active/` |
| `.mhl/logs/codex_<session>.log` | raw Codex event stream |

## Tests

```bash
mhl test tests/
```

`tests/spec_test.mh` covers the pure evaluators and the renderer;
`tests/io_test.mh` covers the digest shell-out, the accepted store, the digest
chain, and the development-plan builder.

## Internal organization

```text
mhl.workflow.specification/
├── main.mh                       # the idea → publish state machine
├── modules/
│   ├── agents/
│   │   ├── codex.agent.mh        # Codex CLI command, args, event parsing
│   │   └── codex.adapter.mh      # execute + error handling
│   ├── prompts/
│   │   ├── discover.prompt.md
│   │   ├── product.prompt.md
│   │   ├── analysis.prompt.md
│   │   ├── design.prompt.md
│   │   ├── review.prompt.md
│   │   └── approve.prompt.md
│   └── tools/
│       ├── spec-config.tool.mh   # tunable guards
│       ├── digest.tool.mh        # sha256 content digests
│       ├── spec-store.tool.mh    # run state + proposal/accepted store
│       ├── sources.tool.mh       # specs/sources ingestion
│       ├── spec-evaluator.tool.mh# the six documental gates
│       ├── spec-renderer.tool.mh # accepted JSON → Markdown
│       └── spec-publisher.tool.mh# safe publish + development plan
├── specs/
│   └── sources/                  # human-curated input material
└── tests/
```

## Differences from `dotnet/Flows.Specification`

- The harness step/dispatch loop is replaced by an MHL `loop pipeline`; retries
  are explicit per-phase `while` loops instead of the harness retry budget.
- Content digests shell out to `sha256sum`/`shasum` (`json.stringify` already
  emits sorted keys, so the digest stays content-addressed).
- The approval pause is a human handoff via the `opts.approved` boolean input;
  Codex never sets it.
- The publisher's postcondition re-reads and byte-compares the written files; it
  does not reproduce `Harness.Engine.DocsReader`'s concatenation check.
- Because MHL raises on a missing object field, every read of an LLM-produced
  proposal goes through safe accessors (`f` / `str` / `list` in the evaluator,
  `g` / `gs` / `gl` in the renderer and publisher); an omitted field is treated
  as absent and reported as a violation rather than crashing the run.

## License

Part of the `mhl-workflows` repository, released under [CC0 1.0 Universal](../LICENSE).
