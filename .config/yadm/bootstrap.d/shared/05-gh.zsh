#!/usr/bin/env zsh
#
# GitHub settings
#

set -euo pipefail

if ! has-command gh; then
  msg "gh not installed"
  return 1
fi

info "Configuring gh-cli"
gh auth login

extensions=(
  github/gh-copilot
  nektos/gh-act
  dlvhdr/gh-dash
  meiji163/gh-notify
)
for ext in $extensions; do
  if gh ext list | grep $ext > /dev/null; then
    gh ext upgrade $ext
  else
    gh ext install $ext
  fi
done
