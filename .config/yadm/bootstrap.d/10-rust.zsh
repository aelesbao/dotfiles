#!/usr/bin/env zsh
#
# Rust setup
#

set -euo pipefail

if ! (( $+commands[rustup] )); then
  msg "rustup not installed"
  return 1
fi

info "Configuring Rust"

rustup update nightly
rustup update stable

rustup target add wasm32-unknown-unknown --toolchain nightly
rustup component add rustfmt
