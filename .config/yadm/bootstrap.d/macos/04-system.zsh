#!/usr/bin/env zsh
#
# Update system-wide settings
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi


require gum
declare name="$(gum input --header "Hostname" --header.foreground 253 --placeholder "Enter hostname for this machine")"

info "Set computer name to ${name}"
sudo scutil --set ComputerName "${name}"
sudo scutil --set HostName "${name}"
sudo scutil --set LocalHostName "${name}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${name}"

info "Enable Remote Login (ssh)"
sudo systemsetup -setremotelogin on
