#!/usr/bin/env zsh
#
# Node.js setup
#

set -euo pipefail

if ! (( $+commands[fnm] )); then
  if [ -x "$HOME/.local/share/fnm/fnm" ]; then
    export PATH="$HOME/.local/share/fnm:$PATH"
  elif [ -x "$HOME/.fnm/fnm" ]; then
    export PATH="$HOME/.fnm:$PATH"
  else
    info "Installing fnm"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    export PATH="$HOME/.local/share/fnm:$PATH"
  fi
fi

eval "$(fnm env --use-on-cd --shell zsh)"

info "Installing latest Node.js version"
fnm install --latest
fnm default latest

function npm-install() {
  local package="$1"
  msg "${package}..."
  npm install --global "$package"
  echo
}

info "Installing global packages"
fnm use latest
npm-install yarn
npm-install typescript
npm-install typescript-language-server
npm-install @zed-industries/claude-agent-acp
npm-install @doist/todoist-cli
npm-install mcp-hub

info "Installing Claude Code native build"
curl -fsSL https://claude.ai/install.sh | bash
