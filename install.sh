#!/bin/bash

set -euo pipefail

export GITHUB_USER="aelesbao"
export DOTFILES_REPO="https://github.com/$GITHUB_USER/dotfiles"
export YADM_VERSION="3.3.0"

title() {
  printf "\033[1;35m≡ %s\033[0m\n" "${@:$#}"
}

info() {
  echo
  printf "\033[1;37m∷ %s\033[0m\n" "${@:$#}"
}

fail() {
  printf "\033[0;31m⁘ %s\n" "${@:$#}" >&2
  exit 1
}

ask() {
  printf "\033[0;32m⁖ %s\033[0m " "${@:$#}"
  old_stty_cfg="$(stty -g)"
  stty raw -echo
  answer="$(head -c 1)"
  # shellcheck disable=SC2086
  stty $old_stty_cfg
  if echo "$answer" | grep -iq "^y"; then
    echo
    return 0
  else
    echo
    return 1
  fi
}

has_command() {
  command -v "$@" >/dev/null 2>&1
}

is_macos() {
  [[ "$OSTYPE" == darwin* ]]
}

get_distro() {
  has_command lsb_release && lsb_release -is
}

is_debian() {
  has_command apt
}

has_pkg() {
  pkg="${1}"

  if is_macos; then
    (brew list --formula "$pkg" || brew list --cask "$pkg") >/dev/null 2>&1
  elif has_command dpkg-query; then
    dpkg-query -W "$pkg" >/dev/null 2>&1
  elif has_command pacman; then
    pacman -Qi "$pkg" >/dev/null 2>&1
  else
    fail "Unsupported OS: $(get_distro)"
  fi
}

# shellcheck disable=SC2086
add_pkg() {
  pkg=${*}
  msg "Installing $pkg"

  if has_command brew; then
    brew install $pkg
  elif has_command apt; then
    sudo apt install -y $pkg
  elif has_command pamac; then
    pamac install --no-confirm $pkg
  elif has_command yay; then
    yay -S --noconfirm $pkg
  elif has_command pacman; then
    sudo pacman -S --noconfirm $pkg
  else
    fail "Unsupported OS: $(get_distro)"
  fi
}

require() {
  local pkg="${1:?}"
  if ! has_pkg "$pkg"; then
    add_pkg "$pkg" || fail "failed to install $pkg"
  fi
}

title "Installing $GITHUB_USER's .dotfiles"

if has_command hostinfo; then
  info "System info"
  hostinfo
fi

if has_command brew; then
  info "Updating Homebrew"
  brew update && brew upgrade
else
  if is_macos || (is_debian && ask "Would you like to use Homebrew for package management?"); then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

require yadm ||
  sudo -- sh -c "curl -fsSLo /usr/local/bin/yadm 'https://raw.githubusercontent.com/TheLocehiliosan/yadm/${YADM_VERSION}/yadm' && chmod a+x /usr/local/bin/yadm"

require curl
if is_macos; then
  # Make sure curl is installed via Homebrew and using the latest version (with OpenSSL)
  brew reinstall -f curl
fi

require git
require zsh

info "Initializing the yadm repository"

if [[ -d "$HOME/.local/share/yadm/repo.git" ]]; then
  if ask "The yadm repository already exists. Do you want to overwrite it?"; then
    yadm clone "$DOTFILES_REPO" -f
    yadm checkout .
  fi

  yadm bootstrap
else
  yadm clone "$DOTFILES_REPO" --bootstrap
fi
