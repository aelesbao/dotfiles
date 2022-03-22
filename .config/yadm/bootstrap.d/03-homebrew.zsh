#!/usr/bin/env zsh
#
# Installs dependencies
#

set -euo pipefail

if ! is-macos; then
  notice "Homebrew is only available on macOS"
  return
fi

if ! [[ -f "$HOME/.Brewfile" ]]; then
  fail "~/.Brewfile not found"
fi

info "Configuring Mac App Store CLI"

require mas

if ! mas account >/dev/null 2>&1; then
  warn "To install all packages from the Homebrew Bundle file, you should first sign in into the App Store"
  if ask "Do you want to do it now?"; then
    osascript -e '
      tell application "App Store"
        activate
      end tell'

    msg "Waiting for the user to sign in..."
    until mas account >/dev/null 2>&1; do
      sleep 3
    done

    notice "Done!"
  fi
fi

info "Updating Homebrew bundle"
brew bundle --global
