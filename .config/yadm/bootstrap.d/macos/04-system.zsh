#!/usr/bin/env zsh
#
# Update system-wide settings
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi


declare name="sirius"

info "Set computer name to ${name}"
sudo scutil --set ComputerName "${name}"
sudo scutil --set HostName "${name}"
sudo scutil --set LocalHostName "${name}"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${name}"

info "Enable Remote Login (ssh)"
sudo systemsetup -setremotelogin on
