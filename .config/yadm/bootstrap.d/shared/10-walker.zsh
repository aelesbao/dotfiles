#!/usr/bin/env zsh
#
# Configures [walker](https://walkerlauncher.com/)
#

set -euo pipefail

if ! has-command elephant; then
  msg "elephant is not installed"
  return
fi

if ! has-command walker; then
  msg "walker is not installed"
  return
fi


info "Configuring elephant"

if ! systemctl --user is-active elephant.service --quiet; then
  elephant service enable
  systemctl --user enable --now elephant.service
  msg "Elephant service started"
fi


info "Configuring walker"

if ! systemctl --user is-enabled app-walker@autostart.service --quiet; then
  cp "${XDG_CONFIG_HOME:-$HOME/.config}/walker/walker.desktop" "${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
  systemctl --user daemon-reload
  msg "Walker autostart service installed"
fi

systemctl --user start app-walker@autostart.service
msg "walker service started"
