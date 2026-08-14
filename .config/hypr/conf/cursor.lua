hl.config({
  cursor = {
    -- sync xcursor theme with gsettings, it applies cursor-theme
    -- and cursor-size on theme load to gsettings making most CSD
    -- gtk based clients use same xcursor theme and size.
    sync_gsettings_theme = true,

    -- Move the cursor to the last focused window after changing
    -- the workspace or toggling a special workspace.
    -- Options: 0 disabled, 1 enabled, 2 force
    warp_on_change_workspace = 1,
    warp_on_toggle_special = 1,

    -- detach the camera from the mouse when zoomed in, only ever
    -- moving the camera to keep the mouse in view when it goes
    -- past the screen edges
    zoom_detached_camera = false,
  },
})
