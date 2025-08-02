local wezterm = require 'wezterm'
local act = wezterm.action

-- https://stackoverflow.com/a/326715
function os.capture(cmd)
  local file = assert(io.popen(cmd, 'r'))
  local stdout = assert(file:read('*a'))
  file:close()
  stdout = string.gsub(stdout, '^%s+', '')
  stdout = string.gsub(stdout, '%s+$', '')
  stdout = string.gsub(stdout, '[\n\r]+', ' ')
  return stdout
end

local function is_linux()
  return os.capture("uname -s") == "Linux"
end

local function cmd_or_ctrl()
  return is_linux() and 'CTRL' or 'CMD'
end

local config = wezterm.config_builder()
config.font = wezterm.font(
  'ComicCodeLigatures Nerd Font'
)
config.font_size = 13.0

config.leader = { key = "Space", mods = 'CTRL' }
config.keys = {
  { key = 'v', mods = cmd_or_ctrl(), action = act.PasteFrom 'Clipboard' },
  { key = 'p', mods = 'LEADER',      action = act.ActivateTabRelative(-1) },
  { key = 'n', mods = 'LEADER',      action = act.ActivateTabRelative(1) },
  { key = 'q', mods = 'LEADER',      action = act.QuitApplication },
  { key = 'x', mods = 'LEADER',      action = act.CloseCurrentTab { confirm = true } },
  { key = 'd', mods = 'LEADER',      action = act.CloseCurrentPane { confirm = true } },
  { key = 'c', mods = 'LEADER',      action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'u', mods = 'LEADER',      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = 'i', mods = 'LEADER',      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = 'l', mods = 'LEADER',      action = act.ActivatePaneDirection "Right" },
  { key = 'h', mods = 'LEADER',      action = act.ActivatePaneDirection "Left" },
  { key = 'k', mods = 'LEADER',      action = act.ActivatePaneDirection "Up" },
  { key = 'j', mods = 'LEADER',      action = act.ActivatePaneDirection "Down" },
  { key = 'm', mods = 'LEADER',      action = act.TogglePaneZoomState },
  { key = 'v', mods = 'LEADER',      action = act.ActivateCopyMode },
}
if is_linux() then
  config.window_decorations = "NONE"
end
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.colors = {
  cursor_bg = '#b4b7b4',
  cursor_border = '#b4b7b4',
  tab_bar = {
    active_tab = {
      bg_color = '#373b41',
      fg_color = '#f0c674',
    },
    inactive_tab = {
      bg_color = '#282a2e',
      fg_color = '#c5c8c6',
    },
  },
  selection_fg = '#282a2e',
  selection_bg = '#f0c674',
}

return config
