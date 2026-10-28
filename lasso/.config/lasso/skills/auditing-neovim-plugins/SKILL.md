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

The audit is read-only until the user approves a plan. Inspect the model and
plugin, then present a prioritized plan describing the proposed changes and
verification. Do not edit files, add or remove dependencies, run formatters or
generators that modify files, or commit anything while preparing the plan. Wait
for explicit user approval before implementing any part of it; the steps below
are guidance for the approved implementation phase.

Write your plan to a local `PLAN.md` file

When the user approves the plan and you complete a step, show all the remaining
steps to do so the user can view what's left.

## 1. Get the model for reference (read-only)

```sh
git clone --depth 1 https://github.com/elanmed/template.nvim /tmp/template.nvim
```

Read from it; never merge from it. There is no shared history and no shared
naming, so `git diff`/`git merge` against the model are meaningless.

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
| `.gitignore` (`tags`, `!doc/tags`)      | Generated files kept out, help tags kept in                | `.gitignore`                     |

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

## 3. What typically needs updating

- **Quality gates**:
- **Testing**: Missing test coverage, or test coverage which doesn't correspond to
  the `testing-neovim-plugins` skill
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
2. Wire everything into the single `deploy` target so nothing is optional.
3. Regenerate artifacts and run the full gate:
   ```sh
   make test lint format docs
   ```
4. Commit. If your plugin uses the pre-push hook pattern, install it
   (`scripts/install_hooks.sh` equivalent) and let it enforce the gate.

## 5. Migrate legacy async to `vim.async`

A single-file legacy async library (often named `async.nvim`) may appear as a
plugin dependency even though its implementation was copied and pasted into the
plugin. Treat it as vendored code and migrate its call sites to Neovim's native
`vim.async` APIs. Remove the copied library and its dependency unless the plugin
still needs iterator helpers. If it does, **ask the user to include the latest
`async.nvim` version**, which provides `batched_iterator` and
`throttled_iterator`; `lua/template/latest_async.lua` is a useful reference for
that version. `lua/template/legacy_async.lua` is likewise a useful reference
for identifying legacy behavior. Neither template file is guaranteed to match
the plugin's copy exactly; expect similar code, inspect the plugin's actual
implementation, and use the references as guidance rather than assumed exact
sources. Since neither template file is guaranteed to match, it's critical
to ask the user to supply the latest async lua file.

Use these adapters at callback-based API boundaries when calling `vim.system`,
`vim.ui.input`, or when an API needs a callback dispatched through
`vim.schedule`:

```lua
--- @type fun(cmd: string[], opts: vim.SystemOpts?): vim.SystemCompleted
local system_async = vim.async.wrap(3, vim.system)

--- @type fun(opts: vim.ui.input.Opts?): string?
local ui_input_async = vim.async.wrap(2, vim.ui.input)

local cb_async = function(callback)
  return function(...)
    local arguments = { ... }
    vim.async
      .run(function()
        callback(unpack(arguments))
      end)
      :raise_on_error()
  end
end

local ensure_main_loop = function()
  vim.async.sleep(0)
end
```

Replace legacy `await`/async wrappers with native `vim.async` coroutine
execution and `vim.async.wrap` for callback-style APIs; use `cb_async` to run
callbacks in an async context and `ensure_main_loop()` where legacy code needs
to yield back to the main loop. Preserve behavior and error propagation, and
remove the old library only after all call sites and tests have been migrated.

## 6. Verification checklist

- [ ] `make deploy` (or your plugin's single gate) passes
- [ ] Every row of the section-2 table has an explicit classification with a
      one-sentence justification
- [ ] Help docs generate under your plugin's name and `:h <name>` resolves
- [ ] Lint and format run clean with zero manual formatting
