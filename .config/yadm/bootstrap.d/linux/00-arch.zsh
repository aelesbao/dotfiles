#!/usr/bin/env zsh
#
# Arch setup
#

set -euo pipefail

if ! has-command pacman; then
  msg "Not in a Arch Linux based system"
  return
fi


if ! [[ -f /etc/pacman.d/mirrorlist.backup ]]; then
  info "Optmize mirror list..."

  require reflector

  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  sudo reflector \
    --country Germany \
    --country Netherlands \
    --age 24 \
    --latest 10 \
    --protocol https \
    --sort rate \
    --save /etc/pacman.d/mirrorlist
fi


info "Update and upgrade packages"
sudo pacman -Syyu --noconfirm

add-pkg \
  base-devel \
  git \
  rsync
  tree \
  wget \
  zsh \
  zsh-completions \
  zsh-syntax-highlighting

if ! (pacman -Qi zsh >/dev/null); then
  sudo chsh -s "$(command -v zsh)" "$(whoami)"
fi

