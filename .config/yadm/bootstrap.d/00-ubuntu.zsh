#!/usr/bin/env zsh
#
# Ubuntu settings
#

set -euo pipefail

if ! is-ubuntu; then
  msg "Not in a Ubuntu"
  return
fi


info "Update and upgrade packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y

info "Installing new packages"
sudo apt install -y \
  build-essential \
  curl \
  file \
  finger \
  jq \
  language-pack-en-base \
  libssl-dev \
  powerline \
  procps \
  rsync \
  wget \
  zip

info "Installing manual packages"

msg "lsd"
version="$(get-latest-tag Peltoche/lsd)"
pkg_path="$(mktemp -d)/lsd_${version}_amd64.deb"
wget -O "${pkg_path}" "https://github.com/Peltoche/lsd/releases/download/${version}/lsd_${version}_amd64.deb"
sudo dpkg -i "${pkg_path}"
