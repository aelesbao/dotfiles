#!/usr/bin/env zsh
#
# Debian setup
#

set -euo pipefail

if ! has-command apt-get; then
  msg "Not in a Debian based system"
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
  git \
  language-pack-en-base \
  libssl-dev \
  rsync \
  uidmap \
  wget \
  zip

info "Cleaning up"
sudo apt autoremove -y
sudo apt autoclean

info "Generating locales"
sudo locale-gen en_US.UTF-8 pt_BR.UTF-8 de_DE.UTF-8

# TODO: Install flatpak and remaining dependencies

if ! has-command brew && ask "Would you like to use Homebrew for package management?"; then
  info "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
