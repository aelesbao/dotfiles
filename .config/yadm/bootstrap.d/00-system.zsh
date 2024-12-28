#!/usr/bin/env zsh
set -euo pipefail

if is-macos; then
  run-boot ./macos
fi

if is-linux; then
  run-boot ./linux

  if ! (grep -q "^$USER:.*:$(command -v zsh)\$" /etc/passwd); then
    sudo chsh -s "$(command -v zsh)" "$USER"
  fi
fi
