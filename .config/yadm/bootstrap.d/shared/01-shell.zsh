#!/usr/bin/env zsh
#
# Prezto setup
#

set -euo pipefail


declare zsh_path="$(command -v zsh)"
if { is-macos && ! (dscl . -read ~/ UserShell | grep -q "UserShell: $zsh_path") } || \
  { is-linux && ! (grep -q "^$USER:.*:$(command -v zsh)\$" /etc/passwd) }; then
  info "Changing $USER's shell to $zsh_path"

  if is-macos; then
    chsh -s "$zsh_path"
  else
    sudo chsh -s "$zsh_path" "$USER"
  fi
fi

if [[ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
  fail "~/.zprezto not found"
fi

info "Configuring Prezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
