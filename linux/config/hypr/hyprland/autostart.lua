-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)

-- macOS-style Cmd shortcuts. See linux/xremap/config.yml for what is remapped.
--
-- Started from here rather than as a systemd user unit on purpose: xremap needs
-- HYPRLAND_INSTANCE_SIGNATURE and WAYLAND_DISPLAY to ask Hyprland which window
-- is focused, and that per-app detection is what lets it skip kitty. Launching
-- from the compositor inherits both; a systemd unit starts with a clean
-- environment and needs import-environment glue that races with startup.
--
-- Requires membership in the `input` group to read /dev/input/event*.
hl.on("hyprland.start", function()
    hl.exec_cmd("pkill -x xremap; xremap --watch=device,config " ..
        os.getenv("HOME") .. "/.config/dotfiles/linux/xremap/config.yml")
    hl.exec_cmd("pkill -x waybar; waybar")
    -- swaync and swayosd are GTK4, which registers every surface with the
    -- ext-background-effect protocol. Hyprland then ignores the blur layer
    -- rules for them, so the glass was plain see-through. Hiding the protocol
    -- from GTK lets the rules in rules.lua apply, as for waybar and the dock.
    -- swaync runs as its systemd unit, which is where its copy of the variable
    -- lives (linux/config/systemd/user/swaync.service.d/blur.conf).
    local noGtkBlur = "GDK_WAYLAND_DISABLE=ext_background_effect_manager_v1 "
    hl.exec_cmd("systemctl --user restart swaync")
    -- Window corner buttons and the dock's bottom-edge trigger (linux/quickshell).
    hl.exec_cmd("pkill -f '^qs -p .*/linux/quickshell'; qs -p " .. os.getenv("HOME") ..
        "/.config/dotfiles/linux/quickshell")
    -- -hl top puts the dock's own hotspot under linux/quickshell/DockEdge.qml,
    -- which shows the dock instead, macOS-style. The XDG_DATA_DIRS entry swaps in
    -- the dock's running-app dots (linux/config/nwg-dock-hyprland/data).
    hl.exec_cmd("pkill -f '^nwg-dock-hyprland'; XDG_DATA_DIRS=" .. os.getenv("HOME") ..
        "/.config/dotfiles/linux/config/nwg-dock-hyprland/data:${XDG_DATA_DIRS:-/usr/local/share:/usr/share} " ..
        "nwg-dock-hyprland -d -hl top -i 84 -mb 12 -nolauncher")
    hl.exec_cmd("pkill -x swayosd-server; " .. noGtkBlur .. "swayosd-server --config ~/.config/dotfiles/linux/swayosd/config.toml --style ~/.config/dotfiles/linux/swayosd/style.css")
    -- Wallpaper. awww-daemon restores the last one; the loop rotates every 30 min.
    -- See linux/scripts/wallpaper.sh.
    hl.exec_cmd("pkill -x awww-daemon; awww-daemon")
    hl.exec_cmd("pkill -f '^bash .*wallpaper.sh rotate'; " .. os.getenv("HOME") .. "/.config/dotfiles/linux/scripts/wallpaper.sh rotate")
    -- Light/dark theme. darkman is a systemd user
    -- service started at login, before Hyprland exists, so its hooks can't
    -- reach hyprctl (the wallpaper silently stayed put). Hand it this session's
    -- variables and restart it; on startup it runs the hook for the current mode.
    -- The scaling variables from env.lua go along, so apps started through
    -- D-Bus or systemd (links, portals, notifications) scale like the rest.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP " ..
        "GDK_SCALE QT_QPA_PLATFORM ELECTRON_OZONE_PLATFORM_HINT STEAM_FORCE_DESKTOPUI_SCALING && systemctl --user restart darkman")
    -- Clipboard history. Nothing is recorded unless this watcher is running, so
    -- the SUPER+ALT+C menu would simply come up empty without it.
    -- The pkill pattern is anchored with ^ on purpose: this line runs via
    -- `sh -c`, whose own command line contains the text too, and an unanchored
    -- `pkill -f` killed that shell before the watcher ever started.
    hl.exec_cmd("pkill -f '^wl-paste --watch cliphist'; wl-paste --watch cliphist store")
    -- Idle: display off at 20 min, lock at 30, never suspend. See hypridle/hypridle.conf.
    hl.exec_cmd("pkill -x hypridle; hypridle -c ~/.config/hypr/hypridle/hypridle.conf")
    -- Polkit agent: the password prompt for apps asking for admin rights.
    -- Started explicitly because graphical-session.target is never reached
    -- without uwsm, so `systemctl --user enable` alone would not start it.
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    -- Calendar reminders (GNOME Calendar/Evolution). Normally started via XDG
    -- autostart, which Hyprland does not run.
    hl.exec_cmd("pkill -f '^/usr/lib/evolution-data-server/evolution-alarm-notify'; /usr/lib/evolution-data-server/evolution-alarm-notify")
    -- Game streaming host for Moonlight. Launched here rather than via its
    -- systemd unit so it inherits the Wayland session for screen capture.
    -- See linux/sunshine/sunshine.conf.
    local sunshine = os.getenv("HOME") .. "/.config/dotfiles/linux/sunshine"
    hl.exec_cmd("command -v sunshine >/dev/null && { pkill -x sunshine; sunshine " ..
        sunshine .. "/sunshine.conf file_apps=" .. sunshine .. "/apps.json; }")
end)
