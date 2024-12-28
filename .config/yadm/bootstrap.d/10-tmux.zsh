#!/usr/bin/env zsh
#
# Configures tmux
#

set -euo pipefail

if ! has-command tmux; then
  msg "tmux is not installed"
  return
fi


info "Configuring tmux"

msg "Downloading terminfo"
curl -sfLO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz

msg "Compiling terminfo database"
/usr/bin/tic -xe tmux-256color terminfo.src && rm terminfo.src
