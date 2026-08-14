-- Tokyo Night palette (was vars/colors.conf).
--
-- Hex is the single source of truth. Every ramped color gets an `_alpha1..9`
-- variant, which used to be 181 hand-written lines. Mirrored back into
-- hyprlang form by scripts/gen-hyprlang-vars, because hyprlock.conf still
-- sources vars/colors.conf.
--
-- Modified from https://github.com/HyDE-Project/hyde-themes/blob/Tokyo-Night/Configs/.config/hyde/themes/Tokyo%20Night/hypr.theme

local M = {}

-- Ordered so the generated vars/colors.conf keeps its original layout.
M.ramped = {
  { "color0", "24283B" },
  { "color1", "F7768E" },
  { "color2", "73DACA" },
  { "color3", "E0AF68" },
  { "color4", "7AA2F7" },
  { "color5", "BB9AF7" },
  { "color6", "2AC3DE" },
  { "color7", "9AA5CE" },
  { "color8", "414868" },
  { "color9", "FF9E64" },
  { "color10", "9ECE6A" },
  { "color11", "FABA4A" },
  { "color12", "92B2F7" },
  { "color13", "C7A9FF" },
  { "color14", "7DCFFF" },
  { "color15", "A9B1D6" },
  { "background", "1A1B26" },
  { "foreground", "C0CAF5" },
}

-- No alpha ramp; only ever used opaque.
M.cursor_hex = "CFC9C2"

--- "24283B" -> 36, 40, 59
local function unpack_hex(hex)
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

--- Opaque `rgb(r,g,b)`, the form Hyprland and hyprlock both accept.
local function rgb(hex)
  return string.format("rgb(%d,%d,%d)", unpack_hex(hex))
end

--- `rgba(RRGGBBAA)` at step/10 opacity. Steps 1..9 round half up, giving the
--- byte sequence 1A 33 4D 66 80 99 B3 CC E6.
local function rgba(hex, step)
  return string.format("rgba(%s%02X)", hex, math.floor(step * 25.5 + 0.5))
end

--- Flat name -> value map, in the order the hyprlang file declared them.
--- `list` preserves order; `map` is for lookups.
function M.vars()
  local list = { { "cursor", rgb(M.cursor_hex) } }
  local map = { cursor = list[1][2] }

  for _, entry in ipairs(M.ramped) do
    local name, hex = entry[1], entry[2]
    list[#list + 1] = { name, rgb(hex), hex }
    map[name] = rgb(hex)

    for step = 1, 9 do
      local alpha_name = name .. "_alpha" .. step
      list[#list + 1] = { alpha_name, rgba(hex, step) }
      map[alpha_name] = rgba(hex, step)
    end
  end

  return list, map
end

-- `c.color5`, `c.background_alpha8`, ... for use in the rest of the config.
local _, map = M.vars()
for name, value in pairs(map) do
  M[name] = value
end

return M
