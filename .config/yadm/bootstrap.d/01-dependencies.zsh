#!/usr/bin/env zsh
#
# Installs dependencies
#

set -euo pipefail

if is-macos; then
  if ! (( $+commands[brew] )); then
    log info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  require dropbox "/Applications/Dropbox.app"
  require 1password "/Applications/1Password 7.app"
  require gpg-suite "/Applications/GPG Keychain.app"

  notice "Now you should configure Dropbox, 1Password and your GPG keys. Get back to the terminal when finished."
  ask "Are you ready to proceed?" || exit 1
fi
