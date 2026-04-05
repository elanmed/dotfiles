local wezterm = require "wezterm"

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

local function toggle_pane_height()
  return wezterm.action_callback(function(win, pane)
    local is_top_pane = true
    for _, pane_info in ipairs(win:active_tab():panes_with_info()) do
      if pane_info.pane:pane_id() == pane:pane_id() then
        is_top_pane = pane_info.top == 0
        break
      end
    end

    local grow_direction = is_top_pane and "Down" or "Up"
    local shrink_direction = is_top_pane and "Up" or "Down"

    local curr_height = pane:get_dimensions().viewport_rows
    local max_height = win:active_tab():get_size().rows

    local half_max_height = math.floor(max_height / 2)

    if curr_height > half_max_height then
      -- shrinks by this amount
      win:perform_action(wezterm.action.AdjustPaneSize { shrink_direction, curr_height - half_max_height, }, pane)
    else
      win:perform_action(wezterm.action.AdjustPaneSize { grow_direction, max_height - curr_height, }, pane)
    end
  end)
end

config.leader = { key = "Space", mods = "CTRL", }
config.keys = {
  { key = "v", mods = cmd_or_ctrl(), action = wezterm.action.PasteFrom "Clipboard", },
  { key = "p", mods = "LEADER|CTRL", action = wezterm.action.ActivateTabRelative(-1), },
  { key = "n", mods = "LEADER|CTRL", action = wezterm.action.ActivateTabRelative(1), },
  { key = "q", mods = "LEADER|CTRL", action = wezterm.action.QuitApplication, },
  { key = "x", mods = "LEADER|CTRL", action = wezterm.action.CloseCurrentTab { confirm = true, }, },
  { key = "d", mods = "LEADER|CTRL", action = wezterm.action.CloseCurrentPane { confirm = true, }, },
  { key = "c", mods = "LEADER|CTRL", action = wezterm.action.SpawnTab "CurrentPaneDomain", },
  { key = "u", mods = "LEADER|CTRL", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain", }, },
  { key = "i", mods = "LEADER|CTRL", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain", }, },
  { key = "k", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection "Up", },
  { key = "j", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection "Down", },
  { key = "v", mods = "LEADER|CTRL", action = wezterm.action.ActivateCopyMode, },
  { key = "e", mods = "LEADER|CTRL", action = wezterm.action.TogglePaneZoomState, },
  { key = "t", mods = "LEADER|CTRL", action = toggle_pane_height(), },
  { key = "l", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection "Right", },
  { key = "h", mods = "LEADER|CTRL", action = wezterm.action.ActivatePaneDirection "Left", },
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString "\x16\n", },
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

wezterm.on("format-tab-title", function(tab)
  local cwd = tab.active_pane.current_working_dir
  if not cwd then return "[no cwd]" end

  local path = cwd.file_path
  local basename = path:match "([^/]+)/?$"
  local min_width = 16
  local padding = math.max(2, min_width - #basename)
  local left_pad = math.floor(padding / 2)
  local right_pad = padding - left_pad
  return string.rep(" ", left_pad) .. basename .. string.rep(" ", right_pad)
end)

return config
