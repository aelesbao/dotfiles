#!/usr/bin/env zsh

# Extract the summary and body from the dunst notification
# format: #<human readable> (<summary>)[<id>,<action>]
dunst_pattern="#\(.*\) (\(.*\)) \[\([0-9]*\),\(.*\)\]"

read -d '' -r args

summary="$(echo "$args" | sed -e ':a' -e '$!{N;ba' -e "}; s/${dunst_pattern}/\2/")"

for line in ${(f)args}; do
  display="$(echo "$line" | sed 's/'${dunst_pattern}'/\1/')"
  echo -en "${line}\0display\x1f${display}\n"
done | rofi -dmenu -theme dunst -window-title dunst -sync -mesg "$summary"
