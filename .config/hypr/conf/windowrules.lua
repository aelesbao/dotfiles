-- See https://wiki.hyprland.org/Configuring/Window-Rules/
--
-- ORDER MATTERS. Rules that assign tags (`tag = "+browser"`) must come before
-- rules that match on them (`match = { tag = "browser" }`). All rules here are
-- anonymous; naming any of them would promote it ahead of the rest, since
-- Hyprland evaluates every named rule before any anonymous one.
--
-- Patterns are RE2 regexes, not Lua patterns, so they are written as long
-- strings and passed through verbatim.

-- Smart gaps
hl.window_rule({ match = { workspace = "f[1]", float = true }, border_size = 0, rounding = 0 })

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ match = { class = [[.*]] }, suppress_event = "maximize" })

-- Allows size persistence between application launches for floating windows
hl.window_rule({ match = { float = true }, persistent_size = true })

-- Floating apps
hl.window_rule({ match = { class = "1password" }, float = true })
hl.window_rule({ match = { class = "evolution-alarm-notify" }, float = true })
hl.window_rule({ match = { class = "blueman-applet" }, float = true })
hl.window_rule({ match = { class = "re.sonny.Junction" }, float = true })
hl.window_rule({ match = { class = "gcm-picker" }, float = true })
hl.window_rule({ match = { class = "org.gnome.Calculator" }, float = true })
hl.window_rule({ match = { class = "io.github.aelesbao.Kairo" }, float = true })

-- Browser
hl.window_rule({ match = { initial_class = [[^(brave-|firefox)(.*)$]] }, tag = "+browser" })
hl.window_rule({
  match = { initial_title = [[^(MetaMask|Keplr|Phantom Wallet|Slush)(.*)$]], tag = "browser" },
  float = true,
})

-- Email
hl.window_rule({ match = { class = [[^(Mailspring|me.proton.Mail|org.gnome.Evolution)]] }, tag = "+email" })

-- Games
hl.window_rule({ match = { initial_class = [[^(steam_.*)$]] }, content = "game", tag = "+game" })
hl.window_rule({ match = { initial_class = [[^(steam|net.lutris.Lutris)$]] }, tag = "+game" })
hl.window_rule({ match = { class = "steam", title = [[(Steam Settings)]] }, float = true })
-- hl.window_rule({ match = { content = "game" }, tag = "+game" })
hl.window_rule({ match = { tag = "game" }, workspace = "6", immediate = true })

-- Terminal
hl.window_rule({
  match = { class = [[^(com.mitchellh.ghostty|kitty|alacritty|foot|wezterm|org.gnome.Terminal)]] },
  tag = "+term",
})
hl.window_rule({ match = { tag = "term" }, no_blur = true, opaque = true })

-- Media
hl.window_rule({ match = { class = [[^([Ss]potify|de.haeckerfelix.Shortwave|vlc|mpv)$]] }, tag = "+media" })
-- hl.window_rule({ match = { content = "video" }, tag = "+media" })
hl.window_rule({ match = { tag = "media" }, workspace = "special:media" })

-- Communication
hl.window_rule({ match = { class = [[^(signal|org.telegram.desktop|ferdium)]] }, tag = "+comms" })
hl.window_rule({ match = { tag = "comms" }, workspace = "special:comms" })
hl.window_rule({ match = { class = "signal", title = [[(Signal Desktop Preferences)]] }, float = true })

hl.window_rule({ match = { class = [[^(discord)]] }, workspace = "special:discord" })

-- Fix pinentry losing focus
hl.window_rule({ match = { class = [[(pinentry-)(.*)]] }, stay_focused = true, pin = true })
hl.window_rule({
  match = { class = "1password", title = [[(Quick Access)(.*)]] },
  stay_focused = true,
  pin = true,
})
-- Secure input
hl.window_rule({ match = { class = [[^(pinentry-.*|1password)]] }, no_screen_share = true })

-- Fix some dragging issues with XWayland
hl.window_rule({
  match = {
    float = true,
    fullscreen = false,
    pin = false,
    class = [[^$]],
    title = [[^$]],
    xwayland = true,
  },
  no_focus = true,
})

-- Initial workspace
hl.window_rule({ match = { class = "org.gnome.Calendar" }, workspace = "1" })
hl.window_rule({ match = { tag = "email" }, workspace = "1" })
hl.window_rule({ match = { class = [[^(Todoist)]] }, workspace = "1" })
hl.window_rule({
  match = { title = [[(Personal|Taxes|Home Lab|Crypto|Shopping)]], tag = "browser" },
  workspace = "2",
})
hl.window_rule({ match = { class = "obsidian" }, workspace = "2" })
hl.window_rule({ match = { title = "Development", tag = "browser" }, workspace = "3" })
hl.window_rule({ match = { tag = "term" }, workspace = "3" })
hl.window_rule({ match = { class = [[[Ss]lack]] }, workspace = "4" })
hl.window_rule({ match = { title = [[(Job Search|Interviews)]], tag = "browser" }, workspace = "4" })

-- Groups
hl.window_rule({ match = { tag = "email" }, group = "set lock invade" })
hl.window_rule({
  match = { title = [[(Personal|Taxes|Home Lab|Crypto|Shopping)]], tag = "browser" },
  group = "set lock invade",
})
