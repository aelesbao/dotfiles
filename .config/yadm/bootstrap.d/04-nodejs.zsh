#!/usr/bin/env zsh
#
# Node.js setup
#

set -euo pipefail

if ! (( $+commands[nvm] )); then
  if [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
    source "/usr/local/opt/nvm/nvm.sh"
  elif [ -s "$HOME/.nvm/nvm.sh" ]; then
    source "$HOME/.nvm/nvm.sh"
  else
    msg "nvm not found, skipping..."
    return 1
  fi
fi

info "Configuring Node.js"

mkdir ~/.nvm
export NVM_DIR="$HOME/.nvm"

nvm install --lts
nvm install node --default
