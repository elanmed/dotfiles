---
name: writing-neovim-lua
description: Use when writing or reviewing Lua that runs in Neovim (a plugin, a config, or its helpers) - code style, native APIs, type annotations, notifications, and the plugin config surface.
---

# Writing Neovim Lua

Conventions for any Lua that runs inside Neovim. Async code has its own skill: `writing-async-neovim-lua`.

## Prefer an immediately invoked function expression over `cond and a or b`

The ternary-style `cond and a or b` silently drops a falsy `a` and hides multi-step branches:

```lua
local bufnr = (function()
  if item_arg.path == nil then
    return nil
  end

  return vim.fn.bufadd(item_arg.path)
end)()
```

## Prefer native Lua APIs over `vim.fn`

The native Lua implementation skips the Vimscript bridge and carries types. Use `vim.trim`, `vim.split`, `vim.fs.*`, `vim.text.*`, and `vim.api.*`; reach for `vim.fn.*` only when there is no Lua equivalent, or when the Vimscript version does more (`vim.fn.trim` also trims a list).

```lua
local text = vim.trim(item.text)
```

## Type annotations

Every function parameter carries a `--- @param` type comment, including anonymous callbacks and `child.lua_func` closures. Name parameters with an `_arg` suffix when the callback would shadow an outer name, and use those names inside the callback:

```lua
--- @param fn_name string
--- @param content string
local function mock_run_diff_cmd(fn_name, content)
  child.lua_func(
    --- @param fn_name_arg string
    --- @param content_arg string
    function(fn_name_arg, content_arg)
      -- Use fn_name_arg and content_arg inside this callback.
    end
  )
end
```

Two exceptions stay unannotated, because their signatures are dictated by MiniTest or by the API being faked:

- the predicate and failure-context functions of `MiniTest.new_expectation`;
- the override functions inside a `mock`/`mock_child` table.

Prefer a named class over a bare `table` parameter, declaring it next to its first use and marking fields that fixtures may omit as optional:

```lua
--- @class QuickfixTestItem
--- @field path string?
--- @field lnum integer?
```

Typing async functions and awaited values is covered in `writing-async-neovim-lua`.

## Use a prefixed notify helper

Prefix plugin notifications and use `string.format` arguments:

```lua
--- @param level vim.log.levels
--- @param msg string
--- @param ... any
local notify = function(level, msg, ...)
  msg = "[plugin-name.nvim]: " .. msg
  vim.notify(msg:format(...), level)
end
```

## Notify before early returns

Call `notify` before early returns that indicate an unexpected issue, such as a required value being `nil` or a command result having `out.code ~= 0`. Do not notify for every early return: expected control flow, such as optional values being absent or normal cancellation, should return quietly.

## Use a typed `nonnil` helper

Prefer a generic helper with LuaLS annotations over native non-nil assertions:

```lua
--- @generic T
--- @param val T | nil
--- @param default_val T
--- @return T
local nonnil = function(val, default_val)
  if val == nil then
    return default_val
  end
  return val
end
```

## Global `vim.g.plugin-name.*` variables

- Global plugin config should be passed through `vim.g.plugin-name.*`
- Function options are still passed through the function
- Global state within the plugin can live in local variables declared at the top scope

## Expose window/buffer options via a user event

```lua
-- plugin
vim.api.nvim_exec_autocmds("User", {
  pattern = "PluginNameOpen",
  data = {
    winnr = input_win,
    bufnr = input_buf,
  },
})

-- config
vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("PluginNameWinOpts", { clear = true }),
  pattern = "PluginNameOpen",
  callback = function(ev)
    local winnr = ev.data.winnr
    vim.api.nvim_win_set_config(winnr, {
      border = "single",
    })
    vim.wo[winnr].number = true
    vim.wo[winnr].scrolloff = 0
  end,
})
```
