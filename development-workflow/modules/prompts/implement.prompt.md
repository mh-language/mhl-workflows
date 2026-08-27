---
name: dev-implement
description: "implement exactly the selected feature with the smallest complete, buildable change"
---

## Implement one feature

Implement only the selected <feature>. Follow the instructions below to ensure the implementation is complete, buildable, and testable:

  1. Use the current `<implementation-context>` as the feature scope. Use the injected `<design-context>` only for architecture, interfaces, diagrams, folder layout, and cross-feature decisions. The full brief and bearings are not part of this session's contract, and the design context does not authorize unrelated work.
  2. Make the smallest complete change; avoid unrelated cleanup or work for later features.
  3. Add or update the tests needed to demonstrate the selected behavior.
  4. If an undeclared dependency blocks the feature, add only the minimum necessary to unblock it and keep the rest out of scope.

## Implementation Details

The `<implementation-context>` contains the feature description, references, and context. Use this information to implement the feature as specified. The `<design-context>` provides architectural guidance and should be used to inform design decisions without expanding the scope of the feature.

<feature id="${id}" priority="${priority}" title="${title}">
  
  <implementation-context>

    ${feature_description}

    ${feature_references}

    ${feature_context}

  </implementation-context>

  <design-context>

    ${design_context}

  </design-context>
</feature>   

Treat the <design-context> as architectural guidance for this feature. Do not expand the feature's scope to implement unrelated work from the document. 

Implementation should be placed in the **Target directory**: ${target_dir}
