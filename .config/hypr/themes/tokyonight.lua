-- Tokyo Night color overrides. Required last, so it wins over conf.d/.
--
-- Modified from https://github.com/HyDE-Project/hyde-themes/blob/Tokyo-Night/Configs/.config/hyde/themes/Tokyo%20Night/hypr.theme

local c = require("lib.colors")

-- GTK/icon theming, disabled. Was a set of `exec = gsettings set ...` lines:
--   org.gnome.desktop.interface icon-theme    candy-icons
--   org.gnome.desktop.interface gtk-theme     Tokyonight-Purple-Dark
--   org.gnome.desktop.interface color-scheme  prefer-dark

local accent = { colors = { c.color5, c.color6 }, angle = 45 }
local accent_dim = { colors = { c.color5_alpha5, c.color6_alpha5 }, angle = 45 }

hl.config({
  misc = {
    background_color = c.background,
  },

  general = {
    col = {
      active_border = accent,
      inactive_border = accent_dim,
    },
  },

  group = {
    col = {
      border_active = accent,
      border_inactive = accent_dim,
      border_locked_active = accent,
      border_locked_inactive = accent_dim,
    },

    groupbar = {
      text_color = c.foreground,
      text_color_inactive = c.foreground_alpha6,
      text_color_locked_active = c.color11,
      text_color_locked_inactive = c.color11_alpha6,

      col = {
        active = c.color0_alpha8,
        inactive = c.background_alpha2,
        locked_active = c.color0_alpha8,
        locked_inactive = c.background_alpha2,
      },
    },
  },

  decoration = {
    -- Only visible if decoration.shadow.enabled is turned back on.
    shadow = {
      color = c.background_alpha8,
    },
  },
})
