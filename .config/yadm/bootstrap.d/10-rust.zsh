#!/usr/bin/env zsh
#
# Rust setup
#

set -euo pipefail

if ! (( $+commands[rustup] )); then
  info "Installing Rust"
  if (( $+commands[rustup-init] )); then
    rustup-init -y
    source "$HOME/.cargo/env"
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  fi
fi

info "Configuring Rust"

rustup update nightly
rustup update stable

rustup target add wasm32-unknown-unknown --toolchain nightly
rustup component add rustfmt
