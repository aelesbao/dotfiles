-- Voxtype compositor integration
-- Fixes modifier key interference when using compositor keybindings
-- Ported from the output of: voxtype setup compositor hyprland
--
-- Four submaps are defined:
-- - voxtype:recording   - active during recording/transcription. F12 cancels.
-- - voxtype:transcoding - active during text output. Blocks modifier keys.
-- - voxtype:clipboard, voxtype:type - unreachable from this config; both entry
--   binds below go to voxtype:recording. Kept because voxtype may enter them
--   itself via `hyprctl dispatch`.
--
-- NOTE: Do not bind Escape in voxtype:transcoding. Binding Escape causes wtype's
-- first character to be dropped. See: https://github.com/hyprwm/Hyprland/issues/3165

local mods = require("lib.mods")

--- Cancel and leave the submap. Was two hyprlang binds on the same key.
local function cancel()
  hl.dispatch(hl.dsp.exec_cmd("voxtype record cancel"))
  hl.dispatch(hl.dsp.submap("reset"))
end

-- Record to clipboard
hl.bind("XF86Eject", function()
  hl.dispatch(hl.dsp.exec_cmd("voxtype record start --clipboard"))
  hl.dispatch(hl.dsp.submap("voxtype:recording"))
end)

-- Record and type
hl.bind(mods.mod .. " + XF86Eject", function()
  hl.dispatch(hl.dsp.exec_cmd("voxtype record start --type"))
  hl.dispatch(hl.dsp.submap("voxtype:recording"))
end)

hl.define_submap("voxtype:clipboard", function()
  hl.bind("XF86Eject", hl.dsp.exec_cmd("voxtype record stop"), { release = true })
  hl.bind("F12", cancel)
end)

hl.define_submap("voxtype:type", function()
  hl.bind("XF86Eject", hl.dsp.exec_cmd("voxtype record stop"), { release = true })
  hl.bind(mods.mod .. " + XF86Eject", hl.dsp.exec_cmd("voxtype record stop"), { release = true })
  hl.bind("F12", cancel)
  hl.bind(mods.mod .. " + F12", cancel)
end)

-- Recording submap - active during recording and transcription
-- F12 cancels recording/transcription and returns to normal
hl.define_submap("voxtype:recording", function()
  hl.bind("XF86Eject", hl.dsp.exec_cmd("voxtype record stop"), { release = true })
  hl.bind(mods.mod .. " + XF86Eject", hl.dsp.exec_cmd("voxtype record stop"), { release = true })
  hl.bind("F12", cancel)
  hl.bind(mods.mod .. " + F12", cancel)
end)

-- Output submap - blocks modifier keys during text output
hl.define_submap("voxtype:transcoding", function()
  for _, key in ipairs({
    "SUPER_L",
    "SUPER_R",
    "Control_L",
    "Control_R",
    "Alt_L",
    "Alt_R",
    "Shift_L",
    "Shift_R",
  }) do
    hl.bind(key, hl.dsp.exec_cmd("true"))
  end

  hl.bind("F12", cancel) -- Emergency escape if voxtype crashes
end)
