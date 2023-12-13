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
  path=$(which yabai)
  hash=shasum -a 256 $(which yabai) | cut -d ' ' -f1
  sudo_line="$(whoami) ALL=(root) NOPASSWD: sha256:$hash $path --load-sa"
  sudoers_file="/private/etc/sudoers.d/yabai"

  msg "Adding to $sudoers_file"
  echo "$sudo_line" | sudo tee -a "$sudoers_file"
fi

yabai --start-service

notice "yabai requires accessibility permissions"
ask "Are you ready to continue?" || fail "Aborting"

yabai --restart-service


info "Configuring skhd"

skhd --install-service
skhd --start-service

notice "skhd requires accessibility permissions"
ask "Are you ready to continue?" || fail "Aborting"

skhd --restart-service
