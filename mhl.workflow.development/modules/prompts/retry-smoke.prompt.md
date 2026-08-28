---
name: dev-smoke
description: "repair the target setup after the harness's deterministic baseline smoke test cannot run or fails"
---

# Repair the baseline smoke setup

The harness already ran the baseline smoke test and reported a failure. Repair only the
environment or setup responsible for that failure; do not start implementing the feature.

- Inspect the reported failure and only the relevant excerpt of `${log_path}`.
- Fix `init.sh`, missing prerequisites, paths, permissions, or equivalent bootstrap setup.
- Run `./init.sh` in the target directory to confirm the repair.
- Keep detailed output in `${log_path}`; do not paste full logs into the response.