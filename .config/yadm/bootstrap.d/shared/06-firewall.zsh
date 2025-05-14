#!/usr/bin/env zsh

set -euo pipefail

info "Configuring firewall"

function add-service() {
  local service="$1"
  local short="$2"
  local description="$3"
  local -au ports=(${argv:4})

  if ! firewall-cmd --permanent --get-services | grep -q "${service}"; then
    msg "Adding ${service} service"
    sudo firewall-cmd --permanent --new-service="${service}"
    sudo firewall-cmd --permanent --service="${service}" --set-short="${short}"
    sudo firewall-cmd --permanent --service="${service}" --set-description="${description}"
    
    for port in "${ports[@]}"; do
      sudo firewall-cmd --permanent --service="${service}" --add-port="${port}"
    done
  fi
}

if (( $+commands[firewall-cmd] )); then
  add-service "ollama" \
    "Ollama" \
    "Large language models service" \
    11434/tcp

  add-service "deskflow" \
    "Deskflow" \
    "Share keyboard and mouse between multiple computers" \
    24800/tcp \
    24801/tcp \
    24800/udp \
    24801/udp

  msg "Enabling services on home zone"
  sudo firewall-cmd --permanent --zone="home" \
    --add-service="deskflow" \
    --add-service="dhcpv6-client" \
    --add-service="docker-swarm" \
    --add-service="dropbox-lansync" \
    --add-service="http" \
    --add-service="http3" \
    --add-service="https" \
    --add-service="kdeconnect" \
    --add-service="mdns" \
    --add-service="ollama" \
    --add-service="openvpn" \
    --add-service="samba-client" \
    --add-service="spotify-sync" \
    --add-service="ssh" \
    --add-service="steam-lan-transfer" \
    --add-service="steam-streaming"

  msg "Reloading firewall"
  sudo firewall-cmd --reload
fi
