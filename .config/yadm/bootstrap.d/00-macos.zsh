#!/usr/bin/env zsh
#
# MacOS settings
#

set -euo pipefail

if ! is-macos; then
  msg "Not in a macOS"
  return
fi


info "Configuring global properties"


function confirm-defaults() {
  local global="${1}"
  local key="${2}"
  local value="${3}" # read remaining args
  # change args order if flag is not set
  # if NON_INTERACTIVE=false
  # read current config and ask if should change
}

msg "Set dark theme"
defaults write -g AppleInterfaceStyle -string "Dark"

msg "Set system language and text format"
defaults write -g AppleLanguages -array "en-US" "pt-BR" "de-DE"
defaults write -g AppleLocale -string "en_DE"
defaults write -g AppleMeasurementUnits -string "Centimeters"
defaults write -g AppleMetricUnits -bool true

msg "Maximize windows on double-click"
defaults write -g AppleMiniaturizeOnDoubleClick -bool false

msg "Show scrollbars when scrolling"
# Possible values: `WhenScrolling`, `Automatic` and `Always`
defaults write -g AppleShowScrollBars -string "WhenScrolling"

# msg "Stop apps from restoring old documents on relaunch"
# defaults write -g ApplePersistence -bool false


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
defaults write com.apple.dock titlesize -int 48
defaults write com.apple.dock titlesize -int 35
defaults write com.apple.dock largesize -int 75

# Hot corners possible values:
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


info "Configuring keyboard and typing"

# https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
msg "Re-mapping keys"
# Remap Caps Lock to ESC on system boot
launchctl load ~/Library/LaunchAgents/io.github.aelesbao.CapslockEscape.plist
# Remap paragraph symbol to `
launchctl load ~/Library/LaunchAgents/io.github.aelesbao.ParagraphToTilde.plist

msg "Disable press-and-hold for keys in favor of key repeat"
defaults write -g ApplePressAndHoldEnabled -bool false

msg "Speed-up key repeat delay"
defaults write -g InitialKeyRepeat -int 25
defaults write -g KeyRepeat -int 2

msg "Disable annoying automatic text substitutions"
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false

msg "Disable auto-correct"
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

msg "Enable full keyboard access for all controls" # (e.g. enable Tab in modal dialogs)
defaults write -g AppleKeyboardUIMode -int 3


info "Configuring Finder"

msg "Show all filename extensions"
defaults write -g AppleShowAllExtensions -bool true

msg "Don't warn when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

msg "Show hidden files"
defaults write com.apple.finder AppleShowAllFiles -bool true

msg "Search current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

msg "Configure iCloud folder sync"
defaults write com.apple.finder FXICloudDriveEnabled -bool true
defaults write com.apple.finder FXICloudDriveDesktop -bool true
defaults write com.apple.finder FXICloudDriveDocuments -bool true

msg "Keep folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

msg "Group files by Kind"
defaults write com.apple.finder FXPreferredGroupBy -string "Kind"

msg "Remove old trash items after 30 days"
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

msg "Set Documents as the default location for new Finder windows"
defaults write com.apple.finder NewWindowTarget -string "PfDo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Documents/"

msg "Show path bar"
defaults write com.apple.finder ShowPathbar -bool true


info "Configuring screen"

# msg "Re-enable subpixel antialiasing"
# defaults write -g CGFontRenderingFontSmoothingDisabled -bool false

msg "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

msg "Save screenshots to the desktop"
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

msg "Enable subpixel font rendering on non-Apple LCDs"
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write -g AppleFontSmoothing -int 1
