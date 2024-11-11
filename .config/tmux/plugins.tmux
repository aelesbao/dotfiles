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
set -g @resurrect-processes 'btop lazygit "~node dev"'
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

# # Copy pasting in terminal with vimium/vimperator like hints.
# set -g @plugin 'Morantron/tmux-fingers'
# set -g @fingers-jump-key /
# # Cosmos address matcher
# set -g @fingers-pattern-0 '([a-z]+)1([qpzry9x8gf2tvdw0s3jn54khce6mua7l]+)'

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

set -g @plugin 'yardnsm/tmux-1password'
set -g @1password-key 'o'

# A Tokyo Night tmux theme directly inspired from Tokyo Night vim theme.
# set -g @plugin 'fabioluciano/tmux-tokyo-night'
# Tokyo Night Theme configuration
# set -g @theme_variation 'storm'
# set -g @theme_left_separator ''
# set -g @theme_right_separator ''
# set -g @theme_plugin_datetime_format '%a %F %R'

# Soothing pastel theme for Tmux.
set -g @plugin 'catppuccin/tmux#v2.1.0'

if "test -f ~/.config/tmux/plugins/tmux/catppuccin.tmux" \
   "run ~/.config/tmux/plugins/tmux/catppuccin.tmux"

# Catppuccin theme settings (use mocha on the host and frappe on ssh)
%if "#{||:#{SSH_CLIENT},#{SSH_TTY}}"
   set -g @catppuccin_flavor "frappe"
%else
   set -g @catppuccin_flavor "mocha"
%endif

set -g @catppuccin_window_text " #W"
set -g @catppuccin_window_current_text " #W"

set -g @catppuccin_status_background "#{@thm_bg}"

set -g status-right-length 100
set -g status-left-length 100

set -g status-left ""

%if "#{||:#{SSH_CLIENT},#{SSH_TTY}}"
   set -g status-left "#[bg=#{@thm_peach},fg=#{@thm_crust}]#[reverse]█#[noreverse]  "
   set -gaF status-left "#[fg=#{@thm_fg},bg=#{@thm_surface_0}] ##H "
%endif

set -g status-right "#{E:@catppuccin_status_application}"
set -ga status-right "#{E:@catppuccin_status_session}"
set -gaF status-right "#{E:@catppuccin_status_cpu}"

%if "#{==:0,#{||:#{SSH_CLIENT},#{SSH_TTY}}}"
   set -gaF status-right "#{E:@catppuccin_status_battery}"
%endif

set -gaF status-right "#{E:@catppuccin_status_date_time}"

# Plug and play battery percentage and icon indicator for Tmux.
set -g @plugin 'tmux-plugins/tmux-battery'
set -g @batt_icon_status_attached ''

# Plug and play cpu percentage and icon indicator.
set -g @plugin 'tmux-plugins/tmux-cpu'

set -g @cpu_percentage_format "%2.0f%%"

# Plugin Manager installation {{{

# Automatic tpm installation
if "test ! -d ~/.config/tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins'"

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.config/tmux/plugins/tpm/tpm'

# }}}
