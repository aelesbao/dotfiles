-- Modifier combinations shared by conf.d/keybindings.lua and conf.d/voxtype-submap.lua.
--
-- Under hyprlang these lived in conf.d/keybindings.conf and only reached
-- voxtype-submap.conf because `source = ./conf.d/*` globs alphabetically.
-- Keeping them here makes that dependency explicit.

return {
  mod = "SUPER",
  nav = "SUPER + CONTROL",
  alt = "SUPER + ALT",
  action = "SUPER + CONTROL + SHIFT",
  alt_action = "SUPER + ALT + SHIFT",
  hyper = "SUPER + CONTROL + ALT + SHIFT",
}
