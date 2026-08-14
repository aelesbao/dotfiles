local apps = require("lib.apps")

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch.
--
-- Replaces hyprlang's `exec-once`, which has no Lua equivalent. hl.exec_cmd
-- spawns asynchronously, so no `& disown` is needed.
hl.on("hyprland.start", function()
  -- Core components (authentication, lock screen, notification daemon)
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  -- Fix apps that take a really long time to open
  hl.exec_cmd([[sleep 1 && dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP]])
  -- SwayOSD
  hl.exec_cmd("uwsm app -- swayosd-server")

  -- Removable disk automounter using udisks
  hl.exec_cmd("udiskie")

  -- Open to the system tray without showing the main window
  hl.exec_cmd([[sleep 5 && uwsm app -- 1password --silent]])

  -- KDE Connect indicator in the system tray
  hl.exec_cmd("uwsm app -- org.kde.kdeconnect.nonplasma.desktop")

  -- LM Studio as a service
  hl.exec_cmd("uwsm app -- lm-studio --run-as-service")

  -- Start terminal emulator
  hl.exec_cmd(apps.terminal)

  -- hl.exec_cmd("uwsm app -- mailspring.desktop")
  -- hl.exec_cmd("uwsm app -- me.proton.Mail.desktop")
  -- hl.exec_cmd("uwsm app -- ferdium.desktop")
  -- hl.exec_cmd("uwsm app -- signal.desktop")
  -- hl.exec_cmd("uwsm app -- obsidian.desktop")
  -- hl.exec_cmd("uwsm app -- slack.desktop")
  hl.exec_cmd("uwsm app -- com.todoist.Todoist.desktop")
  hl.exec_cmd("uwsm app -- org.gnome.Calendar.desktop")
  hl.exec_cmd("uwsm app -- brave-browser.desktop")
end)
