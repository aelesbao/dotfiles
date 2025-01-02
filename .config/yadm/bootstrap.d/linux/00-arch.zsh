#!/usr/bin/env zsh
#
# Arch setup
#

set -euo pipefail

if ! has-command pacman; then
  msg "Could not find pacman. Skipping Arch setup."
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
  curl \
  git \
  python \
  python-jmespath
