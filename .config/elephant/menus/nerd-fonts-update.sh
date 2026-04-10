#!/bin/sh
# Updates Nerd Fonts glyphs JSON from the latest release tag.

set -eu

REPO="ryanoasis/nerd-fonts"
OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_FILE="${OUTPUT_DIR}/nerd-fonts-glyphs.json"

latest_tag=$(curl -fsSL -o /dev/null -w '%{url_effective}' \
  "https://github.com/${REPO}/releases/latest" \
  | sed 's|.*/||')

if [ -z "$latest_tag" ]; then
  echo "error: failed to resolve latest tag" >&2
  exit 1
fi

url="https://raw.githubusercontent.com/${REPO}/refs/tags/${latest_tag}/glyphnames.json"

echo "Downloading glyphnames.json from ${latest_tag}..."
curl -fsSL -o "$OUTPUT_FILE" "$url"

echo "Saved to ${OUTPUT_FILE}"
