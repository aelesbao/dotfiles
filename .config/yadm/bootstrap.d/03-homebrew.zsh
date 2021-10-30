#!/usr/bin/env zsh
#
# Installs dependencies
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a MacOS"
  return 0
fi

if [[ -f "$HOME/.Brewfile" ]]; then
  info "Updating Homebrew bundle"
  brew bundle --global --cleanup
fi
