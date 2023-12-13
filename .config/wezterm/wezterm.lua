-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font('Hack Nerd Font')
config.font_size = 15.0

-- Looks better on MacBook displays
config.freetype_load_flags = 'DEFAULT'
config.freetype_load_target = 'Light'
config.freetype_render_target = 'Light'
config.freetype_interpreter_version = 40

config.color_scheme = 'Catppuccin Mocha'

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.8,
}

config.window_background_opacity = 0.95
config.macos_window_background_blur = 5

config.window_decorations = 'RESIZE'
config.native_macos_fullscreen_mode = true

config.initial_cols = 160
config.initial_rows = 60

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

config.hide_mouse_cursor_when_typing = true

config.disable_default_key_bindings = false

config.keys = {
  {
    key = 'Enter',
    mods = 'SUPER',
    action = wezterm.action.ToggleFullScreen,
  },
}

return config
