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

  # Make sure curl is installed via Homebrew and using the latest version (with OpenSSL)
  brew --prefix curl >/dev/null 2>&1 || brew install -f curl

  require dropbox "/Applications/Dropbox.app"
  require 1password "/Applications/1Password 7.app"
  require gpg-suite "/Applications/GPG Keychain.app"
fi

notice "Dependencies installed. If necessary, please configure them before proceeding."
ask "Are you ready to continue?" || fail "Aborting"
