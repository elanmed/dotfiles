---
name: auditing-neovim-plugins
description: Use when auditing a Neovim plugin in order to update it to the latest standards as determined by the template.nvim plugin.
---

# Auditing a plugin against `template.nvim`

`template.nvim` is a **model of the ideal plugin**: its layout, tooling, and
conventions are the standard to meet. Expect your plugin to differ in name, structure,
and scope — your job is to determine _how_ it differs from the model, decide
which differences are gaps worth closing, and close them.

- **the model** — this repo (`elanmed/template.nvim`).
- **your plugin** — the repo this file has been copied into.

## Plan first; do not make changes

The audit is read-only until the user approves a plan, except for updating
submodule checkouts as described in section 1a. Inspect the model and plugin,
then present a prioritized plan describing the proposed changes and
verification. Do not edit project files, add or remove dependencies, run
formatters or generators that modify files, or commit anything while preparing
the plan. Wait for explicit user approval before implementing any code or
configuration changes; the steps below are guidance for the approved
implementation phase.

Write your plan to a local `PLAN.md` file. Show the user the steps outlined in
the plan. Note that the plan should not be committed.

When the user approves the plan and you complete a step, show all the remaining
steps to do so the user can view what's left.

## 1. Get the model for reference (read-only)

```sh
git clone --depth 1 https://github.com/elanmed/template.nvim /tmp/template.nvim
```

Read from it; never merge from it. There is no shared history and no shared
naming, so `git diff`/`git merge` against the model are meaningless.

### 1a. Update every submodule to latest `master`

Before auditing the plugin, inspect its working-tree status, including every
submodule. Do not overwrite, stash, or reset user changes; if a submodule is
dirty or cannot be safely updated, stop and report that blocker. Initialize
submodules recursively, then fetch and fast-forward each submodule to its
remote `master` branch (including nested submodules). For example:

```sh
git submodule update --init --recursive
git submodule foreach --recursive 'git fetch origin master && (git switch master || git switch --track -c master origin/master) && git pull --ff-only origin master'
```

Do not reset or force-update branches. If a submodule has no `master` branch,
uses a different remote, or cannot fast-forward, report it and do not silently
substitute another branch. This intentionally changes submodule checkouts and
may change the superproject's recorded gitlinks; report every resulting change,
do not commit it, and include the update in the plan for user review.

## 2. Determine how your plugin differs

Work through the model component by component. For each row, find your
plugin's counterpart (or note that it has none):

| Model component                         | What it provides                                           | Where to look in your plugin     |
| --------------------------------------- | ---------------------------------------------------------- | -------------------------------- |
| `lua/template/init.lua`                 | Module entrypoint with `setup()`                           | `lua/<name>/init.lua`            |
| `plugin/template.lua`                   | Eager-load entry that calls `setup()`                      | `plugin/<name>.lua`              |
| `tests/test_e2e.lua`                    | mini.test suite driving a child Neovim                     | `tests/`                         |
| `scripts/minimal_init.lua`              | Deterministic test init (rtp + mini.test)                  | wherever tests bootstrap         |
| `Makefile`                              | `test`, `lint`, `format`, `docs`, `dev`, `clean`, `deploy` | Makefile / task runner           |
| `stylua.toml`, `.styluaignore`          | Formatting config                                          | repo root                        |
| `scripts/pre-push` + `install_hooks.sh` | Runs all checks on push of master                          | hooks / CI config                |
| `deps/*` (git submodules)               | Pinned dev-only deps: mini.test, ts-vimdoc.nvim            | deps/, CI, plugin manager config |
| `make docs` → `doc/template.txt`        | Help docs generated from `README.md` via ts-vimdoc         | doc generation                   |
| `PRINCIPLES.md`                         | Written-down design conventions                            | should not appear in the plugin  |
| `.gitignore` (`tags`, `!doc/tags`)      | Ignore rules synchronized with the model                   | `.gitignore`                     |

For each component, classify the difference as one of:

1. **Equivalent** — same job done, differently named. Nothing to do.
2. **Divergent** — your plugin does the job, but worse or inconsistently.
   Usually adopt the model's approach.
3. **Missing** — your plugin has no counterpart. Usually adopt.
4. **Essentially different** — divergence is a deliberate design decision of
   your plugin. Keep it, and inform the user of the reason

When judging divergence, compare against the _principle_, not the mechanism. See `PRINCIPLES.md` for
these principles.

A different mechanism can still satisfy a principle — keep it and say why.

### Look for bugs as well as template gaps

