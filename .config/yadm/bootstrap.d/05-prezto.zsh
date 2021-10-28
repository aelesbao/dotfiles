#!/usr/bin/env zsh
#
# Prezto setup
#

set -euo pipefail

if ! [[ -d "${HOME}/.zprezto" ]]; then
  msg "~/.zprezto not found"
  return 0
fi

info "Configuring Prezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

chsh -s /bin/zsh
