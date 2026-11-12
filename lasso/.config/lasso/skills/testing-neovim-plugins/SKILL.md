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

## The shared helper module

`tests/_helpers.lua`, the module the examples below build on. Copy it into a repo that lacks one instead of hand-rolling each helper per file.

```lua
local MiniTest = require "mini.test"

local M = {}

--- @class MockCall
--- @field name string
--- @field args any[]

--- @param target table<string, any>
--- @param overrides table<string, function>
--- @param store_name string?
M.mock_child = function(target, overrides, store_name)
  local originals = {}
  local calls = {}
  for name, replacement in pairs(overrides) do
    originals[name] = target[name]
    --- @param ... any
    rawset(target, name, function(...)
      local args = {}
      for index = 1, select("#", ...) do
        local arg = select(index, ...)
        if type(arg) == "function" then
          arg = "<function>"
        end
        args[index] = arg
      end
      table.insert(calls, { name = name, args = args })
      return replacement(...)
    end)
  end

  if store_name ~= nil then
    _G[store_name] = calls
  end

  return calls, originals
end

--- @param target table<string, any>
--- @param overrides table<string, function>
M.mock = function(target, overrides)
  local calls, originals = M.mock_child(target, overrides)

  MiniTest.finally(function()
    for name, original in pairs(originals) do
      rawset(target, name, original)
    end
  end)

  return calls
end

--- @param store_name string
--- @return MockCall[]
M.get_calls = function(child, store_name)
  return child.lua_get(("_G.%s"):format(store_name))
end

--- @class StubbedSystemResponse
--- @field err string?
--- @field stdout string?

--- @param responses table<string, StubbedSystemResponse>
M.stub_async_system = function(responses)
  local helpers = require "tests._helpers"
  local h = require "helpers"
  --- @diagnostic disable-next-line: undefined-field
  local previous_calls = _G.async_system_calls or {}
  local calls = helpers.mock_child(h.async, {
    system = function(cmd_arg)
      local response = responses[cmd_arg[1]]

      return vim.async.run(
        --- @return string?, string?
        function()
          --- @diagnostic disable-next-line: redundant-return-value
          return response.err, response.stdout
        end
      )
    end,
  }, "async_system_calls")
  vim.list_extend(calls, previous_calls)
end

M.stub_notify = function()
  return require("tests._helpers").mock_child(vim, { notify = function() end }, "notifications")
end

M.expect_lines = MiniTest.new_expectation("buffer lines", function(child, expected)
  return vim.deep_equal(child.api.nvim_buf_get_lines(0, 0, -1, false), expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.api.nvim_buf_get_lines(0, 0, -1, false)),
    vim.inspect(expected)
  )
end)

M.expect_cursor = MiniTest.new_expectation("cursor position", function(child, expected)
  return vim.deep_equal(child.api.nvim_win_get_cursor(0), expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.api.nvim_win_get_cursor(0)),
    vim.inspect(expected)
  )
end)

M.expect_cmdline = MiniTest.new_expectation("command line", function(child, expected)
  return vim.deep_equal(child.lua_get [[vim.fn.getcmdline()]], expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_get [[vim.fn.getcmdline()]]),
    vim.inspect(expected)
  )
end)

M.expect_cmdline_cursor = MiniTest.new_expectation("command line cursor", function(child, expected)
  return vim.deep_equal(child.lua_get [[vim.fn.getcmdpos()]], expected)
end, function(child, expected)
  return string.format(
    "Observed: %s\nExpected: %s",
    vim.inspect(child.lua_get [[vim.fn.getcmdpos()]]),
    vim.inspect(expected)
  )
end)

M.expect_eventually = MiniTest.new_expectation(
  "eventually matching value",
  function(get_value, expected)
    return vim.wait(1000, function()
      return vim.deep_equal(get_value(), expected)
    end, 10)
  end,
  function(get_value, expected)
    return string.format(
      "Observed: %s\nExpected: %s",
      vim.inspect(get_value()),
      vim.inspect(expected)
    )
  end
)

M.make_temp_dir = function()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  MiniTest.finally(function()
    vim.fn.delete(dir, "rf")
  end)

  return dir
end

--- @param relative_paths string[]
M.make_files = function(relative_paths)
  local dir = M.make_temp_dir()

  return vim.tbl_map(
    --- @param relative_path_arg string
    function(relative_path_arg)
      local path = vim.fs.joinpath(dir, relative_path_arg)
      vim.fn.mkdir(vim.fs.dirname(path), "p")
      vim.fn.writefile(vim.fn.range(1, 30), path)

      return path
    end,
    relative_paths
  )
end

-- Fixtures below are handed to `child.lua_func`, so they must not reference `M`
-- or any other upvalue.

--- @param lines string[]
M.open_file_buffer = function(lines)
  local path = vim.fn.tempname()
  vim.fn.writefile(lines, path)
  vim.cmd.edit { args = { path }, mods = { silent = true } }

  return path
end

--- @param path string
M.edit_file = function(path)
  vim.cmd.edit { args = { path }, mods = { silent = true } }
end

--- @param lines string[]?
M.open_buffer = function(lines)
  local buf_id = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf_id)
  if lines ~= nil then
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  end

  return buf_id
end

--- @param name string
M.open_named_buffer = function(name)
  local buf_id = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(buf_id, name)
  vim.api.nvim_set_current_buf(buf_id)

  return buf_id
end

--- @param lines string[]
--- @param cursor integer[]
M.open_scratch_buffer = function(lines, cursor)
  local buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf_id)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, cursor)

  return buf_id
end

--- @param path string
--- @param line string
M.file_contains = function(path, line)
  --- @param line_arg string
  local lines = vim.tbl_map(function(line_arg)
    return (line_arg:gsub("%s+", " "))
  end, vim.fn.readfile(path))

  return vim.tbl_contains(lines, line)
end

--- @param contents string
M.write_temp_file = function(contents)
  local path = vim.fn.tempname()
  MiniTest.finally(function()
    vim.fn.delete(path)
  end)

  local file = assert(io.open(path, "wb"))
  file:write(contents)
  file:close()

  return path
end

return M
```

