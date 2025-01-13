local wezterm = require 'wezterm'
local act = wezterm.action

local function is_linux()
  return package.cpath:match("%p[\\|/]?%p(%a+)") == "so"
end

local function cmd_or_ctrl()
  return is_linux() and 'CTRL' or 'CMD'
end

local config = wezterm.config_builder()

config.font_size = 13.0
config.font = wezterm.font(
  'ComicCode Ligatures Nerd Font'
)
config.keys = {
  { key = 'v', mods = cmd_or_ctrl(),             action = act.PasteFrom 'Clipboard' },
  { key = 't', mods = cmd_or_ctrl(),             action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = cmd_or_ctrl(),             action = act.CloseCurrentTab { confirm = true } },
  { key = 'n', mods = cmd_or_ctrl(),             action = act.SpawnWindow },
  { key = '{', mods = cmd_or_ctrl() .. '|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = cmd_or_ctrl() .. '|SHIFT', action = act.ActivateTabRelative(1) },
}
config.colors = {
  cursor_bg = '#b4b7b4',
}
config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = false

return config
