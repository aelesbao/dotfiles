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

if is-linux; then
  cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/nextdns.conf
[Resolve]
DNS=45.90.28.0#${profile_id}.dns.nextdns.io
DNS=2a07:a8c0::#${profile_id}.dns.nextdns.io
DNS=45.90.30.0#${profile_id}.dns.nextdns.io
DNS=2a07:a8c1::#${profile_id}.dns.nextdns.io
DNSOverTLS=yes
EOF
fi

if is-macos; then
  declare device="$(scutil --get ComputerName)"
  curl --output-dir ${TMPDIR:-/tmp} \
    "https://apple.nextdns.io/NextDNS.mobileconfig?profile=${profile_id}&device_name=${device}&device_model=Apple+%7Emacbook-pro&exclude_domains=*.local%2C+*.fritz.box%2C+fritz.box&trust_ca=1&sign=3"
  open ${TMPDIR:-/tmp}/NextDNS.mobileconfig
fi
