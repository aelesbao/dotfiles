# vim:fileencoding=utf-8:ft=tmux:foldmethod=marker

# Catppuccin theme settings (use mocha on the host and frappe on ssh)
%if "#{||:#{SSH_CLIENT},#{SSH_TTY}}"
set -g @catppuccin_flavor "frappe"
%else
set -g @catppuccin_flavor "mocha"
%endif

set -g @catppuccin_pane_status_enabled "yes"
set -g @catppuccin_pane_border_status  "yes"

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
set -g @catppuccin_status_background        "#{@thm_bg}" # Sets the background color of the status line.

# Use a value compatible with the standard tmux `menu-selected-style`
set -g @catppuccin_menu_selected_style "fg=#{@thm_surface_0},bg=#{@thm_yellow}"

# Modules settings
set -g @catppuccin_session_icon  " "
set -g @catppuccin_session_color "#{?client_prefix,#{@thm_red},#{@thm_blue}}"

set -g @catppuccin_host_icon  "#{?#{||:#{SSH_CLIENT},#{SSH_TTY}},󰒍 ,󰒋 }"
set -g @catppuccin_host_color "#{?#{||:#{SSH_CLIENT},#{SSH_TTY}},#{@thm_peach},#{@thm_flamingo}}"

set -g @catppuccin_application_icon  " "
set -g @catppuccin_application_color "#{@thm_rosewater}"

set -g @catppuccin_date_time_icon  " "
set -g @catppuccin_date_time_color "#{@thm_overlay_0}"

set -g @sensors_cpu_icon_color "#{@thm_green}"
set -g @sensors_ram_icon_color "#{@thm_teal}"
set -g @sensors_gpu_icon_color "#{@thm_sky}"

if "test -f ~/.config/tmux/plugins/tmux/catppuccin.tmux" \
   "run ~/.config/tmux/plugins/tmux/catppuccin.tmux"

source -F ~/.config/tmux/status/sensors.tmux
source -F ~/.config/tmux/status/starship_directory.tmux
source -F ~/.config/tmux/status/starship_git.tmux

set -g status-left-length  100
set -g status-right-length 200

set -gF status-left ""
set -ga status-left "#{E:@catppuccin_status_host}"
set -ga status-left "#{E:@catppuccin_status_session}"
set -ga status-left "#[fg=#{@thm_fg},bg=#{@thm_bg}] "

set -g status-right ""
set -ga status-right "#{E:@catppuccin_status_application}"
set -ga status-right "#{E:@catppuccin_status_starship_directory}"
set -ga status-right "#{?#{E:@git_branch},#{E:@catppuccin_status_starship_git},}"
set -gaF status-right "#{E:@catppuccin_status_sensors}"
%if "#{TMUX_BATTERY_ENABLED}"
set -gaF status-right "#{E:@catppuccin_status_battery}"
%endif
set -ga status-right "#{E:@catppuccin_status_date_time}"
