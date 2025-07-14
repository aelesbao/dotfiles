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

mkdir -m 0700 -p ~/.ssh/tmp
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


if is-linux; then
  info "Configuring SSH server"

  if [[ ! -d /etc/ssh/sshd_config.d ]]; then
    warn "SSH server configuration directory not found"
    return
  fi

  if ! sshd -G | grep -iq "^PasswordAuthentication no"; then
    msg "Disabling password authentication"
    echo "PasswordAuthentication no" | sudo tee -a /etc/ssh/sshd_config.d/30-password-authentication.conf > /dev/null
  fi

  if ! sshd -G | grep -iq "^PubkeyAuthentication yes"; then
    msg "Enabling public key authentication"
    echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config.d/30-pubkey-authentication.conf > /dev/null
  fi

  if ! sshd -G | grep -iq "AllowAgentForwarding yes"; then
    msg "Enabling agent forwarding"
    echo "AllowAgentForwarding yes" | sudo tee -a /etc/ssh/sshd_config.d/30-agent-forwarding.conf > /dev/null
  fi
fi
