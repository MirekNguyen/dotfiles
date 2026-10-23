----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
    -- The monitor is 4K at scale 2. Without this, Hyprland renders XWayland
    -- clients at 1x and upscales the result, which is blurry. With it they get
    -- the full 3840x2160 surface and stay sharp -- but each app now has to
    -- scale its own UI, or it draws at half size.
    --
    -- env.lua sets that up from the monitor scale, so this stays on.
    xwayland = {
        force_zero_scaling = true,
    },
})
