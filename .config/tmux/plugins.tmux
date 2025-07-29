# vim:fileencoding=utf-8:ft=tmux:foldmethod=marker

# Tmux Plugin Manager.
set -g @plugin 'tmux-plugins/tpm'

# Basic tmux settings everyone can agree on.
set -g @plugin 'tmux-plugins/tmux-sensible'

# Plugin for copying to system clipboard. Works on MacOS, Linux and Cygwin.
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @yank_action 'copy-pipe' # or 'copy-pipe-and-cancel' for the default

# Persists tmux environment across system restarts.
set -g @plugin 'tmux-plugins/tmux-resurrect'
# Change default keybindings for tmux-ressurect
set -g @resurrect-save 'F5'
set -g @resurrect-restore 'F6'
# Restore additional programs
set -g @resurrect-processes 'nvtop bacon lazygit "gh dash"'
# Restore pane contents. Check the `default-command` tmux option;
# it shouldn't contain `&&` or `||` operators.
set -g @resurrect-capture-pane-contents 'on'
# Restores neovim sessions (if present).
set -g @resurrect-strategy-nvim 'session'

# Continuous saving of tmux environment. Automatic restore when tmux is started.
# Automatic tmux start when computer is turned on.
set -g @plugin 'tmux-plugins/tmux-continuum'
# Don't automatically restore sessions.
set -g @continuum-restore 'on'

# Session and project manager.
set -g @plugin 'aelesbao/tmux-ctrlp'
# Remap to avoid conflict with the prefix
set -g @ctrlp_session_bind 's'

# Search your tmux scrollback buffer using fuzzy matching
set -g @plugin 'roosta/tmux-fuzzback'
set -g @fuzzback-finder 'sk'
set -g @fuzzback-popup 1
set -g @fuzzback-popup-size '90%'

# Quickly open urls using fzf
set -g @plugin 'wfxr/tmux-fzf-url'
# Captures urls from the scrollback history
set -g @fzf-url-history-limit '2000'
# Open tmux-fzf-url in a popup
set -g @fzf-url-fzf-options '-w 50% -h 50% --multi -0 --no-preview --no-border'

# Plug and play battery percentage and icon indicator for Tmux.
%if "#{TMUX_BATTERY_ENABLED}"
set -g @plugin 'tmux-plugins/tmux-battery'
set -g @batt_icon_status_attached ''
%endif

# Plug and play cpu percentage and icon indicator.
set -g @plugin 'aelesbao/tmux-cpu'
set -g @cpu_temp_medium_thresh "70"
set -g @cpu_temp_high_thresh   "85"

# Soothing pastel theme for Tmux.
set -g @plugin 'catppuccin/tmux#v2.1.3'

source ~/.config/tmux/theme.tmux

# Plugin Manager installation {{{

# Automatic tpm installation
if "test ! -d ~/.config/tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins'"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run ~/.config/tmux/plugins/tpm/tpm

# }}}
