#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

# idx_email_space="$(yabai query --windows | jq -r '.[] | select(.app == "Mimestream") | .space')"
# idx_slack_space="$(yabai query --windows | jq -r '.[] | select(.app == "Slack") | .space')"

# display 1
yabai -m space 1 --label email
yabai -m space 2 --label slack
yabai -m space 3 --label personal
yabai -m space 4 --label comms

# display 2
if has_external_display; then
    echo "Configuring spaces with external monitor"

    yabai -m space 5 --label planning
    yabai -m space 6 --label browsing
    yabai -m space 7 --label work

    yabai -m config --space personal layout stack
    yabai -m config --space comms layout stack
    yabai -m config --space planning auto_balance on
else
    echo "Configuring spaces without external monitor"

    yabai -m space 5 --label browsing
    yabai -m space 6 --label work
fi
