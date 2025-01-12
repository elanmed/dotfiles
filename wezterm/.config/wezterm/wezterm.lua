local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

config.font_size = 13.0

config.keys = {
  { key = 'v', mods = 'CTRL',       action = act.PasteFrom 'Clipboard' },
  { key = 't', mods = 'CTRL',       action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL',       action = act.CloseCurrentTab { confirm = false } },
  { key = 'n', mods = 'CTRL',       action = act.SpawnWindow },
  { key = '{', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
}
config.colors = {
  cursor_bg = '#b4b7b4',
}
config.window_decorations = "NONE"

return config
