#!/usr/bin/env zsh
#
# Installs dependencies
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi


if ! (( $+commands[brew] )); then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make sure curl is installed via Homebrew and using the latest version (with OpenSSL)
require curl
require 1password
require gpg-suite

notice "Dependencies installed. If necessary, please configure them before proceeding."
ask "Are you ready to continue?" || fail "Aborting"
