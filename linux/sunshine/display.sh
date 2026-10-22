#!/bin/sh
# Sunshine prep command (see sunshine.conf): `stream` moves the desktop to the
# HDMI dummy plug and turns DP-1 off, `desktop` puts it back.
# The flag file is read by hypr/hyprland/monitors.lua.

flag="$XDG_RUNTIME_DIR/sunshine-streaming"

case "$1" in
stream) touch "$flag" ;;
desktop) rm -f "$flag" ;;
esac
hyprctl reload
