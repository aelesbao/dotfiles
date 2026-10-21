# Agents Instructions

This file provides guidance to coding agents working on this configuration.

Personal tmux configuration targeting tmux 3.7+. Use its features, including hyperlinks, `new-pane`, and extended keys; do not add compatibility workarounds for older tmux versions. There is no build or test suite. This directory is not its own git repo; it is tracked by yadm as part of the dotfiles (`~/.local/share/yadm/repo.git`).

## Applying and checking changes

- Reload the running server only when requested: `tmux source-file ~/.config/tmux/tmux.conf`. Reloading executes scripts and initializes plugins.
- Parse without executing commands: `tmux source-file -n ~/.config/tmux/tmux.conf ~/.config/tmux/{options,keymaps,plugins,theme}.tmux ~/.config/tmux/status/*.tmux` (Bash/Zsh brace expansion). This requires a running server but does not apply configuration. Include all files explicitly because `-n` does not execute nested `source` commands. Parsing alone does not validate runtime behavior or every conditional branch.
- A separate server (`tmux -L <unique-name> -f ...`) isolates tmux state, not filesystem or external side effects. Loading the full configuration can initialize tpack and modify shared plugin directories; it is not a side-effect-free syntax check.
- Inspect an expanded format with `tmux display -p '#{E:@catppuccin_status_sensors}'`. Inspect the stored status string with `tmux show -gv status-right`; this does not expand it.
- Install/update plugins: `tpack install` / `tpack update`, or the TPM-compatible bindings (`prefix + I` / `prefix + U`). Open the tpack TUI with `prefix + T`.
- `plugins/` is gitignored. Don't edit vendored plugins except `tmux-ctrlp` and `tmux-cpu`, which are the user's own forks.

## Load order

`tmux.conf` sets `@ansi_cleanup`/`@ansi_to_tmux` to the scripts' absolute paths, then sources, in order:

1. `options.tmux`: core options, including the `C-s` prefix. Starts `scripts/test-battery` asynchronously with `if -b` and sets the global `TMUX_BATTERY_ENABLED` environment variable to `1` on success. Later `%if` blocks depend on it, but the asynchronous check is not guaranteed to finish before they are parsed. Failure does not clear an existing value. On macOS the helper checks for "Battery Power", not just battery presence.
2. `keymaps.tmux`: bindings. Starts `user-keys.sh` asynchronously. The script assigns `User0` to Alt+Shift+Enter and `User10` through `User29` to Ctrl+digit and Ctrl+Alt+digit CSI sequences. `User1` through `User9` are reserved but not assigned. Bindings such as `User12` rely on these mappings.
3. `plugins.tmux`: `@plugin` declarations and their options, then sources `theme.tmux`, then initializes the plugin manager. **Plugin manager initialization must stay last**: plugins such as `tmux-cpu` and `tmux-battery` interpolate placeholders (`#{cpu_percentage}`, etc.) into `status-right` when they run, so the status line has to be fully built first.

## Plugin manager migration

- Migration from TPM to [tpack](https://github.com/tmuxpack/tpack/blob/main/README.md) is in progress. Prefer tpack for new changes; existing TPM syntax is supported.
- `plugins.tmux` runs `tpack init` when the binary is available. Otherwise, it clones tpack into `plugins/tpm` if that directory is missing and runs `plugins/tpm/tpm`. An existing directory is not automatically migrated, so inspect its remote before assuming it contains tpack.
- tpack uses repository-specific directory names such as `tmux-87a1216f1f68` and renames legacy plugin directories. Audit hard-coded paths, especially `plugins/tmux` in the theme and status modules, during migration. The paths described below reflect the current configuration, not guaranteed tpack locations.
- Do not run TPM and tpack against the same plugin root. Switching back to TPM is not seamless after directory migration.

## Status line (theme.tmux + status/)

- Theme is catppuccin, currently referenced at `plugins/tmux`. `theme.tmux` runs `catppuccin.tmux` before building the status line when that file exists. Flavor is `frappe` when the tmux environment contains `SSH_CLIENT` or `SSH_TTY`, otherwise `mocha`; this is not a per-client SSH check.
- `status/*.tmux` are custom catppuccin modules. Each sets `%hidden MODULE_NAME`, defines `@catppuccin_<name>_{icon,color,text}`, then sources `plugins/tmux/utils/status_module.conf`, which produces `@catppuccin_status_<name>`. Use `-o` for overridable defaults and set overrides in `theme.tmux` before sourcing modules. Not every current setting is a default: sensors and git text, for example, are reset unconditionally. Follow the module structure for new modules and append them to `status-right` in `theme.tmux`.
- `sensors.tmux` wraps tmux-cpu placeholders in `#{l:...}` so they survive the `-F` expansion in `set -gaF status-right` and arrive as literal `#{cpu_*}` for the plugin to interpolate.
- Starship modules shell out to `starship module ...` and pipe through `scripts/ansi-cleanup` (strip escapes) or `scripts/ansi-to-tmux` (convert SGR codes to `#[...]` styles).
- Some modules are conditionally shown by `client_width` (git > 240 cols and a nonempty `@git_branch`, netspeed > 280).
- For the `dotfiles` and `hyprland` sessions, the git module reads the yadm repo instead of the pane's cwd.

## Other files

- `ctrlp.config.zsh` (gitignored): project/session definitions for the `tmux-ctrlp` plugin (`config-session`, `config-org-session`).
- `scripts/`: helpers used by the status line (`netspeed`, ANSI converters) and `test-battery` (a runtime battery probe, not a test suite).
- `CLAUDE.md` is a symlink to `AGENTS.md`; edit the target rather than replacing the symlink.
- Use `yadm` for tracked changes. From this directory, use paths relative to the current directory (for example, `yadm diff -- theme.tmux`), not `.config/tmux/...`.

## Conventions

- Tmux files start with a Vim `ft=tmux` modeline. Top-level files specify marker folding; use `{{{`/`}}}` where sections already use them. Shell and Perl helpers start with their interpreter shebangs instead.
- Align option values in columns within a block, as the existing files do.
- Preserve Linux and macOS support, but do not assume stock macOS tools suffice. `scripts/netspeed` uses Bash associative arrays (Bash 4+), `bc`, and GNU `numfmt`; ANSI converters require Perl. Starship modules require `starship` and `git`.
- Keep configuration changes separate from plugin installation, updates, and migration unless those operations are requested.
