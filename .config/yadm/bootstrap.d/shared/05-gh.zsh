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
if gh auth status | grep -q "Logged in to github.com account ${GITHUB_USER}"; then
  msg "gh-cli not authenticated"
  if [[ -z "${GITHUB_USER:-}" ]]; then
    fail "GITHUB_USER is not set"
  fi
  gh auth login
else
  msg "gh-cli already authenticated"
fi

msg "Configuring git credential helper"
gh auth setup-git

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
