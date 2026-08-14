-- Regenerates the hyprlang vars/ files from the Lua palette and font tables.
--
-- Called on every config load from hyprland.lua so the two can never drift, and
-- runnable standalone via scripts/gen-hyprlang-vars (which is what the yadm
-- bootstrap uses, so a fresh machine can lock its screen before Hyprland has
-- ever started).

local colors = require("lib.colors")
local fonts = require("lib.fonts")
local hyprlang = require("lib.hyprlang")

local M = {}

--- Directory holding hyprland.lua.
local function default_dir()
  local xdg = os.getenv("XDG_CONFIG_HOME")
  if xdg and xdg ~= "" then
    return xdg .. "/hypr"
  end
  return os.getenv("HOME") .. "/.config/hypr"
end

---@param dir? string  defaults to $XDG_CONFIG_HOME/hypr
---@return boolean ok, string? err
function M.generate(dir)
  dir = dir or default_dir()

  local entries = {}
  for _, entry in ipairs(select(1, colors.vars())) do
    local name, value, hex = entry[1], entry[2], entry[3]
    -- Bases carry a hex heading; their alpha variants follow underneath.
    entries[#entries + 1] = { name, value, hex and (name .. ": #" .. hex) or nil }
  end

  local ok, err = hyprlang.write_vars(dir .. "/vars/colors.conf", entries, "lib/colors.lua")
  if not ok then
    return false, err
  end

  return hyprlang.write_vars(dir .. "/vars/fonts.conf", {
    { "font_mono", fonts.mono },
    { "font_ui", fonts.ui },
  }, "lib/fonts.lua")
end

return M
