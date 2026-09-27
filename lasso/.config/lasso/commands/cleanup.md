Check the working tree for diffs and review what changed since the last commit to understand the full scope of the work.

Fix the small breakages the changes are likely to have left behind:

- Missing imports — resolve any identifier used in a file but not imported from its existing source module; remove imports that are no longer used
- Typos in names — identifiers that look like a misspelling or leftover rename (e.g., an old name still referenced after a refactor) get corrected to the current name everywhere they appear, including tests and callers
- Referenced but missing functions — if a file calls a function that doesn't exist anywhere, create it in the module that fits the convention, with tests
- Undefined variables or fields — resolve against existing state, helpers, or deps; if the referenced thing was deleted in the changes, update the call sites, don't resurrect it
- Outdated comments — rewrite comments that describe behavior that no longer holds; never leave comments that contradict the code

Make only the minimal fix for each problem — don't refactor unrelated code, don't reformat, don't rename working code.
