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
if ask "Update to latest nightly version?"; then
  rustup toolchain update nightly --allow-downgrade
  rustup target add wasm32-unknown-unknown --toolchain nightly
fi

info "Installing rustup components"
rustup component add rls
rustup component add rust-analysis
rustup component add rust-src
rustup component add clippy
rustup component add llvm-tools-preview

info "Installing cargo plugins"

function cargo-install() {
  local name="$1"
  local extra=${@:2}

  msg "$name"
  RUSTC_WRAPPER= cargo install --locked "$name" ${extra[@]}
}

function binstall() {
  RUSTC_WRAPPER= cargo binstall --no-confirm ${@:$#}
}

if ! (( $+commands[cargo-binstall] )); then
  curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
fi

if ask "Update installed crates?"; then
  # binstall sccache # <- installed with Homebrew
  cargo-install bacon
  binstall cargo-audit
  binstall cargo-edit
  binstall cargo-expand
  binstall cargo-generate
  binstall cargo-info
  binstall cargo-make
  binstall cargo-modules
  binstall cargo-nextest
  binstall cargo-outdated
  cargo-install cargo-release
  binstall cargo-run-script
  binstall cargo-tarpaulin
  binstall cargo-watch
  binstall evcxr_repl
  binstall grcov
  cargo-install stylua --all-features
fi

msg "Starting sccache server"
sccache --start-server

if ask "Install wasm-pack?"; then
  curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
fi
