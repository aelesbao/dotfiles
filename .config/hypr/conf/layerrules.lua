-- See https://wiki.hyprland.org/Configuring/Window-Rules/#layer-rules

hl.layer_rule({
  name = "waybar-blur",
  match = { namespace = "waybar" },
  blur = true,
  ignore_alpha = 0.5,
})

hl.layer_rule({
  name = "rofi-fx",
  match = { namespace = "rofi" },
  animation = "popin 20%",
  dim_around = true,
})

hl.layer_rule({
  name = "walker-fx",
  match = { namespace = "walker" },
  animation = "popin 20%",
  dim_around = true,
})

hl.layer_rule({
  name = "swaync-control-center-fx",
  match = { namespace = "swaync-control-center" },
  animation = "slide right",
  dim_around = true,
})

hl.layer_rule({
  name = "swaync-notification-window-fx",
  match = { namespace = "swaync-notification-window" },
  animation = "slide right",
  ignore_alpha = 0,
})

hl.layer_rule({
  name = "no-anim-for-selection",
  match = { namespace = "selection" },
  no_anim = true,
})