# Examples

All snippets below assume `local test_helpers = require "tests._helpers"` plus that module's expectations and fixtures.

## Child-process set

```lua
local MiniTest = require "mini.test"
local test_helpers = require "tests._helpers"

local child = MiniTest.new_child_neovim()

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "scripts/minimal_init.lua" }
    end,
    post_once = child.stop,
  },
}

local load_config = function()
  child.lua [[require "barebones"]]
end
```

## In-process set

No child: `mock` restores what a case touches, so only pure Lua logic needs cleanup.

```lua
local MiniTest = require "mini.test"
local h = require "helpers"
local T = MiniTest.new_set()

T["tbl.reverse()"]["reverses without changing the input"] = function()
  local input = { "a", "b", "c" }

  MiniTest.expect.equality(h.tbl.reverse(input), { "c", "b", "a" })
  MiniTest.expect.equality(input, { "a", "b", "c" })
end
```

## Stub at the boundary in the child

The child-side stub is a file-scope function, so its data arrives as arguments:

```lua
--- @param cwd string?
local stub_cwd = function(cwd)
  require("tests._helpers").mock_child(vim.uv, {
    cwd = function()
      return cwd
    end,
  })
end

T["<leader>ye"]["warns when the working directory is unavailable"] = function()
  load_config()
  child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua")
  child.lua_func(stub_cwd, nil)
  child.lua_func(test_helpers.stub_notify)

  child.type_keys "\\ye"

  MiniTest.expect.equality(test_helpers.get_calls(child, "notifications"), {
    { name = "notify", args = { "cwd is nil", vim.log.levels.WARN } },
  })
end
```

## Stub in process and assert the recorded calls

```lua
T["fs.readfile()"]["closes the descriptor after reading the contents"] = function()
  local content = "first\n\nlast\n"
  local calls = test_helpers.mock(vim.uv, {
    fs_open = function(_, _, _, callback)
      callback(nil, 17)
    end,
    fs_fstat = function(_, callback)
      callback(nil, { size = #content })
    end,
    fs_read = function(_, _, _, callback)
      callback(nil, content)
    end,
    fs_close = function(_, callback)
      callback(nil)
    end,
  })

  local read_err, read_content = readfile "mocked.txt"

  MiniTest.expect.equality(read_err, nil)
  MiniTest.expect.equality(read_content, { lines = { "first", "", "last" }, str = content })
  MiniTest.expect.equality(calls, {
    { name = "fs_open", args = { "mocked.txt", 0, 0, "<function>" } },
    { name = "fs_fstat", args = { 17, "<function>" } },
    { name = "fs_read", args = { 17, #content, 0, "<function>" } },
    { name = "fs_close", args = { 17, "<function>" } },
  })
end
```

## Publish only the serializable part of a stub

A recorded argument holding a function (a `format_item` callback, say) cannot cross the RPC boundary: compute what you need on `_G` and read that with `get_calls`.

```lua
--- @class SelectStubOpts
--- @field choice? any

--- @param opts SelectStubOpts
local stub_select = function(opts)
  require("tests._helpers").mock_child(vim.ui, {
    select = function(items, select_opts, on_choice)
      _G.selected_items = items
      _G.selected_formatted_items = vim.tbl_map(select_opts.format_item, items)
      on_choice(opts.choice)
    end,
  })
end

T["<leader>b"]["formats buffers relative to the working directory"] = function()
  load_config()
  local paths = test_helpers.make_files { "a.lua", "b.lua" }
  child.lua_func(test_helpers.edit_file, paths[1])
  child.lua_func(test_helpers.edit_file, paths[2])
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, {})

  child.type_keys "\\b"

  MiniTest.expect.equality(
    test_helpers.get_calls(child, "selected_formatted_items"),
    { "a.lua", "b.lua" }
  )
end
```

