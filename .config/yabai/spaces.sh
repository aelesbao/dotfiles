#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

move_to_space() {
    local app_name="$1"
    local space_number="$2"

    idx_space="$(get_app_window "$app_name" | jq -er '.space')"
    if [ -n "$idx_space" ] && [ "$idx_space" != "$space_number" ]; then
        yabai -m window "$(get_app_window "$app_name" | jq -r '.id')" \
            --space "$space_number" \
            --toggle native-fullscreen
    fi
}

move_to_space "Mimestream" 1
move_to_space "Slack" 1

# display 1
yabai -m space 1 --label email --display "macbook"
yabai -m space 2 --label slack --display "macbook"
yabai -m space 3 --label personal --display "macbook"

# display 2
if has_external_display; then
    echo "Configuring spaces with external monitor"

    yabai -m space 4 --label comms --display "macbook"
    yabai -m space 5 --label development

    yabai -m config --space personal layout stack
    yabai -m config --space comms layout stack
    # yabai -m config --space planning auto_balance on
else
    echo "Configuring spaces without external monitor"

    yabai -m space 4 --label development
    yabai -m space 5 --label comms
fi
