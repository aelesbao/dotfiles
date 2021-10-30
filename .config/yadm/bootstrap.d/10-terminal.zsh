#!/usr/bin/env zsh
#
# Configures terminal apps
#

set -euo pipefail

if is-macos && [[ -d /Applications/iTerm.app ]]; then
  info "Configuring iTerm"

  # Configure shared settings folder
  defaults write com.googlecode.iterm2 PrefsCustomFolder '~/Dropbox/Apps/iTerm'

  curl -fsSL https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
fi
