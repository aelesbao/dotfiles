#!/bin/sh

set -eu

THEME="${1:-}"

if [ -z "$THEME" ]; then
  echo "Usage: $0 <theme-name>"
  exit 1
fi

THEME_DIR="./themes/$THEME"

if [ ! -d "$THEME_DIR" ]; then
  echo "Error: Theme '$THEME' does not exist."
  exit 1
fi

ln -sf "$THEME_DIR/config.json" config.json
ln -sf "$THEME_DIR/style.css" theme.css

echo "Switched to theme '$THEME'"

echo "Restarting swaync service..."
systemctl --user restart swaync.service
