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


is_macos() {
  [[ "$OSTYPE" == darwin* ]]
}

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

pkg_install() {
  local pkg="${1:?}"
  info "Installing $pkg"

  if is_macos; then
    brew install $pkg
  else
    fail "Unsupported OS: $(uname -a)"
  fi
}

require() {
  local pkg="${1:?}"
  if ! command_exists "$pkg"; then
    pkg_install $pkg
  fi
}


title "Installing $GITHUB_USER's .dotfiles"

if command_exists hostinfo; then
  info "System info"
  hostinfo
fi

if is_macos; then
  if ! command_exists brew; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    info "Updating Homebrew"
    brew update && brew upgrade && brew cleanup
  fi
fi

require zsh
require git
require yadm

info "Initializing the repository with yadm"

if [[ -d "$HOME/.local/share/yadm/repo.git" ]]; then
  if ask "The yadm repository already exists. Do you want to overwrite it?"; then
    yadm clone "$DOTFILES_REPO" --bootstrap -f
    yadm checkout .
  else
    fail "Aborting"
  fi
else
  yadm clone "$DOTFILES_REPO" --bootstrap
fi
