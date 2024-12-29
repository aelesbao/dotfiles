#!/usr/bin/env zsh
#
# Installs dependencies
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi


if ! has-command brew; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

info "Installing 1Password and GPG Tools"
require 1password
require gpg-suite

notice "Dependencies installed. Please configure them accordingly before proceeding."
ask "Are you ready to continue?" || fail "Aborting"
