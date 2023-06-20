#!/usr/bin/env zsh
#
# Docker and Colima setup
#

set -euo pipefail

mkdir -p ~/.docker/cli-plugins

info "Installing CLI plugins"

for plugin in buildx compose; do
  if [[ -x /usr/local/opt/docker-$plugin/bin/docker-$plugin ]]; then
    ln -sfn /usr/local/opt/docker-$plugin/bin/docker-$plugin ~/.docker/cli-plugins/docker-$plugin
  fi
done
