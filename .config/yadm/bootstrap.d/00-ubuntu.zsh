#!/usr/bin/env zsh
#
# Ubuntu settings
#

set -euo pipefail

function download-gh-release() {
  set -euo pipefail

  local repo="${1}"
  local file="${2}"
  local version="${3:-$(get-latest-tag "${repo}")}"
  local pkg_path="$(mktemp -d)/${file}"

  curl -fsSLo "${pkg_path}" "https://github.com/${repo}/releases/download/${version}/${file}"
  echo "${pkg_path}"
}

function install-gh-pkg-release() {
  set -euo pipefail

  local repo="${1}"
  local pkg_name="${2:-${repo#*/}}"
  local version="${3:-$(get-latest-tag "${repo}")}"
  local pkg_path="$(download-gh-release "${repo}" "${pkg_name}_${version}_amd64.deb" "${version}")"

  msg "Installing ${repo}"
  sudo dpkg -i "${pkg_path}"
}

if ! is-ubuntu; then
  msg "Not in a Ubuntu"
  return
fi


info "Update and upgrade packages"
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y

info "Installing apt packages"
sudo apt install -y \
  build-essential \
  ca-certificates \
  curl \
  file \
  finger \
  gnupg \
  jq \
  language-pack-en-base \
  libssl-dev \
  lsb-release \
  powerline \
  procps \
  rsync \
  wget \
  zip

info "Installing packages from GitHub Releases"
install-gh-pkg-release "Peltoche/lsd"

if ! (( $+commands[docker] )); then
  info "Installing Docker"
  curl -fsSLo- https://get.docker.com | bash
fi

info "Installing fonts"
mkdir -p ~/.local/share/fonts
unzip -u "$(download-gh-release ryanoasis/nerd-fonts Hack.zip)" -d ~/.local/share/fonts

info "Cleaning up"
sudo apt autoremove -y
sudo apt autoclean

info "Generating locales"
sudo locale-gen en_US.UTF-8 de_DE.UTF-8
