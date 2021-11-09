#!/usr/bin/env zsh
#
# XCode Command Line Tools
#

set -euo pipefail

if ! is-macos; then
  msg "XCode Command Line Tools are only available on macOS"
  return
fi

info "Installing XCode Command Line Tools"

if ! xcode-select --install &> /dev/null; then
  notice "XCode Command Line Tools already installed"
  return
fi

# Wait until the XCode Command Line Tools are installed
until xcode-select --print-path &> /dev/null; do
  sleep 3
done

if [[ $? -eq 0 ]]; then
  notice "Agree to the XCode Command Line Tools license"
  sudo xcodebuild -license
fi
