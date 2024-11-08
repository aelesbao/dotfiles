#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

. "$SCRIPT_DIR/util.sh"

# cleanup existing rules first
for i in $(yabai -m rule --list | jq -r '.[] | .index' | sort -n -r); do
    yabai -m rule --remove "$i";
done

add_rule() {
    yabai -m rule --add "${@}"
}

add_app_rule() {
    app="$1"; shift
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
    "iStat Menus"

# fixed spaces
add_app_rule "Telegram" space="chat"
add_app_rule "WhatsApp" space="chat"
add_app_rule "Messages" space="chat"
add_app_rule "Spotify" space="chat"

add_app_rule "Calendar" space="planning"
add_app_rule "Todoist" space="planning"
add_app_rule "Linear" space="planning"

add_app_rule "Brave Browser" title="^(dotfiles).*" space="dotfiles"
add_app_rule "Brave Browser" title="^(Share the Pi).*" space="dotfiles"
add_app_rule "Brave Browser" title="^(Home Lab|Trading).*" space="home-lab"
add_app_rule "Brave Browser" title="^(VISA|Legal|Kitas).*" space="research"

add_app_rule "Brave Browser" title="^(Work in Progress).*" space="philabs-work"

add_app_rule "Brave Browser" title="^(Google Meet).*" display=1

# Fix browser pop-ups
add_app_rule "(Brave Browser|Firefox|Arc)" title="^(MetaMask|Keplr|Leap Cosmos Wallet|Station Wallet|Phantom Wallet|Sui Wallet).*" manage=off
add_app_rule "Arc" title="^(Profile).*" manage=off

# IDEs
add_app_rule "(RustRover|GoLand|PyCharm|IntelliJ|Visual Studio|Neovide|Zed)" display=2
add_app_rule "(RustRover|GoLand|PyCharm|IntelliJ)" \
    title="^.*(Settings|Shortcut|Module|Delete|Signature|Inline|Refactor|Inspect|Build|Plugin|Rename|Member).*" \
    manage=off

# Always show notification center (or centre) above all windows
add_app_rule "(Notification Cent.*|Raycast)" sub-layer="above"

# Always show calendar sub-windows above other windows
add_app_rule "Calendar" title!="^Calendar$" manage=off sub-layer="above"

# open a few apps in fullscreen by default
add_app_rule "^(Mimestream|Slack)$" display=1 native-fullscreen=on

# Set non-resizable windows as floating
# shellcheck disable=SC2016
yabai -m signal --add \
    label="float-non-resizable-window" \
    event="window_created" \
    action='yabai -m query --windows --window \
        | jq -e ".\"can-resize\" == false and .\"is-floating\" == false" >/dev/null \
        && yabai -m window --toggle float'

# Set all Brave windows' layer to normal
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
