#!/usr/bin/env zsh
#
# GNUPG setup
#

set -euo pipefail

if ! has-command gpg; then
  msg "gpg not found"
  return 1
fi

if ! has-command op; then
  msg "1password-cli not found"
  return 1
fi


declare _gpg_home="$(gpgconf --list-dirs homedir)"
declare _gpg_agent_conf="${_gpg_home}/gpg-agent.conf"
declare _reload_agent=false

info "Configuring GPG"
[[ ! -d ${_gpg_home} ]] && mkdir -m 0700 ${_gpg_home}

if ! grep -q "^enable-ssh-support" ${_gpg_agent_conf} 2>/dev/null; then
  msg "Enable SSH support"
  echo "enable-ssh-support" >> ${_gpg_agent_conf}
  _reload_agent=true
fi

if ! grep -q "^pinentry-program" ${_gpg_agent_conf} 2>/dev/null; then
  local program
  if has-command pinentry-bemenu; then
    program="pinentry-bemenu"
  elif has-command pinentry-curses; then
    program="pinentry-curses"
  elif has-command pinentry-mac; then
    program="pinentry-mac"
  fi

  if [[ -n "${program:-}" ]]; then
    msg "Set pinentry-program to ${program}"
    echo "pinentry-program $(which ${program})" >> ${_gpg_agent_conf} 
    _reload_agent=true
  fi
fi

if ${_reload_agent}; then
  msg "Reload gpg agent"
  gpg-connect-agent reloadagent /bye
fi


# TODO: move to smartcard
info "Fetching key data from 1Password"

declare op_item="op://Development/GPG"
declare op_key_password="${op_item}/password"
declare op_secret_key="${op_item}/aelesbao.secret.key"

declare user_id="$(op read --no-newline "${op_item}/username")"
declare fpr="$(op read --no-newline "${op_item}/info/fingerprint")"


info "Set up key ${user_id} (${fpr})"

if ! gpg --list-options show-only-fpr-mbox -k "${user_id}" 2>/dev/null | grep -q "${fpr}"; then
  msg "Importing public key"
  gpg --receive-keys ${fpr}
fi

# Check if the master secret key is present and usable
# fields desc: https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg.git;a=blob_plain;f=doc/DETAILS
if ! gpg --with-colons -K ${fpr} 2>/dev/null | \
  awk -F: '$1 == "sec" && $15 == "+"' | \
  grep -q .; then
  if ask "Would you like to import the secret key?"; then
    msg "Import master secret key"
    gpg --batch --passphrase-file <(op read "${op_key_password}") \
      --import --allow-secret-key-import \
      <(op read "${op_secret_key}")
  fi
fi

# Check if there are valid subkeys present
if ! gpg --with-colons -K ${fpr} 2>/dev/null | \
  awk -F: '$1 == "ssb" && $2 != "r" && $12 == "s" && $15 == "+"' | \
  grep -q .; then
  if ask "Would you like to add sub-keys?"; then
    info "Adding sub-keys for ${fpr}"

    msg "Signing key"
    gpg --batch \
      --pinentry-mode loopback \
      --passphrase-file <(op read "${op_key_password}") \
      --quick-add-key ${fpr} ed25519 sign 3m

    msg "Encryption key"
    gpg --batch \
      --pinentry-mode loopback \
      --passphrase-file <(op read "${op_key_password}") \
      --quick-add-key ${fpr} cv25519 encrypt 3m

    if ask "Send keys to keyserver?"; then
      gpg --send-keys ${fpr}
    fi
  fi
fi


# Clean up invalid subkeys
declare -a invalid_subkeys=($(
  gpg --with-colons -K ${fpr} 2>/dev/null | \
    awk -F: '$1 == "ssb" && $2 != "r" && $15 == "#" { print $5 }'
))
if [[ ${#invalid_subkeys} -ne 0 ]]; then
  info "Clean up subkeys without secrets from local keyring"
  for subkey in ${invalid_subkeys}; do
    msg "Deleting subkey ${subkey}"
    echo "y" | gpg --quiet --batch --expert --command-fd 0 \
      --edit-key ${fpr} "key ${subkey}" delkey save 2>&1 >/dev/null
  done
fi


# Remove master key secret and use sub-keys only
if gpg --with-colons -K ${fpr} 2>/dev/null | \
  awk -F: '$1 == "sec" && $12 == "scESC" && $15 == "+"' | \
  grep -q .; then
  if ask "Would you like to remove the master key secret?"; then
    info "Removing master key secret"
    declare secsub_file="${_gpg_home}/aelesbao.secsub.gpg"

    msg "Export secret sub-keys"
    gpg --batch \
      --pinentry-mode loopback \
      --passphrase-file <(op read "${op_key_password}") \
      --export-secret-subkeys \
      --output "${secsub_file}" \
      ${fpr}

    msg "Delete secret keys"
    gpg --batch --yes --delete-secret-keys ${fpr}

    msg "Import secret sub-keys"
    gpg --batch --import "${secsub_file}"

    msg "Clean up secrets from disk"
    shred --remove "${secsub_file}"
  fi
fi


if ! gpg --export-ownertrust | grep -q "${fpr}:6:"; then
  info "Set trust level to ultimate"
  gpg --batch --yes --quick-set-ownertrust ${fpr} ultimate

  msg "Reload gpg components"
  gpgconf -R all
fi


declare key_id="$(gpg --keyid-format short -k ${fpr} | awk -F' |/' '$1 == "pub" { print $5 }')"
if [[ "$(git config get user.signingkey)" != "${key_id}" ]] || [[ "$(git config get gpg.format)" != "openpgp" ]]; then
  info "Configuring git"
  git config set -f ~/.gitconfig.local user.signingkey ${key_id}
  git config set -f ~/.gitconfig.local gpg.format openpgp
  git config set -f ~/.gitconfig.local commit.gpgsign true
  git config set -f ~/.gitconfig.local tag.gpgSign true
fi


info "Key information"
gpg --keyid-format long --with-fingerprint -K "${fpr}"
