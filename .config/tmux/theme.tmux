# vim:fileencoding=utf-8:ft=tmux:foldmethod=marker

# Catppuccin theme settings (use mocha on the host and frappe on ssh)
%if "#{||:#{SSH_CLIENT},#{SSH_TTY}}"
set -g @catppuccin_flavor "frappe"
%else
set -g @catppuccin_flavor "mocha"
%endif

set -g @catppuccin_pane_status_enabled "yes"
set -g @catppuccin_pane_border_status  "yes"

# Sets the background color of the status line.
set -g @catppuccin_status_background "#{@thm_bg}"

set -g @catppuccin_window_text         " #W"
set -g @catppuccin_window_current_text " #W"
set -g @catppuccin_window_status_style "basic"
set -g @catppuccin_window_flags        "icon" # none, icon, or text

# Status line options
set -g @catppuccin_status_left_separator    "█"
set -g @catppuccin_status_middle_separator  ""
set -g @catppuccin_status_right_separator   " "
set -g @catppuccin_status_connect_separator "yes"
set -g @catppuccin_status_fill              "icon"

# Modules settings
set -g @catppuccin_session_icon " "
set -g @catppuccin_session_color "#{?client_prefix,#{E:@thm_red},#{E:@thm_blue}}"

%if "#{||:#{SSH_CLIENT},#{SSH_TTY}}"
set -g @catppuccin_host_icon "󰒍 "
set -gF @catppuccin_host_icon_bg "#{E:@thm_peach}"
%else
set -g @catppuccin_host_icon "󰒋 "
set -gF @catppuccin_host_icon_bg "#{E:@thm_mauve}"
%endif

if "test -f ~/.config/tmux/plugins/tmux/catppuccin.tmux" \
   "run ~/.config/tmux/plugins/tmux/catppuccin.tmux"

set -g status-right-length 100
set -g status-left-length 100

set -g status-left ""
set -ga status-left "#{E:@catppuccin_status_session}"
set -ga status-left "#[fg=#{@thm_fg},bg=#{@thm_bg}] "

set -g status-right ""
set -ga status-right "#{E:@catppuccin_status_application}"
set -ga status-right "#{E:@catppuccin_status_directory}"
set -gaF status-right "#{E:@catppuccin_status_cpu}"

%if "#{TMUX_BATTERY_ENABLED}"
set -gaF status-right "#{E:@catppuccin_status_battery}"
%endif

set -gaF status-right "#{E:@catppuccin_status_date_time}"
set -gaF status-right "#{E:@catppuccin_status_host}"
