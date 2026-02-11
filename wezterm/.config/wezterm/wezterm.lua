local wezterm = require "wezterm"
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
  local file = assert(io.popen(cmd, "r"))
  local stdout = assert(file:read "*a")
  file:close()
  stdout = string.gsub(stdout, "^%s+", "")
  stdout = string.gsub(stdout, "%s+$", "")
  stdout = string.gsub(stdout, "[\n\r]+", " ")
  return stdout
end

local function is_linux()
  return os.capture "uname -s" == "Linux"
end

local function cmd_or_ctrl()
  return is_linux() and "CTRL" or "CMD"
end

local config = wezterm.config_builder()
config.font = wezterm.font "ComicCodeLigatures Nerd Font"
config.font_size = 12.0

local function is_nvim(pane)
  return pane:get_user_vars().IS_NVIM == "true"
end

local function smart_move(key, direction)
  return wezterm.action_callback(function(win, pane)
    if is_nvim(pane) then
      win:perform_action(wezterm.action.SendKey { key = " ", mods = "CTRL", }, pane)
      win:perform_action(wezterm.action.SendKey { key = key, mods = "CTRL", }, pane)
    else
      win:perform_action({ ActivatePaneDirection = direction, }, pane)
    end
  end)
end

config.leader = { key = "Space", mods = "CTRL", }
config.keys = {
  { key = "v", mods = cmd_or_ctrl(), action = act.PasteFrom "Clipboard", },
  { key = "p", mods = "LEADER|CTRL", action = act.ActivateTabRelative(-1), },
  { key = "n", mods = "LEADER|CTRL", action = act.ActivateTabRelative(1), },
  { key = "q", mods = "LEADER|CTRL", action = act.QuitApplication, },
  { key = "x", mods = "LEADER|CTRL", action = act.CloseCurrentTab { confirm = true, }, },
  { key = "d", mods = "LEADER|CTRL", action = act.CloseCurrentPane { confirm = true, }, },
  { key = "c", mods = "LEADER|CTRL", action = act.SpawnTab "CurrentPaneDomain", },
  { key = "u", mods = "LEADER|CTRL", action = act.SplitHorizontal { domain = "CurrentPaneDomain", }, },
  { key = "i", mods = "LEADER|CTRL", action = act.SplitVertical { domain = "CurrentPaneDomain", }, },
  { key = "k", mods = "LEADER|CTRL", action = act.ActivatePaneDirection "Up", },
  { key = "j", mods = "LEADER|CTRL", action = act.ActivatePaneDirection "Down", },
  { key = "e", mods = "LEADER|CTRL", action = act.TogglePaneZoomState, },
  { key = "v", mods = "LEADER|CTRL", action = act.ActivateCopyMode, },
  { key = "l", mods = "LEADER|CTRL", action = smart_move("l", "Right"), },
  { key = "h", mods = "LEADER|CTRL", action = smart_move("h", "Left"), },
  { key = "Enter", mods = "CTRL", action = act.SendString "\x16\n", },
}
if is_linux() then
  config.window_decorations = "NONE"
end
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.colors = {
  split = colors.purple,
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
}
config.inactive_pane_hsb = {
  saturation = 1,
  brightness = 1,
}

return config
