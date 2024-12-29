#!/usr/bin/env zsh
#
# Enable fingerprint authentication for sudo
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi

require pam-reattach

info "Enable Touch ID for sudo"
pam_reattach="$(brew --prefix pam-reattach)/lib/pam/pam_reattach.so"
sed "s/^#auth/auth       optional       ${pam_reattach:gs/\//\\\/} ignore_ssh\nauth/" /etc/pam.d/sudo_local.template | \
  sudo tee /etc/pam.d/sudo_local
