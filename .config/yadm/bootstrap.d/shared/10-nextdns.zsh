#!/usr/bin/env zsh
#
# NextDNS setup
#

set -euo pipefail

declare profile_id="${NEXTDNS_PROFILE_ID:-}"
if [[ -z "${profile_id}" ]]; then
  profile_id="$(gum input --header "NextDNS Profile ID" --header.foreground 253 --placeholder "Enter your NextDNS profile ID")"
fi
if [[ -z "${profile_id}" ]]; then
  error "NextDNS profile ID not found"
  return 1
fi

info "Configuring NextDNS with profile ID: ${profile_id}"

declare device="$(hostname -f)"

if (($+commands[nextdns])); then
  msg "Installing using nextdns CLI"

  sudo nextdns install \
    -config "${profile_id}" \
    -report-client-info \
    -auto-activate

  sudo nextdns config set \
    -forwarder local=192.168.0.1 \
    -forwarder fritz.box=192.168.0.1

elif is-linux; then
  msg "Installing using systemd-resolved"

  local sni="${device}-${profile_id}.dns.nextdns.io"
  cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/nextdns.conf
[Resolve]
DNS=45.90.28.0#${sni} 45.90.30.0#${sni} 2a07:a8c0::#${sni} 2a07:a8c1::#${sni}
DNSOverTLS=yes
EOF

  if systemctl is-active --quiet systemd-resolved.service; then
    sudo systemctl restart systemd-resolved.service
  else
    sudo systemctl enable --now systemd-resolved.service
  fi

elif is-macos; then
  msg "Installing using macOS profile"

  curl --output-dir ${TMPDIR:-/tmp} \
    "https://apple.nextdns.io/NextDNS.mobileconfig?profile=${profile_id}&device_name=${device}&device_model=Apple+%7Emacbook-pro&exclude_domains=*.local%2C+*.fritz.box%2C+fritz.box&trust_ca=1&sign=3"
  open ${TMPDIR:-/tmp}/NextDNS.mobileconfig
fi
