-- See https://wiki.hyprland.org/Configuring/Monitors/

-- Catch-all: an empty output name matches every monitor.
hl.monitor({ output = "", mode = "highres", position = "auto", scale = "auto" })

-- creates a virtual monitor; name is arbitrary but must match later
-- hl.monitor({ output = "HEADLESS-1", mode = "2960x1440@60", position = "0x0", scale = 1 })
