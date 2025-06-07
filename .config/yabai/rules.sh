#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

# cleanup existing rules first
for i in $(yabai -m rule --list | jq -r '.[] | .index' | sort -n -r); do
    yabai -m rule --remove "$i"
done

add_rule() {
    yabai -m rule --add "${@}"
}

add_app_rule() {
    app="$1"
    shift
    yabai -m rule --add app="^$app$" "${@}"
}

add_app_rule_manage_off() {
    apps=""
    for app in "$@"; do
        apps="$apps$app|"
    done

    apps="${apps%?}"
    add_app_rule "($apps)" manage=off
}

# Set all windows layer to normal
add_rule app=".*" sub-layer="normal"

# don't manage specific apps
add_app_rule_manage_off \
    "1Password" \
    "Bartender 5" \
    "BetterTouchTool" \
    "Caffeine" \
    "Calculator" \
    "DaisyDisk" \
    "Digital Color Meter" \
    "Irvue" \
    "JetBrains Toolbox" \
    "Karabiner-Elements" \
    "NordVPN" \
    "OneCast" \
    "QuickTime Player" \
    "Raycast" \
    "System Settings" \
    "balenaEtcher" \
    "iStat Menus" \
    "gcups"

# fixed spaces
add_app_rule "(Messages|Signal|Telegram|WhatsApp)" space="comms"
add_app_rule "Spotify" space="comms"

add_app_rule "Obsidian" space="personal"
add_app_rule "^(Calendar|Todoist|Linear)$" space="personal"
# add_app_rule "^(Calendar|Todoist|Linear)$" space="planning"

# fix browser pop-ups
add_app_rule "(Brave Browser|Firefox|Arc)" \
    title="^(Litle Arc - )?(MetaMask|Keplr|Leap Cosmos Wallet|Station Wallet|Phantom Wallet|Sui Wallet|Slush).*" manage=off
add_app_rule "Arc" title="^(Profile).*" manage=off

# development
add_app_rule "Alacritty|Kity|Ghostty" space="development"
add_app_rule "(RustRover|GoLand|PyCharm|IntelliJ|Visual Studio|Neovide|Zed)" space="development"
add_app_rule "(RustRover|GoLand|PyCharm|IntelliJ)" \
    title="^.*(Settings|Shortcut|Module|Delete|Signature|Inline|Refactor|Inspect|Build|Plugin|Rename|Member).*" \
    manage=off

# always show notification center (or centre) above all windows
add_app_rule "(Notification Cent.*|Raycast)" sub-layer="above"

# always show calendar sub-windows above other windows
add_app_rule "Calendar" title!="^Calendar$" manage=off sub-layer="above"

# open a few apps in fullscreen by default
add_app_rule "^(Mimestream)$" display="macbook" native-fullscreen=on
add_app_rule "^(Slack)$" title="^Huddle:.*$" display="macbook" native-fullscreen=off

# set non-resizable windows as floating
# shellcheck disable=SC2016
yabai -m signal --add \
    label="float-non-resizable-window" \
    event="window_created" \
    action='yabai -m query --windows --window \
        | jq -e ".\"can-resize\" == false and .\"is-floating\" == false" >/dev/null \
        && yabai -m window --toggle float'

# set all Brave windows' layer to normal
yabai -m signal --add \
    label="brave-layer-normal-switched" \
    event="application_front_switched" \
    app="^Brave Browser$" \
    action="yabai -m window --sub-layer normal"
yabai -m signal --add \
    label="brave-layer-normal-created" \
    event="window_created" \
    app="^Brave Browser$" \
    action="yabai -m window --sub-layer normal"
yabai -m signal --add \
    label="brave-layer-normal-focused" \
    event="window_focused" \
    app="^Brave Browser$" \
    action="yabai -m window --sub-layer normal"
