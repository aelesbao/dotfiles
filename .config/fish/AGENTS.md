# AGENTS.md

## Scope
- Treat `~/.config/fish` as the repo root for this config.
- yadm manages this repo. The worktree has no `.git` directory because yadm stores it at `~/.local/share/yadm/repo.git`.
- This is a Fish shell config. Prefer Fish syntax and verify with Fish before reporting changes.

## Verify
- Syntax-check all loaded Fish files from this directory: `fish -n config.fish conf.d/*.fish functions/*.fish completions/*.fish themes/*.theme`.
- Check installed Fisher plugins with `fish -lc 'fisher list'`; plugin files are expanded into this directory, not kept under a separate vendor folder.

## Startup Flow
- `config.fish` selects `tokyonight_night`, then only in interactive shells initializes `direnv`, `starship`, `zoxide`, hushlogin, `EDITOR=nvim`
- `conf.d/*.fish` is sourced by Fish at startup. Current unguarded startup hooks load `fnm`, Cargo env, Safe-chain, and the Git plugin init, so avoid adding noisy output or fragile external calls there.
- `functions/*.fish` files are autoloaded by function name; `completions/*.fish` files are shell completions.

## Plugin State
- `fish_plugins` is the source of truth for Fisher plugins; current plugin state is `jhillyerd/plugin-git`.
- `fish_variables` records Fish universal variables and Fisher's installed-file list. Do not hand-edit it for plugin changes; edit `fish_plugins` and intentionally run `fish -lc 'fisher update'` instead.
- Many `functions/*.fish` and `conf.d/git.fish` are generated/managed by `jhillyerd/plugin-git`; do not treat them as local hand-written helpers unless deliberately patching the installed plugin copy.

## Repo-Specific Gotchas
- Node version switching is wired through `fnm` in `conf.d/fnm.fish`; a leftover `nvm_default_version` universal variable exists, but no `nvm.fish` plugin files are currently installed.
- The Git plugin defines abbreviations/functions that bypass checks or destroy state, including `gcv`, `gpv`, `gwip`, `grhh`, and `gclean!!`; use explicit safe Git commands in automation instead of these shortcuts.
- `push_line` binds `Esc+q` via `fish_user_key_bindings`; keep the binding event-based so it survives plugins or modes that reset bindings.
