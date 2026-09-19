# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Personal dotfiles managed by [yadm](https://github.com/TheLocehiliosan/yadm). The **work tree is `$HOME`** and the bare repo lives at `~/.local/share/yadm/repo.git`. There is no `.git` directory here — every git operation must go through `yadm`, not `git`:

```bash
yadm status
yadm add <path>          # paths are relative to $HOME
yadm commit
yadm push
yadm ls-files            # canonical list of tracked dotfiles
```

`~/.config/yadm` (this directory) is yadm's own config dir: bootstrap scripts, Ansible playbook, hooks, and encryption settings. Its contents are themselves tracked under `.config/yadm/` in the repo.

The public entry point is `install.sh` at the repo root (`yadm show HEAD:install.sh`), fetched via curl on a fresh machine. It installs Homebrew/yadm/zsh, clones the repo with `--no-bootstrap`, then `exec yadm bootstrap`.

## Bootstrap system

`bootstrap` (zsh) is the orchestrator. It defines a small helper library, then sources scripts from `bootstrap.d/`:

- `bootstrap.d/macos/` — Darwin-only, run first on macOS
- `bootstrap.d/linux/` — selected by `$ID_LIKE` from `/etc/os-release` (`arch.zsh`, `debian.zsh`)
- `bootstrap.d/shared/` — cross-platform, always run last

Scripts run in filename sort order (`00-` … `10-`), and only if executable. A script is skipped when its name contains `##` or ends with `~` — that is the mechanism for temporarily disabling one.

Run everything, or filter by script basename:

```bash
yadm bootstrap              # full run for the detected OS
yadm bootstrap rust nodejs  # only 10-rust.zsh and 10-nodejs.zsh (plus matching shared scripts)
```

Note: with a filter, the platform-specific directory is matched against the filter too, and shared scripts always run filtered by the same names.

### Writing bootstrap scripts

Scripts are **sourced**, not executed, so they inherit the helper library and must use `return` (never `exit`) to bail out early. Standard shape:

```zsh
#!/usr/bin/env zsh
#
# Short description
#

set -euo pipefail

if ! has-command foo; then
  msg "foo not found. Skipping."
  return
fi

info "Doing the thing"
```

Helpers available from `bootstrap`: `info` / `notice` / `success` / `warn` / `error` / `msg` / `title` (styled output), `fail` (error + exit), `ask` (y/N prompt), `has-command`, `is-macos`, `is-linux`, `get-distro`, `has-pkg`, `add-pkg`, `require` (install if missing), `open`, `gh-latest-tag`, `run-boot`.

Scripts must be **idempotent** — they run repeatedly on every bootstrap. The existing scripts do this by grepping config files before appending, checking for marker files, and guarding installs with `has-command` / `require`. Make new scripts executable (`chmod +x`) or they will silently never run.

Scripts using `$0` for path resolution must use zsh modifiers (`${0:A:h}`) since sourcing changes `$0` semantics — see `shared/03-packages.zsh`.

## Package layer

`shared/03-packages.zsh` is the package installation layer for Linux; macOS uses Homebrew via `~/.Brewfile` (`shared/03-homebrew.zsh`). It replaced an Ansible playbook — there is no Ansible anywhere in the bootstrap any more.

The script reads `packages/packages.yml` through `bootstrap.d/lib/resolve-packages.py`, which projects each entry onto exactly one backend and prints a flat list. The script then installs each backend's list: `pacman` + an AUR helper (`paru`/`yay`, built from the AUR if neither exists) on Arch, `apt-get` on Debian, plus `flatpak` and `snap` on both.

```bash
yadm bootstrap packages                                  # full run
PACKAGE_TAGS=hyprland,nvidia yadm bootstrap packages     # only tagged entries
PACKAGE_SKIP_TAGS=gnome,gaming yadm bootstrap packages   # everything but those

# inspect the resolved plan without installing anything
python3 bootstrap.d/lib/resolve-packages.py packages/packages.yml --os-family archlinux
python3 bootstrap.d/lib/resolve-packages.py packages/packages.yml --os-family debian --backend flatpak
```

Batch installs fall back to one invocation per package when the batch fails, so a single unavailable name cannot abort the run; failures are collected and reported at the end.

### `packages/packages.yml`

A single flat list is the source of truth for all Linux packages. Each entry is a name plus optional per-backend overrides:

```yaml
- name: csvq              # default: install `csvq` from the distro repo
  desc: SQL-like query language for csv
  archlinux:
    aur: csvq-bin         # on Arch, install from AUR via yay instead

- name: gh
  archlinux: github-cli   # scalar form: rename the repo package on Arch

- name: brave-browser
  flatpak: com.brave.Browser   # no repo package; install as a Flatpak

- name: mailspring
  snap: mailspring
  flatpak: com.getmailspring.Mailspring   # flatpak wins over snap
```

Precedence encoded in the resolver: an OS-family key (`archlinux` / `debian`) overrides everything; otherwise `flatpak` beats `snap`; entries with neither go to the system package manager. Keep the list alphabetically sorted by `name` and include `desc`.

The optional `tags:` list (`ai`, `gaming`, `gnome`, `hyprland`, `kde`, `nvidia`) is only consulted when `PACKAGE_TAGS` / `PACKAGE_SKIP_TAGS` are set — an unfiltered run installs everything.

The top-level `repositories:` map holds extra apt sources; each entry's `key` is dearmored into the path named by the `signed-by=` option in `url`, and `policy` sets up `debsig-verify` under the last 16 hex digits of the key fingerprint.

## Secrets and encryption

`encrypt` lists paths encrypted into `.local/share/yadm/archive` with the GPG recipient in `config` (`15A61A97FFAE83F3`). The `hooks/post_pull` hook (symlinked as `post_plr`) runs `yadm decrypt` automatically after pull. Never commit plaintext for anything listed in `encrypt`.

## Submodules

Several config dirs are submodules (`.config/nvim`, `.zprezto`, theme repos, `.config/alacritty/themes`). `yadm bootstrap` starts with `yadm submodule update --recursive --init`. Changes inside them are committed in their own upstream repos; here you only ever bump the recorded commit.

## Commits

Conventional Commits, enforced by the `git-conventions` skill (`.agents/skills/git-conventions/`). Scope is the tool or area being configured, matching the directory name: `feat(hypr):`, `feat(waybar):`, `chore(yazi):`, `feat(yadm):`, `build:` for submodule bumps. Keep commits atomic — one tool's config per commit.
