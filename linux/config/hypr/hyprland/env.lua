-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Scaling. Native Wayland apps are scaled by Hyprland and always come out
-- right, so every toolkit that can is pushed to Wayland: Electron, and Qt
-- (falling back to X11 only when the Wayland plugin is missing).
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- What is left runs on XWayland, which misc.lua gives full-resolution surfaces
-- (force_zero_scaling) so nothing is upscaled and soft. Such apps have to scale
-- themselves. Measured on XWayland at scale 2 with no hints: GTK4 and Chromium
-- already detect 2, GTK3 stays at 1. GDK_SCALE fixes GTK3 (and Java) and
-- leaves the others at 2. It takes integers only, so it is skipped at
-- fractional scales rather than rounded to a wrong size.
--
-- Not Xft.dpi: Chromium multiplies it with the scale it already found and
-- drew at 4x, and GTK3 doubled its text on top of GDK_SCALE.
local scale = require("hyprland.monitors").scale
if scale == math.floor(scale) then
    hl.env("GDK_SCALE", tostring(math.floor(scale)))
end

-- Steam's UI is an embedded Chromium that reads none of the above, only its
-- own variable. Set here rather than in a launcher so it applies however Steam
-- is started (dock, launcher, steam:// links, autostart).
hl.env("STEAM_FORCE_DESKTOPUI_SCALING", tostring(scale))
