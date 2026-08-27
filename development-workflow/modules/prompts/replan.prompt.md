---
name: dev-replan
description: "revise the global development plan when the current one no longer fits the observed repository state"
---

# Revise the development plan

The current development plan may no longer fit the observed repository state. Deterministic
verification kept failing on the same feature and the harness is escalating from a local fix
to a plan revision.

<observation>${observation}</observation>

<persisted-observations>
${observations}
</persisted-observations>

<current-plan>
${current_plan}
</current-plan>

## What to do

Consider at least two materially different responses to the observation and choose one.
Write a single JSON OBJECT to the file `${proposal_path}` (a real file, written with your
file-write tool — do NOT escape it or put it inside the response) with this shape:

{"reason":"why the global plan must change","alternativesConsidered":["alternative A","alternative B; selected because ..."],"basedOnObservationIds":["OBS-1"],"revisedFeatures":[{"id":1,"title":"...","priority":1,"dependsOn":[],"description":"...","references":[],"implementationContext":{"requirements":[],"decisions":[],"constraints":[],"files":[],"acceptance":[]},"status":"pending"}]}

`revisedFeatures` is the COMPLETE replacement plan. Rules:

- Retain every feature already marked `"done"` unchanged: same `id`, `title`, definition and `dependsOn`.
- Pending features may be reprioritized, rewritten, removed, split or added.
- `id` values must be positive integers and unique.
- Every `dependsOn` id must exist in the array; a feature may not depend on itself; the graph must stay acyclic.
- Keep the same verify command and target directory.

Then return `replan` without arguments. The harness validates the file and either applies it
or asks again.
