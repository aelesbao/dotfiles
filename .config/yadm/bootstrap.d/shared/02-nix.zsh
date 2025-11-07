#!/usr/bin/env zsh
#
# Nix setup
#

set -euo pipefail

if ! has-command nix; then
  msg "nix not found"
  return 1
fi

if has-command systemctl; then
  info "Enabling nix-daemon"
  systemctl enable --now nix-daemon.service
fi

info "Adding nixpkgs-unstable channel"
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update
