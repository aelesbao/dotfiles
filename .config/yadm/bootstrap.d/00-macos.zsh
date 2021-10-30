#!/usr/bin/env zsh
#
# MacOS settings
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a MacOS"
  return 0
fi


info "Configuring Dock & Dashboard"

msg "Auto-hide the dock"
defaults write com.apple.dock autohide -bool true

msg "Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

msg "Minimize dock to application icon and set effect type"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock mineffect -string "genie"

msg "Show full trash icon"
defaults write com.apple.dock trash-full -bool true

msg "Don't show recent apps"
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

msg "Configure dock size and magnification"
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock titlesize -int 35
defaults write com.apple.dock largesize -int 75

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen
msg "Bottom right screen corner → Desktop"
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0


if xcode-select --print-path &> /dev/null; then
  notice "XCode Command Line Tools already configured"
else
  title "Installing XCode Command Line Tools"

  # Prompt user to install the XCode Command Line Tools
  xcode-select --install &> /dev/null

  # Wait until the XCode Command Line Tools are installed
  until xcode-select --print-path &> /dev/null; do
    sleep 3
  done

  if [[ $? -eq 0 ]]; then
    notice "Agree to the XCode Command Line Tools license"
    sudo xcodebuild -license
  fi
fi
