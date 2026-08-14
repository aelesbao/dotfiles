-- See https://wiki.hyprland.org/Nvidia/
--
-- Applied unconditionally, as it was under hyprlang. Lua would let this be
-- guarded on the host actually having an NVIDIA GPU, but that is a behaviour
-- change and is deliberately left out of the migration.

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- Hardware video acceleration on Nvidia (depends on nvidia-vaapi-driver)
hl.env("NVD_BACKEND", "direct")
-- In case Electron apps are flickering, try running them in native Wayland instead
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
