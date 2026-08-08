#!/usr/bin/env zsh
#
# Installs Linux packages, Flatpaks and Snaps declared in packages/packages.yml
#
# Optional tag filters (comma separated), e.g.
#   PACKAGE_TAGS=hyprland,nvidia yadm bootstrap packages
#   PACKAGE_SKIP_TAGS=gnome,gaming yadm bootstrap packages
#

set -euo pipefail

if ! is-linux; then
  msg "Not a Linux system. Skipping package installation."
  return
fi

PACKAGES_FILE="${0:A:h}/../../packages/packages.yml"
RESOLVER="${0:A:h}/../lib/resolve-packages.py"

[[ -f "$PACKAGES_FILE" ]] || fail "Package list $PACKAGES_FILE not found"
[[ -f "$RESOLVER" ]] || fail "Package resolver $RESOLVER not found"

[[ -f /etc/os-release ]] || fail "Missing /etc/os-release file"
source /etc/os-release

case " ${ID:-} ${ID_LIKE:-} " in
  *" arch "*) OS_FAMILY="archlinux" ;;
  *" debian "*|*" ubuntu "*) OS_FAMILY="debian" ;;
  *)
    msg "Unsupported distribution: ${PRETTY_NAME:-${ID:-unknown}}. Skipping."
    return
    ;;
esac

# Packages that could not be installed, reported as a summary at the end
declare -a PKG_FAILED=()

function pkg-resolve() {
  python3 "$RESOLVER" "$PACKAGES_FILE" \
    --os-family "$OS_FAMILY" \
    --tags "${PACKAGE_TAGS:-}" \
    --skip-tags "${PACKAGE_SKIP_TAGS:-}" \
    "${@}"
}

# Installs a batch of packages, falling back to one invocation per package so a
# single unavailable name does not abort the whole list.
function pkg-install-many() {
  local installer="${1}"
  shift
  local -a pkgs=("${@}")

  (( ${#pkgs} )) || return 0

  msg "Installing ${#pkgs} package(s) via ${installer#pkg-}"
  if "$installer" "${pkgs[@]}"; then
    return 0
  fi

  warn "Batch install failed. Retrying one package at a time"
  local pkg
  for pkg in "${pkgs[@]}"; do
    "$installer" "$pkg" || PKG_FAILED+=("${installer#pkg-}: $pkg")
  done
}

function pkg-pacman() {
  sudo pacman -S --needed --noconfirm "${@}"
}

function pkg-aur() {
  "$AUR_HELPER" -S --needed --noconfirm "${@}"
}

function pkg-apt() {
  sudo apt-get install -y "${@}"
}

function pkg-flatpak() {
  sudo flatpak install -y --noninteractive flathub "${@}"
}

function pkg-snap() {
  local pkg
  for pkg in "${@}"; do
    sudo snap install "$pkg" || return 1
  done
}

# Installs an apt source list plus its dearmored signing key, and registers the
# debsig-verify policy when the repository ships one.
function pkg-add-apt-repo() {
  local name="${1}" url="${2}" key="${3}" policy="${4}" keyring="${5}"
  local key_file="" policy_file="" debsig_id=""

  if [[ -n "$key" ]]; then
    key_file="$(mktemp)"
    curl -fsSL "$key" | gpg --dearmor > "$key_file"
    sudo install -Dm644 "$key_file" "$keyring"
  fi

  echo "$url" | sudo tee "/etc/apt/sources.list.d/${name}.list" >/dev/null

  # debsig-verify looks its policy up by the last 16 hex digits of the signing
  # key's fingerprint
  if [[ -n "$policy" && -n "$key_file" ]]; then
    debsig_id="$(gpg --show-keys --with-colons "$key_file" |
      awk -F: '/^fpr:/ { print substr($10, length($10) - 15); exit }')"

    if [[ -z "$debsig_id" ]]; then
      warn "Could not determine the debsig id for $name"
    else
      policy_file="$(mktemp)"
      curl -fsSL "$policy" -o "$policy_file"
      sudo install -Dm644 "$policy_file" "/etc/debsig/policies/${debsig_id}/${name}.pol"
      sudo install -Dm644 "$key_file" "/usr/share/debsig/keyrings/${debsig_id}/debsig.gpg"
      rm -f "$policy_file"
    fi
  fi

  if [[ -n "$key_file" ]]; then
    rm -f "$key_file"
  fi
}

function pkg-enable-service() {
  local service="${1}"

  if ! systemctl cat "$service" >/dev/null 2>&1; then
    notice "Service $service is not available. Skipping."
    return 0
  fi

  sudo systemctl enable --now "$service" || warn "Could not enable $service"
}


info "Installing packages for $OS_FAMILY from ${PACKAGES_FILE:t}"

if [[ -n "${PACKAGE_TAGS:-}${PACKAGE_SKIP_TAGS:-}" ]]; then
  notice "Tag filter: tags='${PACKAGE_TAGS:-*}' skip-tags='${PACKAGE_SKIP_TAGS:-}'"
fi

msg "Requesting sudo access"
sudo -v


##
## Prerequisites
##

case "$OS_FAMILY" in
  archlinux)
    has-command python3 || add-pkg python
    python3 -c "import yaml" >/dev/null 2>&1 || add-pkg python-yaml
    ;;
  debian)
    has-command python3 || add-pkg python3
    python3 -c "import yaml" >/dev/null 2>&1 || add-pkg python3-yaml
    ;;
