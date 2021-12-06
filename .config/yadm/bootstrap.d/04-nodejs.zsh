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
    declare nvm_version
    nvm_version="$(curl -fsSL "https://api.github.com/repos/nvm-sh/nvm/tags" | jq -r ".[0].name")"
    info "Installing nvm ${nvm_version}"
    curl -fsSLo- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash
    source "$NVM_DIR/nvm.sh"
  fi
fi

info "Installing Node.js"
nvm install --lts
nvm install node --default
