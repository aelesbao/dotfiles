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

if ask "Select model to run?"; then
  voxtype setup model
fi

if ask "Enable GPU support?"; then
u sudo voxtype setup gpu --enable
fi

info "Checking setup status"
voxtype setup check

info "Setting up systemd service"
voxtype setup systemd
