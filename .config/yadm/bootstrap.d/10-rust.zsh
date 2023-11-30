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
  rustup update nightly
  rustup target add wasm32-unknown-unknown --toolchain nightly
fi

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

if ! (( $+commands[cargo-binstall] )); then
  curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
fi

function binstall() {
  RUSTC_WRAPPER= cargo binstall --no-confirm ${@:$#}
}

binstall sccache
binstall cargo-audit
binstall cargo-edit
binstall cargo-generate
binstall cargo-info
binstall cargo-make
binstall cargo-modules
binstall cargo-nextest
binstall cargo-outdated
LDFLAGS="-L$(brew --prefix openssl@1.1)/lib" CPPFLAGS="-I$(brew --prefix openssl@1.1)/include" binstall cargo-release
binstall cargo-run-script
binstall cargo-watch
binstall evcxr_repl
binstall grcov

sccache --start-server

if ask "Install wasm-pack?"; then
  curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
fi
