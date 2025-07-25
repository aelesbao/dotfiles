# vim:set ft=tmux:
%hidden MODULE_NAME="starship_git"

set -gq @git_path   "#{?#{||:#{==:#S,dotfiles},#{==:#S,hyprland}},#{HOME}/.local/share/yadm/repo.git,#{pane_current_path}}"
set -gq @git_branch "#(git -C '#{E:@git_path}' rev-parse --abbrev-ref HEAD)"

set -gq @starship_git_commit "#(starship module -p '#{E:@git_path}' -P '#{pane_current_path}' git_commit | #{E:@ansi_to_tmux})"
set -gq @starship_git_status "#(starship module -p '#{E:@git_path}' -P '#{pane_current_path}' git_status | #{E:@ansi_to_tmux})"
set -gq @starship_git_state  "#(starship module -p '#{E:@git_path}' -P '#{pane_current_path}' git_state | #{E:@ansi_to_tmux})"

set -ogq @catppuccin_starship_git_icon  " "
set -ogq @catppuccin_starship_git_color "#{E:@thm_mauve}"
set -gq  @catppuccin_starship_git_text  " #{E:@git_branch} #{E:@starship_git_commit}#{E:@starship_git_status}#{E:@starship_git_state}"

source -F "#{d:current_file}/../plugins/tmux/utils/status_module.conf"
