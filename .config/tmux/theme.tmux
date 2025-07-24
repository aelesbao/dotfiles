# vim:fileencoding=utf-8:ft=tmux:foldmethod=marker

if "test -f ~/.config/tmux/plugins/tmux/catppuccin.tmux" \
   "run ~/.config/tmux/plugins/tmux/catppuccin.tmux"

set -g status-right-length 100
set -g status-left-length 100

set -g status-left ""

# Display hostname when connected via SSH
%if "#{||:#{SSH_CLIENT},#{SSH_TTY}}"
set -ga status-left "#[bg=#{@thm_peach},fg=#{@thm_crust}]#[reverse]█#[noreverse]  "
%else
set -ga status-left "#[bg=#{@thm_blue},fg=#{@thm_crust}]#[reverse]█#[noreverse]  "
%endif

set -gaF status-left "#[fg=#{@thm_fg},bg=#{@thm_surface_0}] ##H "
set -ga status-left "#[fg=#{@thm_fg},bg=#{@thm_bg}] "

set -g status-right "#{E:@catppuccin_status_application}"
set -ga status-right "#{E:@catppuccin_status_session}"
set -gaF status-right "#{E:@catppuccin_status_cpu}"

%if "#{TMUX_BATTERY_ENABLED}"
set -gaF status-right "#{E:@catppuccin_status_battery}"
%endif

set -gaF status-right "#{E:@catppuccin_status_date_time}"
