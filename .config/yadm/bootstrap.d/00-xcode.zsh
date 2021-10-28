#!/usr/bin/env zsh
#
# XCode Command Line Tools
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a MacOS"
  return 0
fi

info "Installing XCode Command Line Tools"

if xcode-select --print-path &> /dev/null; then
  msg "XCode Command Line Tools already installed"
  return 0
fi

# Prompt user to install the XCode Command Line Tools
xcode-select --install &> /dev/null

# Wait until the XCode Command Line Tools are installed
until xcode-select --print-path &> /dev/null; do
  sleep 3
done

result "XCode Command Line Tools installation"

# Prompt user to agree to the terms of the Xcode license
sudo xcodebuild -license
result "XCode Command Line Tools license agreement"
