#!/usr/bin/env bash
# VPN status script for Waybar custom module
# Outputs JSON compatible with Waybar's return-type: json

set -euo pipefail

# Get active VPN connections (wireguard, vpn, or tun interfaces)
vpn_output=$(nmcli con show --active 2>/dev/null | grep -iE '(wireguard|vpn)' || true)

if [[ -n "$vpn_output" ]]; then
  # Extract connection name (first column)
  vpn_name=$(echo "$vpn_output" | awk '{print $1}' | head -n1)
  vpn_device=$(echo "$vpn_output" | awk '{print $4}' | head -n1)

  text="VPN"
  alt="$vpn_device"
  tooltip="Connected: ${vpn_name}"

  if [[ "$vpn_name" == "nordlynx" ]]; then
    tooltip="$(nordvpn status)"
  fi

  class="connected"
  percentage=100
else
  text="VPN"
  alt="disconnected"
  tooltip="Disconnected"
  class="disconnected"
  percentage=0
fi

# Output JSON using jq for proper escaping and compact output
jq -nc \
  --arg text "$text" \
  --arg alt "$alt" \
  --arg tooltip "$tooltip" \
  --arg class "$class" \
  --argjson percentage "$percentage" \
  '{"text": $text, "alt": $alt, "tooltip": $tooltip, "class": $class, "percentage": $percentage}'
