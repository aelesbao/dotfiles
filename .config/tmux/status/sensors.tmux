# vim:set ft=tmux:
%hidden MODULE_NAME="sensors"

set -ogq @sensors_main_color "#{@thm_lavender}"

# 󰬹 󰬺 󰬻 󰬼 󰬽 󰬾 󰬿 󰭀 󰭁 󰭂
set -ogq @sensors_format       "%2.0f%%"
set -ogq @sensors_temp_format  "%2.0f"

set -ogq @sensors_low_fg_color    "#{E:@thm_fg}"
set -ogq @sensors_medium_fg_color "#{E:@thm_yellow}"
set -ogq @sensors_high_fg_color   "#{E:@thm_red}"

set -ogq @sensors_low_icon    ""
set -ogq @sensors_medium_icon ""
set -ogq @sensors_high_icon   ""

# ▁ ▂ ▃ ▄ ▅ ▆ ▇ █
# set -ogq @sensors_low_icon    " ▁ "
# set -ogq @sensors_medium_icon " ▄ "
# set -ogq @sensors_high_icon   " ▇ "

# ▏▎▍▌▋▊▉█
# set -ogq @sensors_low_icon    " ▏ "
# set -ogq @sensors_medium_icon " ▌ "
# set -ogq @sensors_high_icon   " ▉ "

set -ogq @sensors_temp_low_icon    "  "
set -ogq @sensors_temp_medium_icon "  "
set -ogq @sensors_temp_high_icon   "  "

set -ogq @sensors_separator "▕"

set -ogq @sensors_cpu_icon_color "#{E:@sensors_main_color}"
set -ogq @sensors_cpu_icon "  󰫰󰫽󰬂 "

set -ogq @sensors_ram_icon_color "#{E:@sensors_main_color}"
set -ogq @sensors_ram_icon "  󰫿󰫮󰫺 "

set -ogq @sensors_gpu_icon_color "#{E:@sensors_main_color}"
set -ogq @sensors_gpu_icon " 󰍹 󰫴󰫽󰬂 "

set -ogq @sensors_gram_icon_color "#{E:@sensors_main_color}"
set -ogq @sensors_gram_icon " 󰢮 󰫴󰫿󰫮󰫺 "

# CPU
set -ogqF @cpu_percentage_format  "#{E:@sensors_format}"

set -ogq @cpu_low_icon        "#{E:@sensors_low_icon}"
set -ogq @cpu_medium_icon     "#{E:@sensors_medium_icon}"
set -ogq @cpu_high_icon       "#{E:@sensors_high_icon}"

set -ogq @cpu_low_fg_color    "#{E:@sensors_low_fg_color}"
set -ogq @cpu_medium_fg_color "#{E:@sensors_medium_fg_color}"
set -ogq @cpu_high_fg_color   "#{E:@sensors_high_fg_color}"

set -ogq @cpu_low_bg_color    "#{E:@catppuccin_status_module_text_bg}"
set -ogq @cpu_medium_bg_color "#{E:@catppuccin_status_module_text_bg}"
set -ogq @cpu_high_bg_color   "#{E:@catppuccin_status_module_text_bg}"

# CPU Temperature
set -ogqF @cpu_temp_format        "#{E:@sensors_temp_format}"

set -ogq @cpu_temp_low_icon        "#{E:@sensors_temp_low_icon}"
set -ogq @cpu_temp_medium_icon     "#{E:@sensors_temp_medium_icon}"
set -ogq @cpu_temp_high_icon       "#{E:@sensors_temp_high_icon}"

set -ogq @cpu_temp_low_fg_color    "#{E:@sensors_low_fg_color}"
set -ogq @cpu_temp_medium_fg_color "#{E:@sensors_medium_fg_color}"
set -ogq @cpu_temp_high_fg_color   "#{E:@sensors_high_fg_color}"

set -ogq @cpu_temp_low_bg_color    "#{E:@catppuccin_status_module_text_bg}"
set -ogq @cpu_temp_medium_bg_color "#{E:@catppuccin_status_module_text_bg}"
set -ogq @cpu_temp_high_bg_color   "#{E:@catppuccin_status_module_text_bg}"

# RAM
set -ogqF @ram_percentage_format  "#{E:@sensors_format}"

set -ogq @ram_low_icon        "#{E:@sensors_low_icon}"
set -ogq @ram_medium_icon     "#{E:@sensors_medium_icon}"
set -ogq @ram_high_icon       "#{E:@sensors_high_icon}"

set -ogq @ram_low_fg_color    "#{E:@sensors_low_fg_color}"
set -ogq @ram_medium_fg_color "#{E:@sensors_medium_fg_color}"
set -ogq @ram_high_fg_color   "#{E:@sensors_high_fg_color}"

