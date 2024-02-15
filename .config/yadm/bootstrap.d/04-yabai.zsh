#!/usr/bin/env zsh

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi


info "Configuring yabai"

yabai --install-service

notice "Setting up yabai scripting addition requires root access"
if ask "Would you like to configure it?"; then
  yabai_path="$(which yabai)"
  yabai_hash="$(shasum -a 256 "$yabai_path" | cut -d ' ' -f1)"
  sudo_line="$(whoami) ALL=(root) NOPASSWD: sha256:$yabai_hash $yabai_path --load-sa"
  sudoers_file="/private/etc/sudoers.d/yabai"

  msg "Adding to $sudoers_file"
  echo "$sudo_line" | sudo tee -a "$sudoers_file"
fi

notice "yabai requires accessibility permissions"
yabai --start-service

if ask "Did you have to enable the accessibility permissions and need to restart yabai?"; then
  yabai --restart-service
fi

info "Configuring skhd"

skhd --install-service

notice "skhd requires accessibility permissions"
skhd --start-service

if ask "Did you have to enable the accessibility permissions and need to restart skhd?"; then
  yabai --restart-service
fi
