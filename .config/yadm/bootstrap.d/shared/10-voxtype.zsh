#!/usr/bin/env zsh
#
# Configures [voxtype](https://github.com/peteonrails/voxtype)
#

set -euo pipefail

if ! has-command voxtype; then
  msg "voxtype is not installed"
  return
fi


info "Configuring voxtype"
voxtype setup
voxtype setup --download

if ask "Select model to run?"; then
  voxtype setup model
fi

if ask "Enable GPU support?"; then
  sudo voxtype setup gpu --enable
fi

msg "Checking setup status"
voxtype setup check

msg "Setting up systemd service"
voxtype setup systemd
systemctl --user enable --now voxtype
