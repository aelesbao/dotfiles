-- Commands launched from keybindings and autostart (was vars/apps.conf).

return {
  -- Launchers
  launcher = "~/.local/bin/walker-launch",
  switcher = "~/.local/bin/walker-launch -m windows",
  calc = "~/.local/bin/walker-launch -m calc",
  emoji = "~/.local/bin/walker-launch -m symbols",
  clipboard_history = "~/.local/bin/walker-launch -m clipboard",

  -- uses proposed xdg-terminal-exec
  terminal = "uwsm app -- ghostty +new-window",
  file_manager = "uwsm app -- thunar --window",
  password_manager = "uwsm app -a 1password-quick-access -- 1password --quick-access",

  notification_history = "swaync-client --skip-wait --toggle-panel",
  dismiss_notifications = "swaync-client --skip-wait --hide-all",
  toggle_dnd = "swaync-client --skip-wait --toggle-dnd",

  color_picker = "uwsm app -- hyprpicker --autocopy --lowercase-hex",
  screenshot = "uwsm app -- hyprshot -m region -o ~/Pictures/Screenshots",

  -- Volume and brightness, via SwayOSD so changes get an on-screen indicator.
  --
  -- Alternatives kept for reference:
  --   vol_up      = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
  --   vol_down    = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  --   vol_mute    = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  --   vol_up      = "set-volume up 5"        -- helper with notifications
  --   bright_up   = "brightnessctl s 10%+"
  vol_up = "swayosd-client --output-volume +3 --max-volume 100",
  vol_down = "swayosd-client --output-volume -3 --max-volume 100",
  vol_mute = "swayosd-client --output-volume mute-toggle",

  vol_mic_up = "swayosd-client --input-volume +3 --max-volume 100",
  vol_mic_down = "swayosd-client --input-volume -3 --max-volume 100",
  vol_mic_mute = "swayosd-client --input-volume mute-toggle",

  bright_up = "swayosd-client --brightness raise",
  bright_down = "swayosd-client --brightness lower",

  -- Track navigation goes through SwayOSD; seeking has no SwayOSD equivalent
  -- and still calls playerctl directly.
  player_next = "swayosd-client --playerctl next",
  player_previous = "swayosd-client --playerctl prev",
  player_play = "swayosd-client --playerctl play-pause",
  player_pause = "swayosd-client --playerctl play-pause",
  player_forward = "playerctl position +5",
  player_rewind = "playerctl position -5",

  -- Productivity tools
  -- Unbound as of the Lua migration; kept because it is a fiddly command to reconstruct.
  todo = "uwsm app -- flatpak run --command=io.github.alainm23.planify.quick-add io.github.alainm23.planify",
}
