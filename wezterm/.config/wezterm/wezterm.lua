local wezterm = require 'wezterm'
local act = wezterm.action

-- https://stackoverflow.com/a/326715
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
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
config.keys = {
  { key = 'v', mods = cmd_or_ctrl(),             action = act.PasteFrom 'Clipboard' },
  { key = 't', mods = 'CMD',                     action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'y', mods = cmd_or_ctrl() .. '|SHIFT', action = act.CloseCurrentTab { confirm = true } },
  { key = '{', mods = cmd_or_ctrl() .. '|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = '}', mods = cmd_or_ctrl() .. '|SHIFT', action = act.ActivateTabRelative(1) },
}
config.colors = {
  cursor_bg = '#b4b7b4',
}
if is_linux() then
  config.window_decorations = "NONE"
end
config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = false

return config
