#!/usr/bin/env zsh
#
# Installs dependencies
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a MacOS"
  return 0
fi

require mas

if ! mas account >/dev/null 2>&1; then
  warn "Not logged in into Mac App Store"
  if ask "Do you want to sign in into the App Store now?"; then
    osascript -e '
      tell application "App Store"
        activate
      end tell'
  fi
fi

if [[ -f "$HOME/.Brewfile" ]]; then
  info "Updating Homebrew bundle"
  brew bundle --global --cleanup
fi
