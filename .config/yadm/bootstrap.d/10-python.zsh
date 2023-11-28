#!/usr/bin/env zsh
#
# Python setup
#

set -euo pipefail

if ! (( $+commands[pyenv] )); then
  info "Installing pyenv"
  if is-macos; then
    brew install pyenv
  else
    curl https://pyenv.run | bash
  fi
fi

python_version="$(pyenv install -l | egrep '^  ([0-9]+\.[0-9]+\.[0-9]+)$' | tail -1 | sed 's/ //g')"
info "Configuring Python $python_version"

if ! pyenv versions | grep -s "$python_version" >/dev/null; then
  info "Installing Python $python_version"
  pyenv install "$python_version"
fi

msg "Using $python_version"
pyenv shell "$python_version"

python3 -m pip install --upgrade pip virtualenv

if ! (( $+commands[pipx] )); then
  info "Installing pipx"
  if is-macos; then
    brew install pipx
    pipx ensurepath
  else
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
  fi
fi

info "Installing pipx packages"
pipx install poetry
#pipx install --include-deps ansible
#pipx inject --include-apps ansible ansible-lint
#pipx inject --include-apps ansible argcomplete
#pipx inject ansible paramiko
