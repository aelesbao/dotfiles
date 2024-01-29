# shellcheck disable=SC2034
single='length == 1'
# shellcheck disable=SC2034
samsung_odyssey_full='map(.index == 2 and .frame.w == 5120.0000) | any'
# shellcheck disable=SC2034
samsung_odyssey_half='map(.index == 2 and .frame.w == 2560.0000) | any'

has_display() {
    display_query="$1"
    yabai -m query --displays | jq -e "$display_query"
}

is_system_protection_disabled() {
    csrutil status | grep -q "disabled"
}
