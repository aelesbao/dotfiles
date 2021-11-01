#!/usr/bin/env zsh
#
# XCode Command Line Tools
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a MacOS"
  return
fi

if xcode-select --print-path &> /dev/null; then
  notice "XCode Command Line Tools already configured"
else
  title "Installing XCode Command Line Tools"

  # Prompt user to install the XCode Command Line Tools
  xcode-select --install &> /dev/null

  # Wait until the XCode Command Line Tools are installed
  until xcode-select --print-path &> /dev/null; do
    sleep 3
  done

  if [[ $? -eq 0 ]]; then
    notice "Agree to the XCode Command Line Tools license"
    sudo xcodebuild -license
  fi
fi
