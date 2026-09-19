-- See https://wiki.hyprland.org/Configuring/Monitors/

-- Catch-all: an empty output name matches every monitor.
hl.monitor({
  output = "desc:Samsung Electric Company Odyssey G95SC H1AK500000",
  mode = "5120x1440@240",
  position = "auto",
  scale = "auto",
})

hl.monitor({
  output = "",
  mode = "highres",
  position = "auto",
  scale = "auto",
})

-- creates a virtual monitor; name is arbitrary but must match later
-- hl.monitor({ output = "HEADLESS-1", mode = "2960x1440@60", position = "0x0", scale = 1 })
