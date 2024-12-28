#!/usr/bin/env zsh
#
# Prezto setup
#

set -euo pipefail

if ! [[ -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
  msg "~/.zprezto not found"
  return 1
fi

info "Configuring Prezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

declare current_shell="$(finger $USER | grep 'Shell:*' | cut -f3 -d ':' | sed 's/ //g')"
if [[ "$current_shell" == $(which zsh) ]]; then
  msg "Changing $USER's shell to zsh"
  if is-macos; then
    chsh -s $(which zsh)
  else
    sudo chsh -s $(which zsh) $(whoami)
  fi
fi
