#!/usr/bin/env zsh

set -euo pipefail


if (( ! $+commands[gnome-shell] )); then
  echo "gnome-shell not available"
  exit 1
fi


declare settings_file="${0:A:h}/gnome-settings.dconf"
if [[ ! -f "${settings_file}" ]]; then
  echo "Settings file not found: ${settings_file}"
  exit 1
fi

dconf load / < "${settings_file}"

