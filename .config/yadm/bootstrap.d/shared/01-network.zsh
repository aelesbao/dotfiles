#!/usr/bin/env zsh
#
# Network setup
#

set -euo pipefail

if is-linux && ask "Configure IPv6 Privacy Extensions?"; then
  info "Writing sysctl configuration for IPv6 Privacy Extensions"

  sudo tee /etc/sysctl.d/40-ipv6.conf > /dev/null <<EOF
# Enable IPv6 Privacy Extensions
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
EOF

  for iface in $(ip -details -json link show | jq -r '.[] | select((.linkinfo.info_kind // .link_type == "loopback") | not) | .ifname'); do
    echo "net.ipv6.conf.${iface}.use_tempaddr = 2" | sudo tee -a /etc/sysctl.d/40-ipv6.conf > /dev/null
  done

  info "Applying sysctl settings"
  sudo sysctl --system
fi

