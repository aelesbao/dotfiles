has_display() {
    display_query="$1"
    yabai -m query --displays | jq -e "$display_query"
}

has_external_display() {
    has_display 'length > 1'
}

has_fullhd_display() {
    has_display 'map(.frame.w == 1920.0000) | any'
}

has_uwfhd_display() {
    has_display 'map(.frame.w == 2560.0000) | any'
}

has_ultrawide_display() {
    has_display 'map(.frame.w == 5120.0000) | any'
}

is_system_protection_disabled() {
    csrutil status | grep -q "disabled"
}
