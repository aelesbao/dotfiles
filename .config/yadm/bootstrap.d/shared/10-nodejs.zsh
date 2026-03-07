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
  elif [ -s "/usr/share/nvm/init-nvm.sh" ]; then
    source "/usr/share/nvm/init-nvm.sh"
  elif [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
  else
    nvm_version="$(gh-latest-tag nvm-sh/nvm)"
    info "Installing nvm ${nvm_version}"
    curl -fsSLo- "https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh" | bash
    source "$NVM_DIR/nvm.sh"
  fi
fi

info "Installing latest stable Node.js version"
nvm install stable --default --latest-npm --reinstall-packages-from=stable

function npm-install() {
  local package="$1"
  msg "${package}..."
  npm install -g "$package"
  echo
}

info "Installing global packages"
nvm use default
npm-install @anthropic-ai/claude-code
npm-install @zed-industries/claude-agent-acp
npm-install mcp-hub

info "Installing Claude Code native build"
claude install
