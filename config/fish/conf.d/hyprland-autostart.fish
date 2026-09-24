# Start Hyprland after autologin on tty1 (Wayland desktop).
if status is-login
    and test -z "$WAYLAND_DISPLAY"
    and test "$XDG_VTNR" = 1
    and command -q start-hyprland
    exec start-hyprland
end
