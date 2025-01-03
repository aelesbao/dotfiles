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
  info "Optmize mirror list"

  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

  if has-command pacman-mirrors; then
    sudo pacman-mirrors \
      -c Germany,Netherlands,Austria,Switzerland
  elif has-command reflector; then
    sudo reflector \
      --country Germany \
      --country Netherlands \
      --country Austria \
      --country Switzerland \
      --age 24 \
      --latest 10 \
      --protocol https \
      --sort rate \
      --save /etc/pacman.d/mirrorlist
  fi
fi


info "Update and upgrade packages"
sudo pacman -Syyu --noconfirm

add-pkg \
  base-devel \
  curl \
  git \
  python \
  python-jmespath
