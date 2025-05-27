#!/usr/bin/env zsh
#
# Arch setup
#

set -euo pipefail

if ! has-command pacman; then
  msg "Could not find pacman. Skipping Arch setup."
  return
fi


info "Adding Chaotic AUR repository"

msg "Import primary key"
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

msg "Install chaotic-mirrorlist and chaotic-keyring"
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

msg "Add repository to /etc/pacman.conf"
if ! grep -q "^[chaotic-aur]$" /etc/pacman.conf; then
  echo -e "\n\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null
fi


if ! [[ -f /etc/pacman.d/mirrorlist.bak ]]; then
  info "Optmize mirror list"

  sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

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


info "Sync packages"
sudo pacman -Syyu

info "Install base packages"
add-pkg \
  base-devel \
  curl \
  git \
  jq \
  go-yq \
  python \
  python-jmespath
