-- See https://wiki.hyprland.org/Configuring/Binds/
-- See https://wiki.hyprland.org/Configuring/Dispatchers/
--
-- Bind options (were the hyprlang bind flag letters):
--   locked           l -> will also work when an input inhibitor (e.g. a lockscreen) is active.
--   release          r -> will trigger on release of a key.
--   click            c -> triggers on release as long as the cursor stays inside binds.drag_threshold.
--   drag             g -> triggers on release as long as the cursor moves outside binds.drag_threshold.
--   long_press       o -> will trigger on long press of a key.
--   repeating        e -> will repeat when held.
--   non_consuming    n -> key/mouse events are passed to the active window in addition to the dispatcher.
--   mouse            m -> for interactive move/resize drags.
--   transparent      t -> cannot be shadowed by other binds.
--   ignore_mods      i -> will ignore modifiers.
--   submap_universal s -> active in every submap.
--   description      d -> human-readable description, shown by `hyprctl binds`.
--   dont_inhibit     p -> bypasses the app's requests to inhibit keybinds.

local apps = require("lib.apps")
local mods = require("lib.mods")

--- Resize the active window to a fraction of the monitor.
---
--- Replaces hyprlang's `resizeactive, exact 34% 50%`. hl.dsp.window.resize only
--- accepts pixel counts -- percentages and expression strings are both rejected
--- -- so the fraction is resolved against the active monitor's logical size.
local function resize_to_fraction(width_fraction, height_fraction)
  return function()
    local monitor = hl.get_active_monitor()
    if not monitor then
      return
    end

    hl.dispatch(hl.dsp.window.resize({
      x = math.floor(monitor.width / monitor.scale * width_fraction),
      y = math.floor(monitor.height / monitor.scale * height_fraction),
    }))
  end
end

-- Remove existing bindings
hl.unbind("CONTROL + Q")

-- <apps>

hl.bind(mods.mod .. " + space", hl.dsp.exec_cmd(apps.launcher), { description = "Application launcher" })
hl.bind(mods.mod .. " + SHIFT + space", hl.dsp.exec_cmd(apps.switcher), { description = "Application switcher" })
hl.bind(mods.nav .. " + space", hl.dsp.exec_cmd(apps.emoji), { description = "Icon viewer" })
hl.bind(mods.alt .. " + space", hl.dsp.exec_cmd(apps.calc), { description = "Calculator" })

hl.bind(mods.mod .. " + e", hl.dsp.exec_cmd(apps.file_manager), { description = "File explorer" })
hl.bind(mods.mod .. " + t", hl.dsp.exec_cmd(apps.terminal), { description = "Terminal" })

hl.bind(mods.alt .. " + n", hl.dsp.exec_cmd(apps.notification_history), { description = "Notification History" })
hl.bind(mods.action .. " + n", hl.dsp.exec_cmd(apps.dismiss_notifications), { description = "Dismiss Notifications" })
hl.bind(mods.alt_action .. " + n", hl.dsp.exec_cmd(apps.toggle_dnd), { description = "Toggle DND" })

hl.bind(mods.alt .. " + backslash", hl.dsp.exec_cmd(apps.password_manager), { description = "Opens password manager" })

hl.bind(mods.mod .. " + SHIFT + v", hl.dsp.exec_cmd(apps.clipboard_history), { description = "Clipboard History" })
hl.bind(mods.mod .. " + SHIFT + 4", hl.dsp.exec_cmd(apps.screenshot), { description = "Screenshot" })
hl.bind(mods.mod .. " + SHIFT + 1", hl.dsp.exec_cmd(apps.color_picker), { description = "Color picker" })

-- </apps>

-- <system>

-- Overview binds, disabled. Both need plugins that are not installed; plugin
-- dispatchers are reached via hl.plugin.<name> in Lua, not the old `plugin:name`
-- dispatcher strings.
--   navMod + up   -> hyprexpo expo toggle
--   navMod + down -> Hyprspace overview (plugin is broken)

