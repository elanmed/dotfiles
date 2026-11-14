---
name: auditing-neovim-plugin-tests
description: Use when auditing or bringing the existing test suite of a Neovim plugin up to the user's standards (mini.test layout, child-process tests, fixtures, stubs, async test patterns).
---

# Auditing a plugin's test suite

Bring the test suite of the repo this skill is run in up to the user's testing
standards. Read these in full before inspecting anything; they are the criteria:

- `testing-neovim-plugins` — test layout, child-process tests, fixtures, stubs, assertions. Primary source.
- `writing-neovim-lua` — style and type annotations that test code must also follow.
- `writing-async-neovim-lua` — async helpers under test and how to test them (`vim.async`, wrapped callbacks).

Scope is the tests (`tests/`, test `Makefile` target, `scripts/minimal_init.lua`,
helpers, fixtures). Production-code changes only when a test cannot meet the
standards without one — call those out separately in the plan and leave them
until the user approves.

## Plan first; do not make changes

Read the standards and the current test suite, then present a prioritized plan of
the concrete edits (per test file, plus runner/helper changes) and how you will
verify it. Do not edit project files while planning. Write the plan to a local
`PLAN.md` (do not commit it), show the steps, and wait for explicit approval
before implementing.

After approval, work through the steps; after each completed step show the
remaining ones.

## Then implement

- Prefer rewriting a case over patching it: same test intent, standards-compliant
  shape (child process where Vim state is involved, literal expectations, mock
  helper for stubs, polling instead of fixed sleeps).
- Keep one test file per source module, and move/grow shared helpers per the
  standards as you go; re-read the other test files after adding a helper.
- Run the suite after each file, and the whole suite at the end; report the
  actual result. Also check the runner surfaces hangs and real failures (generous
  timeout in the test Makefile target).
