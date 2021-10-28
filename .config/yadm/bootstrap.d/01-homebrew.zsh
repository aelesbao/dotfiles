#!/usr/bin/env zsh
#
# Installs Homebrew
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a MacOS"
  return 0
fi

if ! (( $+commands[brew] )); then
  log info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -f "$HOME/.Brewfile" ]]; then
  info "Updating Homebrew bundle"
  brew bundle --global
fi
