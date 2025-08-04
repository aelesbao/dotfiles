# vim:set ft=tmux:
%hidden MODULE_NAME="starship_directory"

set -gq @starship_directory_icon "#(starship module -p '#{pane_current_path}' -P '#{pane_current_path}' directory | #{E:@ansi_cleanup} | sed -E 's/^(. )?(.*) $/\\1/' | grep -o '^.')"
set -gq @starship_directory_path "#(starship module -p '#{pane_current_path}' -P '#{pane_current_path}' directory | #{E:@ansi_cleanup} | sed -E 's/^(. )?(.*) $/\\2/')"

set -ogq @catppuccin_starship_directory_icon  "#{?#{E:@starship_directory_icon},#{E:@starship_directory_icon},} "
set -ogq @catppuccin_starship_directory_color "#{@thm_blue}"
set -ogq @catppuccin_starship_directory_text  " #{E:@starship_directory_path}"

source -F "#{d:current_file}/../plugins/tmux/utils/status_module.conf"