set -ogq @ram_low_bg_color    "#{E:@catppuccin_status_module_text_bg}"
set -ogq @ram_medium_bg_color "#{E:@catppuccin_status_module_text_bg}"
set -ogq @ram_high_bg_color   "#{E:@catppuccin_status_module_text_bg}"

# GPU
set -ogqF @gpu_percentage_format  "#{E:@sensors_format}"

set -ogq @gpu_low_icon        "#{E:@sensors_low_icon}"
set -ogq @gpu_medium_icon     "#{E:@sensors_medium_icon}"
set -ogq @gpu_high_icon       "#{E:@sensors_high_icon}"

set -ogq @gpu_low_fg_color    "#{E:@sensors_low_fg_color}"
set -ogq @gpu_medium_fg_color "#{E:@sensors_medium_fg_color}"
set -ogq @gpu_high_fg_color   "#{E:@sensors_high_fg_color}"

set -ogq @gpu_low_bg_color    "#{E:@catppuccin_status_module_text_bg}"
set -ogq @gpu_medium_bg_color "#{E:@catppuccin_status_module_text_bg}"
set -ogq @gpu_high_bg_color   "#{E:@catppuccin_status_module_text_bg}"

# GPU Temperature
set -ogqF @gpu_temp_format        "#{E:@sensors_temp_format}"

set -ogq @gpu_temp_low_icon        "#{E:@sensors_temp_low_icon}"
set -ogq @gpu_temp_medium_icon     "#{E:@sensors_temp_medium_icon}"
set -ogq @gpu_temp_high_icon       "#{E:@sensors_temp_high_icon}"

set -ogq @gpu_temp_low_fg_color    "#{E:@sensors_low_fg_color}"
set -ogq @gpu_temp_medium_fg_color "#{E:@sensors_medium_fg_color}"
set -ogq @gpu_temp_high_fg_color   "#{E:@sensors_high_fg_color}"

set -ogq @gpu_temp_low_bg_color    "#{E:@catppuccin_status_module_text_bg}"
set -ogq @gpu_temp_medium_bg_color "#{E:@catppuccin_status_module_text_bg}"
set -ogq @gpu_temp_high_bg_color   "#{E:@catppuccin_status_module_text_bg}"

# GPU RAM
set -ogqF @gram_percentage_format "#{E:@sensors_format}"

set -ogq @gram_low_icon        "#{E:@sensors_low_icon}"
set -ogq @gram_medium_icon     "#{E:@sensors_medium_icon}"
set -ogq @gram_high_icon       "#{E:@sensors_high_icon}"

set -ogq @gram_low_fg_color    "#{E:@sensors_low_fg_color}"
set -ogq @gram_medium_fg_color "#{E:@sensors_medium_fg_color}"
set -ogq @gram_high_fg_color   "#{E:@sensors_high_fg_color}"

set -ogq @gram_low_bg_color    "#{E:@catppuccin_status_module_text_bg}"
set -ogq @gram_medium_bg_color "#{E:@catppuccin_status_module_text_bg}"
set -ogq @gram_high_bg_color   "#{E:@catppuccin_status_module_text_bg}"

# Module settings
set -ogq "@catppuccin_${MODULE_NAME}_icon"  " "
set -ogq "@catppuccin_${MODULE_NAME}_color" "#{E:@sensors_main_color}"

set -gq  "@catppuccin_${MODULE_NAME}_text"  ""

set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{@sensors_cpu_icon_color}]#{@sensors_cpu_icon}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{l:#{cpu_fg_color}}]#{l:#{cpu_icon}}#{l:#{cpu_percentage}}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{l:#{cpu_temp_fg_color}}]#{l:#{cpu_temp_icon}}#{l:#{cpu_temp}}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"

set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{@catppuccin_status_${MODULE_NAME}_icon_bg}]#{@sensors_separator}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{@sensors_ram_icon_color}]#{@sensors_ram_icon}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{l:#{ram_fg_color}}]#{l:#{ram_icon}}#{l:#{ram_percentage}}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"

set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{@catppuccin_status_${MODULE_NAME}_icon_bg}]#{@sensors_separator}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{@sensors_gpu_icon_color}]#{@sensors_gpu_icon}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{l:#{gpu_fg_color}}]#{l:#{gpu_icon}}#{l:#{gpu_percentage}}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{l:#{gpu_temp_fg_color}}]#{l:#{gpu_temp_icon}}#{l:#{gpu_temp}}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"

set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{@catppuccin_status_${MODULE_NAME}_icon_bg}]#{@sensors_separator}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{@sensors_gram_icon_color}]#{@sensors_gram_icon}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"
set -gaq "@catppuccin_${MODULE_NAME}_text"  "#[fg=#{l:#{gram_fg_color}}]#{l:#{gram_icon}}#{l:#{gram_percentage}}#[fg=#{@catppuccin_status_${MODULE_NAME}_text_fg}]"

source -F "#{d:current_file}/../plugins/tmux/utils/status_module.conf"
