#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

idx_email_space="$(get_app_windows "Mimestream" | jq -r '.space')"
if [ -n "$idx_email_space" ] && [ "$idx_email_space" != "1" ]; then
    yabai -m window "$(get_app_windows "Mimestream" | jq -r '.id')" --space 1
fi

idx_slack_space="$(get_app_windows "Slack" | jq -r '.space')"
if [ -n "$idx_slack_space" ] && [ "$idx_slack_space" != "2" ]; then
    yabai -m window "$(get_app_windows "Slack" | jq -r '.id')" --space 2
fi

# display 1
yabai -m space 1 --label email
yabai -m space 2 --label slack
yabai -m space 3 --label personal
yabai -m space 4 --label comms
yabai -m space 5 --label development

# display 2
if has_external_display; then
    echo "Configuring spaces with external monitor"

    yabai -m config --space personal layout stack
    yabai -m config --space comms layout stack
    # yabai -m config --space planning auto_balance on
fi
