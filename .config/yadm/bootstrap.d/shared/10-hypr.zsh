#!/usr/bin/env zsh
#
# Configures [Hyprland](https://hypr.land/)
#

set -euo pipefail

if ! has-command Hyprland; then
  msg "Hyprland is not installed"
  return
fi

if ! has-command lua; then
  msg "lua is not installed"
  return
fi


info "Configuring Hyprland"

# hyprland.lua is the source of truth for colors and fonts, but hyprlock and the
# other hypr* daemons are still hyprlang. Hyprland regenerates vars/*.conf on
# every config load; do it here too so a freshly bootstrapped machine can lock
# its screen before Hyprland has ever started.
msg "Generating hyprlang vars for hyprlock"
"${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/gen-hyprlang-vars"
