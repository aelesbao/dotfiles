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
