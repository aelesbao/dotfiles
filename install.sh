#!/bin/sh

set -euo pipefail


export GITHUB_USER="aelesbao"
export DOTFILES_REPO="https://github.com/$GITHUB_USER/dotfiles"


title() {
  echo "\033[1;35m≡ ${@:$#}\033[0m"
}

info() {
  echo
  echo "\033[1;37m∷ ${@:$#}\033[0m"
}

fail() {
  echo "\033[0;31m⁘ ${@:$#}" >&2
  exit 1
}

ask() {
  printf "\033[0;32m⁖ ${@:$#}\033[0m "
  local old_stty_cfg="$(stty -g)"
  stty raw -echo
  local answer="$(head -c 1)"
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

pkg_install() {
  local pkg="${1:?}"
  info "Installing $pkg"

  if is_macos; then
    brew install $pkg
  elif has_command apt; then
    sudo apt install -y $pkg
  elif has_command pacman; then
    sudo pacman -S --noconfirm $pkg
  else
    fail "Unsupported OS: $(uname -a)"
  fi
}

require() {
  local pkg="${1:?}"
  if ! has_command "$pkg"; then
    pkg_install $pkg
  fi
}


title "Installing $GITHUB_USER's .dotfiles"

if has_command hostinfo; then
  info "System info"
  hostinfo
fi

if is_macos; then
  if ! has_command brew; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    info "Updating Homebrew"
    brew update && brew upgrade && brew cleanup
  fi

  # Make sure curl is installed via Homebrew and using the latest version (with OpenSSL)
  brew reinstall -f curl
fi

require zsh
require git
require yadm

info "Initializing the repository with yadm"

if [[ -d "$HOME/.local/share/yadm/repo.git" ]]; then
  ask "The yadm repository already exists. Do you want to overwrite it?" || fail "Aborting"

  yadm clone "$DOTFILES_REPO" --bootstrap -f
  yadm checkout .
else
  yadm clone "$DOTFILES_REPO" --bootstrap
fi
