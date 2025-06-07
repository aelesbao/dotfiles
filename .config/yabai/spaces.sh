#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

idx_email_space="$(get_app_window "Mimestream" | jq -er '.space')"
if [ -n "$idx_email_space" ] && [ "$idx_email_space" != "1" ]; then
    yabai -m window "$(get_app_window "Mimestream" | jq -r '.id')" --space 1
fi

idx_slack_space="$(get_app_window "Slack" | jq -er '.space')"
if [ -n "$idx_slack_space" ] && [ "$idx_slack_space" != "2" ]; then
    yabai -m window "$(get_app_window "Slack" | jq -r '.id')" --space 2
fi

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
