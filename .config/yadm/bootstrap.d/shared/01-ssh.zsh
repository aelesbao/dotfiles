#!/usr/bin/env zsh
#
# SSH keys configuration
#

set -euo pipefail

function keygen() {
  local key_type="${1}"
  local key_file="${HOME}/.ssh/id_${key_type}"

  if [[ -f "$key_file" ]]; then
    msg "SSH key already exists"
  else
    declare key_name="${GITHUB_USER}@$(hostname)"
    ssh-keygen -t "$key_type" -C "$key_name" -f "$key_file" -q -N ""
    msg "SSH key $key_type created"
  fi
}

info "Configuring SSH"

keygen rsa
keygen ed25519

declare gh_key="${HOME}/.ssh/id_ed25519"

declare public_key="$(ssh-keygen -y -f "$gh_key" | cut -d ' ' -f 1,2)"
declare github_keys="$(curl -fsSL "https://api.github.com/users/${GITHUB_USER}/keys")"
if [[ "$github_keys" == *"$public_key"* ]]; then
  msg "The SSH key already added to GitHub"
else
  if ask "Do you want to add the public key to your GitHub account?"; then
    notice "Copy and paste the key content into GitHub:"
    echo "$gh_key"
    open "https://github.com/settings/ssh/new"
  fi

  if ! ask "Did you add the public key to your account?"; then
    warn "If you find issues executing the scripts bellow, try adding the key before running the script again"
  fi
fi