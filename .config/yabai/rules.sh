#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

# cleanup existing rules first
for i in $(yabai -m rule --list | jq -r '.[] | .index' | sort -n -r); do
    yabai -m rule --remove "$i";
done

add_rule() {
    app="$1"; shift
    yabai -m rule --add app="^$app$" "${@}"
}

add_rule_manage_off() {
    apps=""
    for app in "$@"; do
        apps="$apps$app|"
    done

    apps="${apps%?}"
    add_rule "($apps)" manage=off
}

# Set all windows layer to normal
yabai -m rule --add app=".*" sub-layer="normal"

# don't manage specific apps
add_rule_manage_off \
    "Bartender 5" \
    "BetterTouchTool" \
    "Caffeine" \
    "Calculator" \
    "DaisyDisk" \
    "Digital Color Meter" \
    "Irvue" \
    "iStat Menus" \
    "JetBrains Toolbox" \
    "Karabiner-Elements" \
    "QuickTime Player" \
    "Raycast" \
    "System Settings" \
    "1Password" \
    "NordVPN"

# fixed spaces
add_rule "Telegram" space="chat"
add_rule "WhatsApp" space="chat"
add_rule "Messages" space="chat"
add_rule "Spotify" space="chat"

add_rule "Calendar" space="planning"
add_rule "Todoist" space="planning"
add_rule "Linear" space="planning"

add_rule "Brave Browser" title="^(dotfiles).*" space="dotfiles"
add_rule "Brave Browser" title="^(Share the Pi).*" space="dotfiles"
add_rule "Brave Browser" title="^(Home Lab|Trading).*" space="home-lab"
add_rule "Brave Browser" title="^(VISA|Legal|Kitas).*" space="research"

add_rule "Brave Browser" title="^(Work in Progress).*" space="philabs-work"

add_rule "Brave Browser" title="^(Google Meet).*" display=1

# Fix some pop-ups
add_rule "Brave Browser" title="^(MetaMask|Keplr|Leap Cosmos Wallet|Station Wallet).*" manage=off

# Always show notification centre above all windows
add_rule "(Notification Cent.*|Raycast)" sub-layer="above"

# Always show calendar sub-windows above other windows
add_rule "Calendar" title!="^Calendar$" manage=off sub-layer="above"

# open a few apps in fullscreen by default
add_rule "^(Mimestream|Slack)$" display=1 native-fullscreen=on

# Set all windows layer to normal
yabai -m signal --add \
    label="windows-layer-normal-switched" \
    event="application_front_switched" \
    app="^Brave Browser$" \
    action="yabai -m window --sub-layer normal"
yabai -m signal --add \
    label="windows-layer-normal-created" \
    event="window_created" \
    app="^Brave Browser$" \
    action="yabai -m window --sub-layer normal"
yabai -m signal --add \
    label="windows-layer-normal-focused" \
    event="window_focused" \
    app="^Brave Browser$" \
    action="yabai -m window --sub-layer normal"
