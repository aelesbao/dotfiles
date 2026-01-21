Name = "wallpapers"
NamePretty = "Wallpapers"
Description = "Set wallpaper using hyprpaper"
Icon = "desktop"
Cache = true
HideFromProviderlist = false
SearchName = true
Action = "hyprctl hyprpaper wallpaper ,'%VALUE%'"

function GetEntries()
  local home = os.getenv("HOME")
  local wallpaper_dir = home .. "/.local/share/wallpapers"

  local handle = io.popen(
    "find '"
    .. wallpaper_dir
    ..
    "' -maxdepth 1 -type f -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.gif' -o -name '*.bmp' -o -name '*.webp' 2>/dev/null"
  )
  if not handle then
    return {}
  end

  local entries = {}

  for line in handle:lines() do
    local filename = line:match("([^/]+)$")
    if filename then
      table.insert(entries, {
        Text = filename,
        Value = line,
        Preview = line,
        PreviewType = "file",
      })
    end
  end
  handle:close()

  return entries
end
