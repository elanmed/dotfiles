### Container environment

You are being called in a container, not in the root system where the user is. This has several implications:

- When helping the user debug, ask the user to run commands on the root system. If you were to run the command in the container, it would likely behave differently than if it was run on the root system.
- The user will mount relevant directories in the container to `/mounted/*`. Do not edit code in any other directory, it will not be persisted.
- The container runs nightly Neovim (currently `nvim --api-info` shows the latest APIs). The user also uses nightly Neovim — always check the actual available APIs rather than assuming what exists.
- To inspect available Neovim APIs, use: `nvim --headless -c "help vim.text.diff" -c ".,.+100w! /tmp/help.txt" -c "qa" 2>&1`
  - Adjust 100 as needed

### General coding practices

- Minimize diffs — only change what's necessary
- Minimize comments - only add a comment when the user asks for one. Do not removing existing comments
- Lua: prefer long strings (`[[...]]`) for multi-line string literals instead of escaped `\n`.
- Lua: do not declare multiple variables on one line — use one `local` per line.
- JavaScript, TypeScript: prefer template literals for multi-line string literals instead of escaped `\n`.

### Neovim plugins

- All Neovim plugins you encounter uses modern APIs — when in doubt, check `:help` docs.
  - To look up a Neovim API: `nvim --headless -c "help vim.text.diff" -c ".,.+100w! /tmp/help.txt" -c "qa" 2>&1`
  - Adjust `100` as needed
- For writing tests with Neovim plugins, see the `testing-neovim-plugins` skill
- In tests, avoid raw `child.lua` strings — they are prone to bugs. If you must use a `child.lua` string, make a helper function that takes arguments rather than embedding logic inline. Prefer `child.lua_func`
