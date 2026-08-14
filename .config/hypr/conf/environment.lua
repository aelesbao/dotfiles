-- See https://wiki.hyprland.org/Configuring/Environment-variables/

-- INFO: uwsm users should avoid placing environment variables in the
-- compositor config. Instead, use ~/.config/uwsm/env for theming, xcursor,
-- nvidia and toolkit variables, and ~/.config/uwsm/env-hyprland for HYPR* and
-- AQ_* variables. Both files exist; these are still here for parity with the
-- pre-Lua config and are a candidate for a follow-up move.

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Nodzy-hyprcursors")

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
