#!/usr/bin/env zsh
#
# general system setup
#

set -euo pipefail


if is-linux; then
  info "Increasing inotify max watches"

  sudo tee /etc/sysctl.d/30-inotify.conf > /dev/null <<EOF
# Increase inotify max watches
fs.inotify.max_user_watches = 2097152
EOF

  msg "Applying sysctl settings"
  sudo sysctl -p --system
fi
