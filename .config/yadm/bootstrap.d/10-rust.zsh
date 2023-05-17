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

rustup set profile default

info "Updating rust stable"
rustup update stable
rustup target add wasm32-unknown-unknown

info "Updating rust nightly"
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly

info "Installing rustup components"
rustup component add rls
rustup component add rust-analysis
rustup component add rust-src
rustup component add clippy
rustup component add llvm-tools-preview

function add-plugin() {
  local name="$1"
  local features="${2:-}"

  msg "$name"
  if [[ -z "$features" ]]; then
    cargo install "$name"
  else
    cargo install "$name" --features "$features"
  fi
}

info "Installing cargo plugins"

RUSTC_WRAPPER= cargo binstall --no-confirm \
  sccache \
  cargo-audit \
  cargo-edit \
  cargo-generate \
  cargo-make \
  cargo-modules \
  cargo-nextest \
  cargo-outdated \
  cargo-release \
  cargo-run-script \
  cargo-watch \
  grcov

sccache --start-server

curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
