#!/usr/bin/env zsh
#
# Node.js setup
#

set -euo pipefail

mkdir -p ~/.nvm
export NVM_DIR="$HOME/.nvm"

if ! (( $+commands[nvm] )); then
  if [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
    source "/usr/local/opt/nvm/nvm.sh"
  elif [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
  else
    nvm_version="$(get-latest-tag nvm-sh/nvm)"
    info "Installing nvm ${nvm_version}"
    curl -fsSLo- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash
    source "$NVM_DIR/nvm.sh"
  fi
fi

info "Installing Node.js"
nvm install stable --default --reinstall-packages-from=stable
