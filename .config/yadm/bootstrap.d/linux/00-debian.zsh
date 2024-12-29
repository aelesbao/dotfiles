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
  git \
  libssl-dev

info "Cleaning up"
sudo apt autoremove -y
sudo apt autoclean

info "Generating locales"
sudo locale-gen en_US.UTF-8 pt_BR.UTF-8 de_DE.UTF-8

if ! has-command brew && ask "Would you like to use Homebrew for package management?"; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
