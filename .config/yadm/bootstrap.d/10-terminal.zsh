#!/usr/bin/env zsh
#
# Configures terminal apps
#

set -euo pipefail

if is-macos && is-pkg-installed iterm2; then
  info "Configuring iTerm"

  # Configure shared settings folder
  defaults write com.googlecode.iterm2 PrefsCustomFolder "~/Dropbox/Apps/iTerm"

  if ! [[ -f ~/.iterm2_shell_integration.zsh ]]; then
    curl -fsSL https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
  fi
fi

if is-macos && has-command kitty; then
  info "Configuring Kitty"
  kitty_app_path=$(find /Applications -name "kitty.app" -maxdepth 1)

  msg "Set icon"
  cp ~/.config/kitty/kitty-icon/kitty.icns ${kitty_app_path}/Contents/Resources/kitty.icns
  cp ~/.config/kitty/kitty-icon/icon_128x128.png ${kitty_app_path}/Contents/Resources/kitty/logo/kitty-128.png
  cp ~/.config/kitty/kitty-icon/icon_256x256.png ${kitty_app_path}/Contents/Resources/kitty/logo/kitty.png

  msg "Refresh icon cache"
  touch ${kitty_app_path}
  rm /var/folders/*/*/*/com.apple.dock.iconcache
  killall Dock
fi