## Stub the async process runner by command

`stub_async_system` keys the canned `{ err, stdout }` by executable and still records the calls, so assertions can cover both halves of the boundary:

```lua
T["ctags"]["runs ctags with the files of the git root on write"] = function()
  child.lua_func(stub_ctags)
  child.lua_func(test_helpers.stub_async_system, {
    git = { err = nil, stdout = "/repo\n" },
    rg = { err = nil, stdout = "a.lua\nb.lua\n" },
  })
  child.lua [[vim.api.nvim_exec_autocmds("BufWritePost", {})]]
  run_last_timer_callback()
  expect_ctags_finished()

  MiniTest.expect.equality(test_helpers.get_calls(child, "async_system_calls"), {
    { name = "system", args = { { "git", "rev-parse", "--show-toplevel" } } },
    { name = "system", args = { { "rg", "--files" }, { cwd = "/repo" } } },
  })
end
```

## Expectations

```lua
T["pairs"]["inserts a pair after the cursor"] = function()
  child.type_keys("i", "ab", "<Esc>")

  test_helpers.expect_lines(child, { "ab()" })
  test_helpers.expect_cursor(child, { 1, 3 })
end

T["<leader>a"]["starts the grep prompt"] = function()
  child.type_keys "\\a"

  test_helpers.expect_cmdline(child, "grep ")
  test_helpers.expect_cmdline_cursor(child, 6)
end
```

Poll instead of sleeping when the state settles asynchronously:

```lua
T["<C-d>"]["scrolls by half a page"] = function()
  child.lua_func(test_helpers.open_buffer, hundred_lines)

  child.type_keys "<C-d>"

  test_helpers.expect_eventually(function()
    return child.api.nvim_win_get_cursor(0)
  end, { 14, 0 })
end
```

## Filesystem fixtures

```lua
T["K"]["jumps to the tag under the cursor in a split window"] = function()
  load_config()
  local def_path = test_helpers.write_temp_file "first\nsecond\n"
  local source_path = test_helpers.write_temp_file "foo\nbar\n"
  child.o.tags = test_helpers.write_temp_file("foo\t" .. def_path .. "\t2\n")
  child.lua_func(test_helpers.edit_file, source_path)

  child.type_keys "K"

  test_helpers.expect_cursor(child, { 2, 0 })
end

T["<leader>b"]["lists only loaded, listed, and named buffers"] = function()
  load_config()
  local paths = test_helpers.make_files { "a.lua", "b.lua", "c.lua" }
  child.lua_func(test_helpers.edit_file, paths[1])
  child.api.nvim_create_buf(true, false)
  child.lua_func(test_helpers.edit_file, paths[2])
  child.bo.buflisted = false
  child.lua_func(test_helpers.edit_file, paths[3])
  child.lua_func(stub_cwd, vim.fs.dirname(paths[1]))
  child.lua_func(stub_select, { choice = child.fn.bufnr(paths[1]) })

  child.type_keys "\\b"

  MiniTest.expect.equality(test_helpers.get_calls(child, "selected_items"), {
    child.fn.bufnr(paths[1]),
  })
end
```

`make_temp_dir` for a directory the code under test writes into, asserted through `file_contains` (whitespace-normalized literal lines, no Lua patterns):

```lua
T["PrintRemaps"]["writes the remaps"] = function()
  local sandbox_dir = test_helpers.make_temp_dir()
  child.cmd("cd " .. vim.fn.fnameescape(sandbox_dir))
  child.lua [[vim.keymap.set("n", "gzq", "<cmd>echo 1<CR>")]]

  child.cmd "PrintRemaps"

  MiniTest.expect.equality(
    test_helpers.file_contains(vim.fs.joinpath(sandbox_dir, "remaps.txt"), "n gzq * <Cmd>echo 1<CR>"),
    true
  )
end
```

## Buffer fixtures

```lua
child.lua_func(test_helpers.open_buffer, { "line 1", "line 2" }) -- unnamed, listed
child.lua_func(test_helpers.open_named_buffer, "/root/one/foo.lua") -- named for path assertions
child.lua_func(test_helpers.open_scratch_buffer, { "abc" }, { 1, 0 }) -- scratch + cursor
child.lua_func(test_helpers.open_file_buffer, { "abc" }) -- real file on disk, returns its path
child.lua_func(test_helpers.edit_file, path) -- `:edit` an existing file
```

## Async plumbing in process

```lua
T["async.system()"]["returns the command output"] = function()
  local task = vim.async.run(function()
    return vim.async.await(h.async.system { "printf", "%s", "async output" })
  end)
  local err, stdout = task:wait(1000)

  MiniTest.expect.equality({ err = err, stdout = stdout }, { err = nil, stdout = "async output" })
end
```

# How to test with 'mini.test'

Shallow clone `nvim-mini/mini.test` and read the README.md thoroughly

```sh
git clone --depth 1 https://github.com/nvim-mini/mini.test /tmp/mini.test
```
