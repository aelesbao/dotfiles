#!/usr/bin/env zsh
#
# Vim setup
#

set -euo pipefail

if ! (( $+commands[vim] )); then
  msg "vim not installed"
  return 0
fi

info "Configuring Vim"

if ! [[ -f "${HOME}/.vimrc" ]]; then
  msg "~/.vimrc not found"
  return 1
fi

if [[ -d "${HOME}/.vim/bundle" ]]; then
  if ! ask "It seems like vim is already configured. Do you want to proceed anyway?"; then
    return 0
  fi
fi

mkdir -p ~/.vim

[ $# -eq 0 ] && set -- -
vim +'BundleInstall' +'BundleClean!' +'BundleUpdate' +'qall' -R

ln -s ~/.vim/bundle/Colour-Sampler-Pack ~/.vim/colors

pushd ~/.vim/bundle/coc.nvim
yarn install --frozen-lockfile
popd
