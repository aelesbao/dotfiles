-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/

-- Workspace names
hl.workspace_rule({ workspace = "1", default_name = "planning" })
hl.workspace_rule({ workspace = "2", default_name = "browsing" })
hl.workspace_rule({ workspace = "3", default_name = "development" })
hl.workspace_rule({ workspace = "4", default_name = "work" })
hl.workspace_rule({ workspace = "5", default_name = "studies" })
hl.workspace_rule({ workspace = "6", default_name = "gaming" })

-- Remove gaps on fullscreen workspaces
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })

-- Add gaps to special workspaces
hl.workspace_rule({ workspace = "s[true]", gaps_out = 100 })
hl.workspace_rule({ workspace = "special:zen", gaps_out = 8, gaps_in = 4 })
