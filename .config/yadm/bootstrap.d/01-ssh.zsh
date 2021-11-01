#!/usr/bin/env zsh
#
# SSH keys configuration
#

set -euo pipefail

info "Configuring SSH"

if [[ -f "${HOME}/.ssh/id_rsa" ]]; then
  msg "An SSH key already exists"
else
  declare key_name="${GITHUB_USER}@$(hostname)"
  ssh-keygen -t rsa -b 4096 -C "$key_name" -f "${HOME}/.ssh/id_rsa" -q -N ""
  msg "SSH key $key_name created"
fi

declare public_key="$(ssh-keygen -y -f "${HOME}/.ssh/id_rsa" | cut -d ' ' -f 1,2)"
declare github_keys="$(curl -fsSL "https://api.github.com/users/${GITHUB_USER}/keys")"
if [[ "$github_keys" == *"$public_key"* ]]; then
  msg "The SSH key already exists in GitHub"
else
  if ask "Do you want to add the public key to your GitHub account?"; then
    pbcopy < "${HOME}/.ssh/id_rsa.pub"
    msg "The public key content was copied to the clipbord"
    notice "Now you should paste that into GitHub..."
    open "https://github.com/settings/ssh/new"
  fi

  if ! ask "Did you add the public key to your account?"; then
    warn "If you find issues executing the scripts bellow, try adding the key before running the script again"
  fi
fi