Inspect the plugin's implementation and tests for concrete correctness defects,
not just missing conventions. Trace public APIs through their callers and cover
normal behavior, boundary and empty inputs, invalid arguments, error paths,
resource cleanup, state/lifecycle transitions, and asynchronous callbacks or
coroutine scheduling where applicable. Check that tests actually assert the
observable behavior and failure cases. Run existing non-mutating checks when
safe, but do not fix issues during the audit. Report each suspected bug with
severity, file and line, a concise explanation, and a reproducible scenario or
missing test; distinguish confirmed defects from risks or coverage gaps, and
include proposed fixes/tests in the prioritized `PLAN.md`.

## 3. What typically needs updating

- **Quality gates**:
- **Testing**: Identify missing or insufficient tests by mapping the plugin’s
  public behavior, important edge cases, and error paths to existing coverage;
  propose tests for uncovered behavior. Ensure tests correspond to the
  `testing-neovim-plugins` skill. Use `mini.test` for the test framework; if a
  plugin includes all of `mini.nvim` only to access its test framework, replace it
  with the focused `mini.test` dependency.
- **Format config**: `stylua.toml` with `.styluaignore` - many older plugins use `.editorconfig` and
  `.luarc.json` instead, both of which should be deleted
- **Legacy async**: Using a local `async.nvim` plugin instead of the latest `vim.async` standards.
  See section #5 below for more information.

Skip from the model: the stub feature code (`setup()` is intentionally empty),
the `template` naming, `LICENSE`, and README prose. The model demonstrates
_shape_, not features.

## 4. How to update

1. For each adopted component, port the **pattern**, not the file: copy the
   model's file, then rename/trim to your plugin's name and layout. Typical
   rename points: module paths, the `pack/dev/start/<name>.nvim` stow target in
   `make dev`, the `doc/<name>.txt` output and help tag in `make docs`, and
   `require("<name>").setup()` in tests and `plugin/<name>.lua`.
2. Use `mini.test` rather than the full `mini.nvim` repository when adding the
   test framework dependency.
3. Synchronize the plugin’s `.gitignore` with the model’s current `.gitignore` contents; do not merely compare them.
4. Wire everything into the single `deploy` target so nothing is optional.
5. Regenerate artifacts and run the full gate:
   ```sh
   make test lint format docs
   ```
6. Commit. If your plugin uses the pre-push hook pattern, install it
   (`scripts/install_hooks.sh` equivalent) and let it enforce the gate.

## 5. Migrate legacy async to `vim.async`

A single-file legacy async library (often named `async.lua`) may appear as a
plugin dependency even though its implementation was copied and pasted into the
plugin. Treat it as vendored code and migrate its call sites to Neovim's native
`vim.async` APIs. Remove the copied library and its dependency unless the plugin
still needs iterator helpers. If it does, **ask the user to include the latest
`async-iterators.nvim` version**, which provides `batched_iterator` and
`throttled_iterator`; `lua/template/latest_async.lua` is a useful reference for
that version. `lua/template/legacy_async.lua` is likewise a useful reference
for identifying legacy behavior. Neither template file is guaranteed to match
the plugin's copy exactly; expect similar code, inspect the plugin's actual
implementation, and use the references as guidance rather than assumed exact
sources. Since neither template file is guaranteed to match, it's critical
to ask the user to supply the latest async lua file. The file should be named
`async-iterators.lua`.

Replace legacy `await`/async wrappers with native `vim.async` coroutine
execution and `vim.async.wrap` for callback-style APIs; use `cb_async` to run
callbacks in an async context and `ensure_main_loop()` where legacy code needs
to yield back to the main loop. Preserve behavior and error propagation, and
remove the old library only after all call sites and tests have been migrated.

## 6. Verification checklist

- [ ] `make deploy` (or your plugin's single gate) passes
- [ ] Every row of the section-2 table has an explicit classification with a
      one-sentence justification
- [ ] Every submodule was fast-forwarded to remote `master`, or any blocker and
      resulting gitlink changes were explicitly reported
- [ ] Bug findings distinguish confirmed defects, risks, and coverage gaps, with
      locations and reproducible evidence
- [ ] Help docs generate under your plugin's name and `:h <name>` resolves
- [ ] Lint and format run clean with zero manual formatting
- [ ] Missing or insufficient test coverage has been identified and addressed
- [ ] Tests use `mini.test`; the full `mini.nvim` dependency is not used solely for testing
- [ ] Plugin `.gitignore` matches the model’s current `.gitignore`
