#!/usr/bin/env zsh
#
# Debian setup
#

set -euo pipefail

if ! has-command apt; then
  msg "Could not find apt. Skipping Debian setup."
  return
fi


info "Update and upgrade packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y

info "Installing required packages"
add-pkg \
  build-essential \
  ca-certificates \
  curl \
  flatpak \
  gnome-software-plugin-flatpak \
  git \
  libssl-dev

info "Cleaning up"
sudo apt autoremove -y
sudo apt autoclean

info "Adding flatpak remote"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

info "Generating locales"
sudo locale-gen en_US.UTF-8 pt_BR.UTF-8 de_DE.UTF-8

if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

brew install \
  gcc \
  git
