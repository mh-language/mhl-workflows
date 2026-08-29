---
name: dev-fix
description: "repair the current feature after the harness's deterministic verification failed"
---

## Fix one feature

Deterministic verification FAILED for the feature below. Repair only this feature so the verification command passes. Do not start other features or do unrelated cleanup.

## Feature to fix

<feature id="${id}" title="${title}">
  <implementation-context>
    ${feature_context}
  </implementation-context>

  <design-context>
    ${design_context}
  </design-context>

  <bearings>
    ${bearings_context}
  </bearings>

  <verification-failure>
    ${verify_failure}
  </verification-failure>
</feature>

## Instructions

- Read the failure above and only the relevant part of the verification output.
- Make the smallest change that makes the verification pass; keep the feature's scope.
- Update or add the tests that demonstrate the corrected behavior.
- Treat `<design-context>` as architectural guidance only; do not expand scope.

Implementation stays in the **Target directory**: ${target_dir}
