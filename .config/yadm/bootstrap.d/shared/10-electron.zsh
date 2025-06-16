#!/usr/bin/env zsh
#
# Global flgas for Electron apps
#

set -euo pipefail

if ! is-linux; then
  notice "Skipping Electron setup"
  return
fi

info "Configuring global Electron flags"

cat <<EOF >! ~/.config/electron-flags.conf
--password-store=gnome-libsecret
--enable-features=UseOzonePlatform
--enable-wayland-ime
--ozone-platform=wayland
EOF

declare -a apps=(
  brave
  chrome
  code
  cursor
  ferdium
  mailspring
  proton-mail
  signal-desktop
  slack
  windsurf
)

for app in ${apps[@]}; do
  ln -sf ~/.config/electron-flags.conf ~/.config/$app-flags.conf
done
