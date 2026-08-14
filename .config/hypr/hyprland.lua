-- Refer to the wiki for more information.
-- https://wiki.hyprland.org/Configuring/
--
-- Loaded explicitly rather than by glob: hyprlang's `source = ./conf.d/*`
-- expanded alphabetically, which is what made keybindings have to sort before
-- voxtype-submap. Order below is deliberate.
--
-- The directory is `conf/`, not `conf.d/`: Hyprland's require() rewrites both
-- `.` and `/` to path separators, so `conf.d/general` resolves to
-- `conf/d/general.lua` and a dotted directory name is unreachable.

-- Mirror the palette and fonts back into vars/*.conf for hyprlock and the other
-- hypr* daemons, which are still hyprlang and cannot read this file.
require("lib.gen_vars").generate()

require("conf.general")
require("conf.decoration")
require("conf.animations")
require("conf.input")
require("conf.cursor")
require("conf.misc")
require("conf.binds")
require("conf.debug")
require("conf.layouts")
require("conf.monitor")

require("conf.environment")
require("conf.nvidia")

require("conf.workspaces")
require("conf.windowrules")
require("conf.layerrules")

require("conf.keybindings")
require("conf.voxtype-submap")

require("conf.autostart")

-- Last: overrides colors set above.
require("themes.tokyonight")
