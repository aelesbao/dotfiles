hl.config({
  layout = {
    -- whenever only a single window is shown on a screen, add padding so that it conforms to the specified aspect ratio.
    -- A value like 4 3 on a 16:9 screen will make it a 4:3 window in the middle with padding to the sides.
    single_window_aspect_ratio = { 16, 9 },
  },

  -- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
  dwindle = {
    -- Master switch for pseudotiling. Enabling is bound to actionMod + P in keybindings.lua
    -- pseudotile = true,
    -- You probably want this
    preserve_split = true,
    -- specifies which window will receive the split ratio. 0 -> directional (the top or left window), 1 -> the current window
    split_bias = 1,
  },

  -- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
  master = {
    new_status = "master",
  },
})
