local wezterm = require 'wezterm'
local act = wezterm.action

local colors = {
  black = "#1d1f21",
  extra_dark_grey = "#282a2e",
  dark_grey = "#373b41",
  grey = "#969896",
  light_grey = "#b4b7b4",
  extra_light_grey = "#c5c8c6",
  dark_white = "#e0e0e0",
  white = "#ffffff",
  red = "#cc6666",
  orange = "#de935f",
  yellow = "#f0c674",
  green = "#b5bd68",
  cyan = "#8abeb7",
  blue = "#81a2be",
  purple = "#b294bb",
  brown = "#a3685a",
}

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
  split = colors.light_grey,
  cursor_bg = colors.light_grey,
  cursor_border = colors.light_grey,
  tab_bar = {
    background = colors.extra_dark_grey,
    active_tab = {
      bg_color = colors.dark_grey,
      fg_color = colors.purple,
    },
    inactive_tab = {
      bg_color = colors.extra_dark_grey,
      fg_color = colors.extra_light_grey,
    },
    new_tab = {
      bg_color = colors.extra_dark_grey,
      fg_color = colors.purple,
    },
  },
  selection_fg = colors.extra_dark_grey,
  selection_bg = colors.yellow,
}
config.inactive_pane_hsb = {
  saturation = 1,
  brightness = 1,
}

return config
