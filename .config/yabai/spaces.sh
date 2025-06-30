#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

fullscreen_space() {
    app_name="$1"
    target_space="$2"

    echo "Configuring $app_name on fullscreen space $target_space"

    window_space="$(get_app_window "$app_name" | jq -er '.space')"
    if [ -n "$window_space" ] && [ "$window_space" != "$target_space" ]; then
        window_id="$(get_app_window "$app_name" | jq -r '.id')"

        if ! get_app_window "$app_name" | jq -er '."is-native-fullscreen"' 1>/dev/null; then
            yabai -m window "$window_id" --toggle native-fullscreen
        fi

        sleep 1

        new_window_space="$(get_app_window "$app_name" | jq -er '.space')"
        echo "Current space for $app_name: $new_window_space, moving to space $target_space"
        yabai -m space "$new_window_space" --move "$target_space"
    fi
}

fullscreen_space "Mimestream" 1
fullscreen_space "Slack" 2

# display 1
yabai -m space 1 --label email --display "macbook"
yabai -m space 2 --label slack --display "macbook"
yabai -m space 3 --label personal --display "macbook"

# display 2
if has_external_display; then
    echo "Configuring spaces with external monitor"

    yabai -m space 4 --label comms --display "macbook"
    yabai -m space 5 --label development --display "external"

    yabai -m config --space personal layout stack
    yabai -m config --space comms layout stack
    # yabai -m config --space planning auto_balance on
else
    echo "Configuring spaces without external monitor"

    yabai -m space 4 --label development
    yabai -m space 5 --label comms
fi