hl.bind(mods.mod .. " + escape", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock Session" })
hl.bind(mods.nav .. " + Q", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock Session" }) -- macOS muscle memory
hl.bind(mods.nav .. " + backspace", hl.dsp.exec_cmd([[killall wlogout; wlogout -b 6]]), { description = "Logout" })
-- sleep button
--
-- Was a hyprlang keysym combo, `Super_L&Alt_L, XF86Eject&ISO_Next_Group`. That
-- syntax is gone in the Lua API, and the old bind was dead anyway: `hyprctl
-- binds` on the hyprlang config resolved it to modmask=72 with an empty key, so
-- it never fired. Bound here to the combination the laptop's sleep key actually
-- emits (see the keysym notes in the multimedia section below).
hl.bind("SUPER + ALT + XF86Eject", hl.dsp.exec_cmd([[killall wlogout; wlogout -b 6]]), {
  submap_universal = true,
})

-- </system>

-- <workspaces>

-- Navigate through existing workspaces
hl.bind(mods.nav .. " + bracketleft", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mods.nav .. " + bracketright", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind(mods.nav .. " + bracketleft", hl.dsp.exec_cmd("hyprnome -p"))
-- hl.bind(mods.nav .. " + bracketright", hl.dsp.exec_cmd("hyprnome"))

-- Scroll through existing workspaces with mod + mouse scroll
hl.bind(mods.mod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mods.mod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
-- hl.bind(mods.mod .. " + mouse_down", hl.dsp.exec_cmd("hyprnome -p"))
-- hl.bind(mods.mod .. " + mouse_up", hl.dsp.exec_cmd("hyprnome"))

-- Switch workspaces with navMod + [0-9], and move the active window there with
-- actionMod + [0-9]. Key 0 maps to workspace 10.
for i = 1, 10 do
  local key = i % 10
  hl.bind(mods.nav .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mods.action .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Move windows to prev / next workspace
hl.bind(mods.action .. " + bracketleft", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mods.action .. " + bracketright", hl.dsp.window.move({ workspace = "r+1" }))

-- Special workspaces: navMod toggles, actionMod sends the active window there.
for _, entry in ipairs({
  { "s", "media" },
  { "c", "comms" },
  { "d", "discord" },
  { "z", "zen" },
}) do
  local key, name = entry[1], entry[2]
  hl.bind(mods.nav .. " + " .. key, hl.dsp.workspace.toggle_special(name))
  hl.bind(mods.action .. " + " .. key, hl.dsp.window.move({ workspace = "special:" .. name }))
end

-- </workspaces>

-- <windows>

-- Move focus with navMod + vim keys
hl.bind(mods.nav .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mods.nav .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mods.nav .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mods.nav .. " + j", hl.dsp.focus({ direction = "d" }))

-- Move focus with mod. Each of these was two hyprlang binds on the same key;
-- as one closure the dispatches stay ordered and neither can shadow the other.
hl.bind(mods.mod .. " + tab", function()
  hl.dispatch(hl.dsp.window.cycle_next({ next = true }))
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)
hl.bind(mods.mod .. " + SHIFT + tab", function()
  hl.dispatch(hl.dsp.window.cycle_next({ next = false }))
  hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Move window with actionMod + vim keys
hl.bind(mods.action .. " + h", hl.dsp.window.move({ direction = "l", group_aware = true }))
hl.bind(mods.action .. " + l", hl.dsp.window.move({ direction = "r", group_aware = true }))
hl.bind(mods.action .. " + k", hl.dsp.window.move({ direction = "u", group_aware = true }))
hl.bind(mods.action .. " + j", hl.dsp.window.move({ direction = "d", group_aware = true }))

-- Window actions
hl.bind(mods.mod .. " + Q", hl.dsp.window.close(), { description = "Closes the active window" })
hl.bind(mods.action .. " + Q", hl.dsp.window.kill(), { description = "Force quits the current active window" })
hl.bind(mods.action .. " + F", hl.dsp.window.fullscreen(), { description = "Toggle window fullscreen mode" })

-- Dwindle
hl.bind(mods.action .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mods.action .. " + J", hl.dsp.layout("togglesplit"))

-- Floating
hl.bind(mods.action .. " + T", hl.dsp.window.float({ action = "toggle" }))

-- Groups
hl.bind(mods.action .. " + G", hl.dsp.group.toggle())
hl.bind(mods.alt .. " + G", hl.dsp.group.lock_active({ action = "toggle" }))

hl.bind(mods.alt .. " + H", hl.dsp.group.prev())
hl.bind(mods.alt .. " + L", hl.dsp.group.next())

hl.bind(mods.alt_action .. " + H", hl.dsp.group.move_window({ forward = false }))
hl.bind(mods.alt_action .. " + L", hl.dsp.group.move_window({ forward = true }))

-- Move/resize windows with mod + LMB/RMB and dragging
hl.bind(mods.mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mods.mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- </windows>

-- <multimedia>

-- Multimedia keys for volume
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(apps.vol_up), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(apps.vol_down), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(apps.vol_mute), { locked = true, repeating = true })
hl.bind("CONTROL + XF86AudioRaiseVolume", hl.dsp.exec_cmd(apps.vol_mic_up), { locked = true, repeating = true })
hl.bind("CONTROL + XF86AudioLowerVolume", hl.dsp.exec_cmd(apps.vol_mic_down), { locked = true, repeating = true })
hl.bind("CONTROL + XF86AudioMute", hl.dsp.exec_cmd(apps.vol_mic_mute), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(apps.vol_mic_mute), { locked = true, repeating = true })

-- Multimedia keys for LCD brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(apps.bright_up), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(apps.bright_down), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(apps.player_next), { locked = true })
hl.bind("SHIFT + XF86AudioNext", hl.dsp.exec_cmd(apps.player_forward))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(apps.player_previous), { locked = true })
hl.bind("SHIFT + XF86AudioPrev", hl.dsp.exec_cmd(apps.player_rewind))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(apps.player_play), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(apps.player_pause), { locked = true })

-- XF86Eject + NoSymbol = Eject
-- XF86Tools = F13
-- XF86Launch5 = BrightnessDown = F14
-- XF86Launch6 = BrightnessUp = F15
-- XF86Eject + Alt_L + Super_L + ISO_Next_Group = Sleep

-- </multimedia>

-- <submaps>

--- Resize Mode
hl.bind(mods.action .. " + R", hl.dsp.submap("resize"), { description = "Resize Mode" })

hl.define_submap("resize", function()
  -- prevent any keys from passing to your active application while in a submap
  -- or to exit it immediately when any unknown key is pressed
  -- hl.bind("catchall", hl.dsp.submap("reset"))

  -- sets repeatable binds for resizing the active window
  hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

  hl.bind("h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
  hl.bind("l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
  hl.bind("k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
  hl.bind("j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

  -- hl.bind("SHIFT + left", hl.dsp.layout("splitratio -0.1"), { repeating = true })
  -- hl.bind("SHIFT + right", hl.dsp.layout("splitratio +0.1"), { repeating = true })
  -- hl.bind("SHIFT + h", hl.dsp.layout("splitratio -0.1"), { repeating = true })
  -- hl.bind("SHIFT + l", hl.dsp.layout("splitratio +0.1"), { repeating = true })

  hl.bind("3", resize_to_fraction(0.34, 0.5), { repeating = true })
  hl.bind("5", resize_to_fraction(0.5, 0.5), { repeating = true })
  hl.bind("6", resize_to_fraction(0.66, 0.5), { repeating = true })

  hl.bind("e", hl.dsp.exec_cmd("hyprctl keyword layout:single_window_aspect_ratio 32 9"), {
    description = "Expand single window aspect ratio",
  })
  hl.bind("c", hl.dsp.exec_cmd("hyprctl keyword layout:single_window_aspect_ratio 16 9"), {
    description = "Contract single window aspect ratio",
  })

  hl.bind("escape", hl.dsp.submap("reset"))
end)

hl.bind(mods.alt_action .. " + 3", resize_to_fraction(0.34, 0.5))
hl.bind(mods.alt_action .. " + 5", resize_to_fraction(0.5, 0.5))
hl.bind(mods.alt_action .. " + 6", resize_to_fraction(0.66, 0.5))

--- Service control
-- These were nested under a `servicectl` submap that is commented out in the
-- hyprlang config, which left them globally bound. Keeping that behaviour.
-- hl.bind(mods.action .. " + D", hl.dsp.submap("servicectl"), { description = "Service Control Mode" })

hl.bind(mods.hyper .. " + w", hl.dsp.exec_raw("~/.local/bin/restart-service waybar"), {
  description = "Reload waybar",
})
hl.bind(mods.hyper .. " + n", hl.dsp.exec_raw("~/.local/bin/restart-service swaync"), {
  description = "Reload swaync",
})
hl.bind(mods.hyper .. " + d", hl.dsp.exec_raw("~/.local/bin/hypr-dbgwin"), {
  description = "Debug current window properties",
})

--- Wallpaper Mode
hl.bind(mods.action .. " + W", hl.dsp.submap("wallpaper"), { description = "Wallpaper Mode" })

hl.define_submap("wallpaper", function()
  hl.bind("left", hl.dsp.exec_raw("~/.config/hypr/scripts/hyprpaper-rotate prev"), { repeating = true })
  hl.bind("right", hl.dsp.exec_raw("~/.config/hypr/scripts/hyprpaper-rotate next"), { repeating = true })

  hl.bind("catchall", hl.dsp.submap("reset"))
end)

-- </submaps>

-- <zoom>
-- Long strings keep the shell substitution, pipes and single quotes intact.
hl.bind(
  mods.alt .. " + mouse_down",
  hl.dsp.exec_cmd(
    [[hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq -er '(.float * 1.1) | if . > 2 then 2 else . end')]]
  )
)
hl.bind(
  mods.alt .. " + mouse_up",
  hl.dsp.exec_cmd(
    [[hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq -er '(.float * 0.9) | if . < 1 then 1 else . end')]]
  )
)

hl.bind(mods.alt .. " + 0", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor 1"))
-- KP0 was not a valid keysym and this bind never loaded; the keypad 0 keysym is KP_0.
hl.bind(mods.alt .. " + KP_0", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor 1"))
-- </zoom>
