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
    msg "nvm not found, skipping..."
    return 1
  fi
fi

info "Configuring Node.js"

nvm install --lts
nvm install node --default
