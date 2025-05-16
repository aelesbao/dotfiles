#!/usr/bin/env zsh

set -euo pipefail


if (( ! $+commands[gnome-shell] )); then
  echo "gnome-shell not available"
  return 1
fi


# Setup directories
declare src_dir=~/.local/share/src
declare themes_dir=~/.local/share/themes
declare icons_dir=~/.local/share/icons

mkdir -p ~/.local/share/{icons,src,themes}


function install-cursor() {
  local repo="$1"
  local cursor="$2"
  local ext="${3:-tar.xz}"
  local file="${cursor}.${ext}"

  local cursor_dir="${icons_dir}/${cursor}"

  printf "- %s: " "$cursor"

  if [[ -d ${cursor_dir} ]]; then
    echo "already installed"
    return
  fi

  curl -LOSsf --create-dirs --output-dir ${icons_dir} \
    "https://github.com/${repo}/releases/latest/download/${file}"

  if [[ "${ext}" == "tar.xz" ]]; then
    tar -C ${icons_dir} -xf "${file}"
  else
    unzip -qq -o -d ${icons_dir} "${icons_dir}/${file}"
  fi

  rm -f "${icons_dir}/${file}"

  gtk4-update-icon-cache ${cursor_dir} >/dev/null 2>&1 || true
  gtk-update-icon-cache ${cursor_dir} >/dev/null 2>&1 || true

  echo "done"
}

function clone-repo() {
  local gh_user="$1"
  local repo="$2"
  local branch="${3:-master}"

  local repo_dir="${src_dir}/${repo}"

  if [[ ! -d ${repo_dir} ]]; then
    gum spin --title="cloning ${gh_user}/${repo}" --spinner points --show-error -- cat <( \
      git clone https://github.com/${gh_user}/${repo}.git ${repo_dir} 2>&1; \
      git -C ${repo_dir} checkout ${branch} 2>&1 \
    )
  else
    gum spin --title="updating ${gh_user}/${repo}" --spinner points --show-error -- cat <( \
      git -C ${repo_dir} pull --rebase 2>&1; \
      git -C ${repo_dir} checkout ${branch} 2>&1 \
    )
  fi
}

function install-eliverlara-theme() {
  local repo="$1"
  local branch="${2:-master}"
  local theme="${3:-${repo}${2:+-${2}}}"

  local repo_dir="${src_dir}/${repo}"
  local theme_dir="${themes_dir}/${theme}"

  echo "- $theme"

  clone-repo EliverLara ${repo} ${branch}

  pushd ${repo_dir}/gtk-2.0
  gum spin --title="rendering gtk-2.0" --spinner points --show-error -- cat <( \
    ./render-assets.sh 2>/dev/null \
  )
  popd

  pushd ${repo_dir}/src
  gum spin --title="rendering src" --spinner points --show-error -- cat <( \
    ./render-gtk3-assets.py 2>/dev/null; \
    ./render-gtk3-assets-hidpi.py 2>/dev/null; \
    ./render-wm-assets-hidpi.py 2>/dev/null; \
    ./render-wm-assets.py 2>/dev/null \
  )
  popd

  gum spin --title="copying files" --spinner points --show-error -- cat <( \
    mkdir -p ${theme_dir}; \
    cp -a ${repo_dir}/* ${theme_dir} \
  )

  echo "  done"
  echo
}

function install-fausto-korpsvart-theme() {
  local repo="$1"
  local branch="$2"
  local theme="$3"
  local variant="${4:-default}"

  local repo_dir="${src_dir}/${repo}"

  echo "- $theme [$variant]"

  clone-repo Fausto-Korpsvart ${repo} ${branch}

  gum spin --title="linking" --spinner points --show-error -- cat <( \
    ${repo_dir}/themes/install.sh \
      -n ${theme} \
      -t ${variant} \
      -c dark \
      --tweaks black outline \
      -d ${themes_dir}
  )

  echo "  done"
  echo
}

function install-flat-remix() {
  local name="Flat-Remix"
  local base_theme_dir="${themes_dir}/${name}"

  echo "- ${name}"


  clone-repo daniruiz flat-remix-gtk
  cd ${src_dir}/flat-remix-gtk

  local color="Violet"
  local variant="Darkest"

  local color_theme_dir="${base_theme_dir}-${color}-${variant}"
  local variant_theme_dir="${base_theme_dir}-${variant}"

  gum spin --title="building gtk" --spinner points --show-error -- cat <( \
    make -j build dist \
      COLOR_VARIANTS="${color}" 2>&1 \
  )

  rm -rf ${color_theme_dir} ${variant_theme_dir}{,-hdpi,-xhdpi}
  mkdir -p ${color_theme_dir} ${variant_theme_dir}{,-hdpi,-xhdpi}

  local d="$(mktemp -d)"
  tar -C ${d} -xf 01-${name}-GTK-${color}_*.tar.xz

  mv ${d}/${name}-GTK-${color}-${variant}/* ${color_theme_dir}
  mv ${d}/${name}-${variant}-Metacity/* ${variant_theme_dir}
  mv ${d}/${name}-${variant}-XFWM/* ${variant_theme_dir}
  mv ${d}/${name}-${variant}-XFWM-HiDPI/* ${variant_theme_dir}-hdpi
  mv ${d}/${name}-${variant}-XFWM-xHiDPI/* ${variant_theme_dir}-xhdpi


  clone-repo daniruiz flat-remix-gnome
  cd ${src_dir}/flat-remix-gnome

  local variant_theme_dir="${base_theme_dir}-${variant}"

  gum spin --title="building gnome-shell" --spinner points --show-error -- cat <( \
    make -j build dist \
      THEME_VARIANTS="Darkest Miami-Dark" \
      BASE_THEME="Flat-Remix-Darkest" 2>&1 \
  )

  tar -C ${themes_dir} -xf themes/*-${name}-Darkest-fullPanel_*.tar.xz
  tar -C ${themes_dir} -xf themes/*-${name}-Miami-Dark-fullPanel_*.tar.xz


  echo "  done"
  echo
}


echo
echo "Installing themes"

install-eliverlara-theme Andromeda-gtk main Andromeda
install-fausto-korpsvart-theme Tokyonight-GTK-Theme master Tokyonight
install-fausto-korpsvart-theme Tokyonight-GTK-Theme master Tokyonight purple
install-fausto-korpsvart-theme Catppuccin-GTK-Theme main Catppuccin
install-fausto-korpsvart-theme Catppuccin-GTK-Theme main Catppuccin purple
install-flat-remix


echo "Installing cursors"

declare -a variants

# Catppuccin
variants=( mocha-dark )
for variant in ${variants[@]}; do
  install-cursor catppuccin/cursors "catppuccin-${variant}-cursors" zip
done

# Bibata
variants=(
  Bibata-Modern-Classic
  Bibata-Modern-Ice
)
for variant in ${variants[@]}; do
  install-cursor ful1e5/Bibata_Cursor "${variant}"
done