esac

pkg-resolve >/dev/null || fail "Could not resolve ${PACKAGES_FILE:t}"


##
## Repository packages
##

if [[ "$OS_FAMILY" == "archlinux" ]]; then
  info "Importing package signing keys"

  msg "1Password"
  sudo pacman-key --recv-key 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 \
    --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 3FEF9748469ADBE15DA7CA80AC2D62742012EA22

  msg "Dropbox"
  sudo pacman-key --recv-key 1C61A2656FB57B7E4DE0F4C1FC918B335044912E \
    --keyserver keyserver.ubuntu.com
  sudo pacman-key --lsign-key 1C61A2656FB57B7E4DE0F4C1FC918B335044912E

  info "Installing repository packages"
  sudo pacman -Syu --noconfirm
  pkg-install-many pkg-pacman $(pkg-resolve --backend repo)

  info "Installing AUR packages"

  AUR_HELPER=""
  for helper in paru yay; do
    if has-command "$helper"; then
      AUR_HELPER="$helper"
      break
    fi
  done

  if [[ -z "$AUR_HELPER" ]]; then
    msg "No AUR helper found. Building yay from the AUR"

    build_dir="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
    (cd "$build_dir/yay-bin" && makepkg -si --noconfirm)
    rm -rf "$build_dir"

    AUR_HELPER="yay"
  fi

  msg "Using $AUR_HELPER"
  pkg-install-many pkg-aur $(pkg-resolve --backend aur)
fi

if [[ "$OS_FAMILY" == "debian" ]]; then
  info "Adding extra apt repositories"

  export DEBIAN_FRONTEND=noninteractive
  require ca-certificates
  require gnupg

  # not a pipeline, so that failures can be recorded in PKG_FAILED
  repositories="$(mktemp)"
  pkg-resolve --repositories > "$repositories"

  while IFS=$'\t' read -r name url key policy keyring; do
    msg "Repository $name"
    pkg-add-apt-repo "$name" "$url" "$key" "$policy" "$keyring" ||
      PKG_FAILED+=("repository: $name")
  done < "$repositories"

  rm -f "$repositories"

  info "Installing repository packages"
  sudo apt-get update
  pkg-install-many pkg-apt $(pkg-resolve --backend repo)
fi


##
## Flatpaks
##

declare -a flatpaks=($(pkg-resolve --backend flatpak))

if (( ${#flatpaks} )); then
  info "Installing Flatpaks"

  require flatpak

  msg "Adding remotes"
  sudo flatpak remote-add --if-not-exists \
    gnome https://sdk.gnome.org/gnome-apps.flatpakrepo
  sudo flatpak remote-add --if-not-exists \
    flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  pkg-install-many pkg-flatpak "${flatpaks[@]}"
fi


##
## Snaps
##

declare -a snaps=($(pkg-resolve --backend snap))

if (( ${#snaps} )); then
  info "Installing Snaps"

  if ! has-command snap; then
    if [[ "$OS_FAMILY" == "archlinux" ]]; then
      pkg-install-many pkg-aur apparmor snapd
    else
      require snapd
    fi
  fi

  for service in snapd.socket snapd.service apparmor.service snapd.apparmor.service; do
    pkg-enable-service "$service"
  done

  pkg-install-many pkg-snap "${snaps[@]}"

  if (( ${#${(M)snaps:#nordvpn*}} )); then
    info "Fixing NordVPN permissions"

    getent group nordvpn >/dev/null || sudo groupadd nordvpn
    sudo usermod -aG nordvpn "$USER"

    for iface in network-control network-observe firewall-control \
                 login-session-observe system-observe; do
      sudo snap connect "nordvpn:${iface}" || warn "Could not connect nordvpn:${iface}"
    done
  fi
fi


##
## Services
##

info "Enabling system services"
pkg-enable-service bluetooth.service


if (( ${#PKG_FAILED} )); then
  warn "${#PKG_FAILED} package(s) could not be installed:"
  for pkg in "${PKG_FAILED[@]}"; do
    msg "  $pkg"
  done
fi
