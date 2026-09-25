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
    hl.exec_cmd("pkill -x swaync; swaync")
    hl.exec_cmd("pkill -x swayosd-server; swayosd-server --config ~/.config/dotfiles/linux/swayosd/config.toml --style ~/.config/dotfiles/linux/swayosd/style.css")
    -- Wallpaper. See hypr/hyprpaper.conf.
    hl.exec_cmd("pkill -x hyprpaper; hyprpaper")
    -- Light/dark theme. darkman is a systemd user
    -- service started at login, before Hyprland exists, so its hooks can't
    -- reach hyprctl (the wallpaper silently stayed put). Hand it this session's
    -- variables and restart it; on startup it runs the hook for the current mode.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP && systemctl --user restart darkman")
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
    -- Game streaming host for Moonlight. Launched here rather than via its
    -- systemd unit so it inherits the Wayland session for screen capture.
    -- See linux/sunshine/sunshine.conf.
    local sunshine = os.getenv("HOME") .. "/.config/dotfiles/linux/sunshine"
    hl.exec_cmd("command -v sunshine >/dev/null && { pkill -x sunshine; sunshine " ..
        sunshine .. "/sunshine.conf file_apps=" .. sunshine .. "/apps.json; }")
end)
