#!/usr/bin/env zsh
#
# Update system-wide settings
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi

info "Enable Remote Login (ssh)"
sudo systemsetup -setremotelogin on
