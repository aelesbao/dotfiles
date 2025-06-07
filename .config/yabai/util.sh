query_displays() {
    display_query="$1"
    yabai -m query --displays | jq -re "$display_query" 1> /dev/null
}

has_external_display() {
    query_displays 'length > 1'
}

has_fullhd_display() {
    query_displays 'map(.frame.w == 1920.0000) | any'
}

has_uwfhd_display() {
    query_displays 'map(.frame.w == 2560.0000) | any'
}

has_ultrawide_display() {
    query_displays 'map(.frame.w == 5120.0000) | any'
}

get_ultrawide_display() {
    query_displays '.[] | select(.frame.w == 5120.0000) | .index'
}

get_app_window() {
    app_name="$1"
    yabai -m query --windows | jq -e --arg app_name "$app_name" '.[] | select(.app == $app_name)'
}

is_system_protection_disabled() {
    csrutil status | grep -q "disabled"
}
