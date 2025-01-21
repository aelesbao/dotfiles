#!/usr/bin/env zsh
#
# SSH keys configuration
#

set -euo pipefail

if [[ -z "${GITHUB_USER:-}" ]]; then
  fail "GITHUB_USER is not set"
fi


function keygen() {
  local key_type="${1}"
  local key_file="${HOME}/.ssh/id_${key_type}"

  if [[ -f "$key_file" ]]; then
    msg "SSH key $key_type already exists"
  else
    declare key_name="${GITHUB_USER}@$(hostname)"
    ssh-keygen -t "$key_type" -C "$key_name" -f "$key_file" -q -N ""
    msg "SSH key $key_type created"
  fi

  declare public_key="$(ssh-keygen -y -f "$key_file" | cut -d ' ' -f 1,2)"

  if ! grep -q "^${public_key}" ~/.ssh/authorized_keys; then
    cat "${key_file}.pub" >> ~/.ssh/authorized_keys
    msg "Authorized $key_type public key"
  fi
}


info "Creating SSH keys"

touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

keygen ed25519


info "Adding ${GITHUB_USER} GitHub public keys to ~/.ssh/authorized_keys"

IFS=$'\n' # make newlines the only separator
for key in $(curl -fsSL "https://github.com/${GITHUB_USER}.keys"); do
  msg "$key"
  if ! grep -q "^$key" ~/.ssh/authorized_keys; then
    echo "$key ${GITHUB_USER}@users.noreply.github.com" >> ~/.ssh/authorized_keys
    notice "added to authorized keys"
  fi
done

# reset IFS
unset IFS
