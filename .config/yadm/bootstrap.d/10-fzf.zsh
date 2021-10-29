#!/usr/bin/env zsh
#
# fzf
#

set -euo pipefail

if ! [[ -x /usr/local/opt/fzf/install ]]; then
  msg "fzf not installed"
  return 0
fi

info "Configuring fzf"
/usr/local/opt/fzf/install --all --no-bash --no-fish
