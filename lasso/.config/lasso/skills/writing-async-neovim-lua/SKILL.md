---
name: writing-async-neovim-lua
description: Use when writing, typing, or migrating async Lua for a Neovim plugin - `vim.async` coroutines, wrapping callback APIs, and replacing a legacy async library.
---

# Writing async Neovim Lua

Async code means `vim.async.*`: coroutine tasks, `vim.async.wrap` around callback APIs, and typed awaits. Code style outside async lives in `writing-neovim-lua`.

## Wrap callback APIs for async use

Use explicit types for `vim.async.wrap` wrappers:

```lua
--- @type fun(cmd: string[], opts: vim.SystemOpts?): vim.SystemCompleted
local system_async = vim.async.wrap(3, vim.system)

--- @type fun(opts: vim.ui.input.Opts?): string?
local ui_input_async = vim.async.wrap(2, vim.ui.input)
```

## Schedule callbacks in `vim.async.run` and raise errors from the task

```lua
--- @param callback fun(...: any): any
--- @return fun(...: any): nil
local cb_async = function(callback)
  return function(...)
    local arguments = { ... }
    vim.async
      .run("cb_async_task", function()
        callback(unpack(arguments))
      end)
      :raise_on_error()
  end
end
```

## Use `vim.async.sleep(0)` to ensure execution on the main loop

```lua
local ensure_main_loop = function()
  vim.async.sleep(0)
end
```

`sleep(0)` yields to the main loop; it is not a way to wait for state. Never sleep for a fixed duration hoping the work finished - poll the condition itself (in tests, `vim.wait` with a predicate).

## Type async functions and awaited values

Annotate values returned from `vim.async.run` and use a cast when the awaited result's type cannot be inferred:

```lua
--- @return string?
return vim.async.run(function()
  local result = get_async_result()
  if not result then
    return nil
  end

  return result
end)

local value = vim.async.await(start_async_operation()) --[[@as string?]]
```

## Migrate legacy async to `vim.async`

A single-file legacy async library (often named `async.lua`) may appear as a plugin dependency even though its implementation was copied and pasted into the plugin. Treat it as vendored code and migrate its call sites to `vim.async`.

1. Identify the copied library and every call site: `await`, `async.run`, callback wrappers, and any iterator helpers.
2. Replace legacy `await`/async wrappers with native `vim.async` coroutine execution, and wrap callback-style APIs with `vim.async.wrap` (typed, as above).
3. Use `cb_async` to run callbacks in an async context and `ensure_main_loop()` where legacy code needed to yield back to the main loop.
4. Preserve behavior and error propagation (`:raise_on_error()`), and migrate the tests alongside the call sites.
5. Remove the copied library and its dependency only after every call site and test is migrated.

If the plugin still needs iterator helpers, **ask the user to include the latest `async-iterators.nvim` version**, which provides `batched_iterator` and `throttled_iterator`; the file should be named `async-iterators.lua`. In the `elanmed/template.nvim` model repo, `lua/template/latest_async.lua` is a useful reference for that version and `lua/template/legacy_async.lua` for identifying legacy behavior. Neither file is guaranteed to match the plugin's copy exactly: inspect the plugin's actual implementation and use the references as guidance rather than assumed exact sources. Since a match is not guaranteed, it is critical to ask the user to supply the latest async Lua file.
