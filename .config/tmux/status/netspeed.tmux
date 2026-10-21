# vim:set ft=tmux:
%hidden MODULE_NAME="netspeed"

set -gqF @netspeed_cmd "#{d:current_file}/../scripts/netspeed"

set -ogq @catppuccin_netspeed_icon  "󰛳 "
set -ogq @catppuccin_netspeed_color "#{@thm_lavender}"
set -ogq @catppuccin_netspeed_text  " #(#{E:@netspeed_cmd})"

source -Fq "#{@catppuccin_dir}/utils/status_module.conf"
