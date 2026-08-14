-- https://wiki.hyprland.org/Configuring/Variables/#animations
hl.config({
  animations = {
    enabled = true,
    workspace_wraparound = true,
  },
})

-- Curves
-- hl.curve(NAME, { type = "bezier", points = { {X0, Y0}, {X1, Y1} } })
-- where the two points are the control points for a Cubic Bézier curve.
-- `type = "spring"` is also available, taking mass/stiffness/dampening.
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.15, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })
hl.curve("easeInOutQuart", { type = "bezier", points = { { 0.76, 0 }, { 0.24, 1 } } })

-- Animations
-- hl.animation({ leaf = NAME, enabled = BOOL, speed = DS, bezier = CURVE, style = STYLE })
-- speed is the amount of ds (1ds = 100ms) the animation will take.
-- bezier is a curve name from above; use `spring` instead for spring curves.
-- style is optional.

-- global
hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "default" })

--   ↳ windows - styles: slide, popin, gnomed
--     ↳ windowsIn - window open - styles: same as windows
--     ↳ windowsOut - window close - styles: same as windows
--     ↳ windowsMove - everything in between, moving, dragging, resizing.
--
-- For animation style popin in windows, you can specify a minimum percentage to start from.
-- For example, the following will make the animation 80% -> 100% of the size:
--
--   style = "popin 80%"
--
-- For animation style slide in windows and layers you can specify a forced side.
-- You can choose between top, bottom, left or right.
--
--   style = "slide left"
hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "easeOutQuint", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.5, bezier = "easeOutQuint", style = "popin 80%" })

--   ↳ layers - styles: slide, popin, fade
--     ↳ layersIn - layer open
--     ↳ layersOut - layer close
hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.7, bezier = "almostLinear", style = "fade" })

--   ↳ fade
--     ↳ fadeIn - fade in for window open
--     ↳ fadeOut - fade out for window close
--     ↳ fadeSwitch - fade on changing activewindow and its opacity
--     ↳ fadeShadow - fade on changing activewindow for shadows
--     ↳ fadeDim - the easing of the dimming of inactive windows
--     ↳ fadeLayers - for controlling fade on layers
--       ↳ fadeLayersIn - fade in for layer open
--       ↳ fadeLayersOut - fade out for layer close
--     ↳ fadePopups - for controlling fade on wayland popups
--       ↳ fadePopupsIn - fade in for wayland popup open
--       ↳ fadePopupsOut - fade out for wayland popup close
--     ↳ fadeDpms - for controlling fade when dpms is toggled
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "quick" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "quick" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "quick" })

--   ↳ border - for animating the border's color switch speed
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
--   ↳ borderangle - for animating the border's gradient angle - styles: once (default), loop
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })

--   ↳ workspaces - styles: slide, slidevert, fade, slidefade, slidefadevert
--     ↳ workspacesIn - styles: same as workspaces
--     ↳ workspacesOut - styles: same as workspaces
--     ↳ specialWorkspace - styles: same as workspaces
--       ↳ specialWorkspaceIn - styles: same as workspaces
--       ↳ specialWorkspaceOut - styles: same as workspaces
--
-- For animation styles slide, slidevert, slidefade and slidefadevert in workspaces, you can
-- specify a movement percentage, e.g. style = "slidefade 20%" moves windows 20% of the screen width.
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "quick", style = "fade" })

--   ↳ zoomFactor - animates the screen zoom
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 2, bezier = "easeInOutCubic" })

--   ↳ monitorAdded - monitor added zoom animation
hl.animation({ leaf = "monitorAdded", enabled = true, speed = 5, bezier = "easeInOutQuart" })
