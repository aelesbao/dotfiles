#!/usr/bin/env zsh
#
# vconsole setup
#

set -euo pipefail


info "Configuring console font"
local font="ter-v16n"
if ! grep -q "^FONT=$font$" /etc/vconsole.conf; then
  echo "FONT=$font" >> /etc/vconsole.conf
  notice "using $font font"
fi
