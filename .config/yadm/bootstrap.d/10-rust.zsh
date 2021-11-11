#!/usr/bin/env zsh
#
# Rust setup
#

set -euo pipefail

if ! (( $+commands[rustup] )); then
  info "Installing Rust"
  if (( $+commands[rustup-init] )); then
    rustup-init -y --no-modify-path
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
  source "$HOME/.cargo/env"
fi

info "Configuring Rust"

rustup set profile default

rustup update stable
rustup target add wasm32-unknown-unknown

rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly

rustup component add rls
rustup component add rust-analysis
rustup component add rust-src
