Name = "nerd-fonts"
NamePretty = "Nerd Fonts"
Description = "Search for Nerd Fonts glyphs"
Placeholder = "Glyph name..."
Keywords = { "nerd", "fonts", "glyph", "emoji", "unicode", "icon" }
Icon = ""
Cache = true
HideFromProviderlist = false
SearchName = true
Match = "Fuzzy"
Action = "wl-copy %VALUE%"

function GetEntries()
  local entries = {}

  -- Build path to JSON file using XDG config home
  -- source: https://raw.githubusercontent.com/ryanoasis/nerd-fonts/refs/tags/v3.4.0/glyphnames.json
  local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
  local json_file = config_home .. "/elephant/menus/nerd-fonts-glyphs.json"

  -- Read the JSON file
  local handle = io.open(json_file, "r")
  if not handle then
    return entries
  end

  local content = handle:read("*a")
  handle:close()

  -- Parse JSON
  local glyphs = jsonDecode(content)
  if not glyphs then
    return entries
  end

  -- Iterate over glyphs, filtering out METADATA
  for name, data in pairs(glyphs) do
    if name ~= "METADATA" then
      table.insert(entries, {
        Text = name,
        Subtext = "U+" .. string.upper(data.code),
        Value = data.char,
        Icon = data.char,
      })
    end
  end

  return entries
end
