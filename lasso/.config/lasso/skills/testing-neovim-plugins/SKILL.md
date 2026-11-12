---
name: testing-neovim-plugins
description: Use when writing, reworking, or reviewing tests for a Neovim plugin or config (`mini.test` suites, child-process tests, fixtures, stubs).
---

# User preferences

Guidelines distilled from the user's own plugin test suites (e.g. ff.nvim). Apply these in addition to the general guidance below — where they conflict with the general guidance, follow these.

- **One test file per source file, mirroring the module:** `lua/foo/bar.lua` -> `tests/foo/bar_test.lua`; repos that keep tests flat replace `/` with `_` (`lua/foo/bar.lua` -> `tests/lua_foo_bar_test.lua`), drop `.lua`, and append `_test.lua`. No registration is needed for a new file when the test init collects both `test_*.lua` and `*_test.lua`.
- **Anything that runs inside Vim is tested in a child process** (`MiniTest.new_child_neovim`): buffers, windows, options, `_G` functions, autocommands, screen state, command output. Use `child.restart { "-u", "scripts/minimal_init.lua" }` in `pre_case` and stop it in `post_once` (guard with `child.is_running()` when the set may be filtered). The child is thrown away per case, so global state cannot leak. Reserve the in-process style for pure Lua logic (string/table helpers, data transforms, async plumbing), and there restore everything a case touches (`cwd`, registers, stubs, highlight groups, mappings, `vim.g`) with `MiniTest.finally`.
- **Child-side Lua:** `child.lua`/`child.lua_get` for a single expression, `child.lua_func` whenever the code is more than one line. Functions handed to `child.lua_func` are dumped and must not capture upvalues - pass data as arguments and return one structured value; a leading `nil` argument is silently dropped, so pass a table when a value can be nil. Use direct redirections (`child.api.*`, `child.o.*`, `child.bo.*`, `child.fn.*`, `child.g.*`) when they fit, and avoid multi-statement Lua strings.
- **Type every callback parameter** the same way as production code, including `child.lua_func` closures, and add the `_arg` suffix when the callback would shadow an outer name (see `writing-neovim-lua` for the general rule). Two exceptions stay unannotated, because their signatures are dictated by MiniTest or by the API being faked: the predicate and failure-context functions of `MiniTest.new_expectation`, and the override functions inside a `mock`/`mock_child` table.
- **Exercise real code and stub externals at the boundary** (cwd, `stdpath`, `notify`, clipboard registers, `git`, the process runner); prefer real temp dirs and files as fixtures over stubbing the filesystem.
- **Per-function top-level sets,** behavior-sentence case names ("aborts for readonly buffers"), and every case asserting observable behavior (buffer contents, files on disk, notifications, cursor, register state) rather than placeholder or dummy-equality smoke tests.
- **Strict assertions:** exact `MiniTest.expect.equality` against full literal expected values (whole tables, kept as file-scope constants), never aliases and never values derived by the same expression as the code under test. Mapping is fine when the value under test is itself a table (`vim.tbl_map(function(list_arg) return list_arg.title end, result)`) or when it collapses genuinely repetitive access (registers 1-9), but don't map just to save a line or two on distinct values. If floating-point precision forces tolerance, prefer explicit tolerance over commented-out assertions - and don't let the runner's timeout mask precision problems (set a generous `timeout` in the test Makefile target so hangs and real failures surface).
- **Add a custom expectation instead of repeating a raw API call plus `expect.equality`** (`nvim_buf_get_lines`, `nvim_win_get_cursor`), with a failure message showing observed vs expected. For async state, poll with an expectation (`vim.wait` until the value matches) instead of `expect.equality(vim.wait(...), true)`.
- **Helper placement and shape:** put a fixture or expectation in one shared module when more than one test file uses it, keep it file-local when a single file uses it, and inline it at the call site when it is used only once; after adding a helper, re-read every other test file and adopt it where it now fits. Helpers return values instead of taking callbacks so case bodies stay flat (`local sandbox_dir = chdir_to_sandbox()`); take a callback only when the helper must bracket the work (save, run, restore).
- **Stubs go through the mock helper**, asserting the recorded calls as a full literal list (`{ { name = "notify", args = { "Aborting, readonly", vim.log.levels.WARN } } }`). Function arguments are recorded as `"<function>"` so calls stay comparable and RPC-serializable. In-process use `mock` (restores after the case); inside a child use `mock_child`, optionally publishing the calls on `_G[store_name]` for the parent to read. Never hand-roll `rawset` plus manual restore.
- **Poll for state instead of waiting a fixed duration:** a fixed `vim.wait(50)`/`vim.async.sleep(50)` delay is both slower than necessary and unreliable - too short under load, and it always wastes the full delay when the work finished sooner. Wait on the condition itself (`vim.wait(1000, function() return cond end)`, or an expectation that polls until the observed value matches) so a case returns as soon as the state settles and fails with a clear message when it never does.
- **Write assertions in readable literals:** name constants instead of magic numbers (`vim.log.levels.WARN`, not `3`); assert command output through whitespace-normalized literal lines (`file_contains(path, "n gzq * <Cmd>echo 1<CR>")`) instead of Lua patterns that encode column padding; and only assert on output the code under test controls - an index into Vim's builtin `:hi`/`:map` dumps tests Vim, not the code.
- **Plan large test additions first,** grouped by related tests, and get approval before implementing (see a `PLAN.md` with prioritized items and nested test-case lists). Enumerate concrete assertions per case (contents on disk, formatted strings, event payloads, window/buffer state) - not internal call counts.
- **When adding tests, look for bugs in the code under test** and flag them to the user with the case that reveals them, instead of silently encoding current behavior as correct; record them in the repo's bug doc (`BUGS.md`) when it has one, with the code reference, the surprising behavior, and the test case that pins it down.

The `mock` helper referenced above, when it is not yet a shared module:

```lua
--- @param target table
--- @param overrides table<string, function>
--- @return { name: string, args: any[] }[]
local mock = function(target, overrides)
  local originals = {}
  local calls = {}
  for name, replacement in pairs(overrides) do
    originals[name] = target[name]
    rawset(target, name, function(...)
      local args = vim.tbl_filter(function(arg)
        return type(arg) ~= "function"
      end, { ... })
      table.insert(calls, { name = name, args = args })
      return replacement(...)
    end)
  end

  MiniTest.finally(function()
    for name, original in pairs(originals) do
      rawset(target, name, original)
    end
  end)

  return calls
end
```

# How to test with 'mini.test'

Shallow clone `nvim-mini/mini.test` and read the README.md thoroughly

```sh
git clone --depth 1 https://github.com/nvim-mini/mini.test /tmp/mini.test
```
