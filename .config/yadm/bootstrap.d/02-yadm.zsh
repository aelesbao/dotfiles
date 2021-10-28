#!/usr/bin/env zsh
#
# yadm configuration
#

set -euo pipefail

info "Updating the yadm repo origin URL"
yadm remote set-url origin "git@github.com:$GITHUB_USER/dotfiles.git"

info "Init submodules"
yadm submodule update --recursive --init

info "Decrypting secret files"
yadm decrypt
