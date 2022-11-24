#!/usr/bin/env zsh
#
# Configures terminal apps
#

set -euo pipefail

if is-macos && is-pkg-installed iterm2; then
  info "Configuring iTerm"
  macos-change-app-icon "iTerm" "$HOME/.config/iterm2/terminal-icons/icns/synthwave_option_6.icns"

  # Configure shared settings folder
  defaults write com.googlecode.iterm2 PrefsCustomFolder "~/.config/iterm2"

  if ! [[ -f ~/.iterm2_shell_integration.zsh ]]; then
    curl -fsSL https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
  fi
fi

if has-command kitty; then
  info "Configuring Kitty"

  macos-change-app-icon "kitty" "$HOME/.config/kitty/kitty-icon/kitty.icns"
fi

macos-refresh-icons
