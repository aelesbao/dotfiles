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
  msg "gh-cli already authenticated"
else
  msg "gh-cli not authenticated"
  if [[ -z "${GITHUB_USER:-}" ]]; then
    fail "GITHUB_USER is not set"
  fi
  gh auth login -s admin:public_key,admin:ssh_signing_key
fi

msg "Configuring git credential helper"
gh auth setup-git

if [[ -f ~/.ssh/id_ed25519 ]]; then
  declare _pubkey="$(ssh-keygen -yf ~/.ssh/id_ed25519 | cut -d ' ' -f 1,2)"
  declare _comment="$(ssh-keygen -yf ~/.ssh/id_ed25519 | cut -d ' ' -f 3)"

  if ! gh ssh-key list | grep -q "${_pubkey}.*signing"; then
    msg "Adding SSH signing keys"
    gh ssh-key add ~/.ssh/id_ed25519.pub --title "${_comment}" --type signing
  fi
fi

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
