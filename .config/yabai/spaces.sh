#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

# display 1
yabai -m space 1 --label email
yabai -m space 2 --label slack
yabai -m space 3 --label personal
yabai -m space 4 --label chat

# display 2
if has_display "$samsung_odyssey_full"; then
    echo "Configuring spaces with external monitor"

    yabai -m space 5 --label planning
    yabai -m space 6 --label philabs-browsing
    yabai -m space 7 --label philabs-work
    yabai -m space 8 --label dotfiles
    yabai -m space 9 --label home-lab
    yabai -m space 10 --label research

    yabai -m space planning --balance
    yabai -m space research --balance
else
    echo "Configuring spaces without external monitor"

    yabai -m space 5 --label philabs-browsing
    yabai -m space 6 --label philabs-work
    yabai -m space 7 --label dotfiles
    yabai -m space 8 --label home-lab
    yabai -m space 9 --label research
fi

yabai -m config --space personal layout stack
yabai -m config --space chat layout stack
