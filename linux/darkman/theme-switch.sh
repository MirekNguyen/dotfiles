#!/usr/bin/env bash
# darkman hook: re-theme the desktop for light or dark.
#
# Symlinked into ~/.local/share/darkman/, which runs it with the new mode as $1
# at sunrise/sunset and on `darkman toggle`
#
# Most of the desktop follows the XDG portal's org.freedesktop.appearance and every libadwaita app (Overskride, swaync) pick it up with no help.
# This script exists for the three things that do *not* watch the portal: GTK3, rofi, waybar, swaync, hyprlock and the wallpaper.

set -uo pipefail

REPO="$HOME/.config/dotfiles"
GTK3="$HOME/.config/gtk-3.0/settings.ini"
GTK4="$HOME/.config/gtk-4.0/settings.ini"

mode="${1:-}"
case "$mode" in
  dark|light) ;;
  *) echo "usage: ${0##*/} dark|light (normally run by darkman)" >&2; exit 2 ;;
esac

# 1. The portal setting. This is the one that cascades: kitty and libadwaita
#    apps re-theme themselves off it without further prompting.
if [ "$mode" = "dark" ]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  prefer_dark=1
else
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  prefer_dark=0
fi

# 2. GTK3 has no colour-scheme concept and ignores the portal, so its dark
#    variant has to be requested explicitly. GTK4's non-libadwaita path reads
#    the same key, so keep both files in step.
for f in "$GTK3" "$GTK4"; do
  [ -f "$f" ] && sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$prefer_dark/" "$f"
done

# 3. rofi, waybar and swaync read a palette file; swap where the symlink points.
ln -sfn "$REPO/linux/rofi/colors-$mode.rasi" "$HOME/.config/rofi/colors.rasi"
ln -sfn "colors-$mode.css" "$REPO/linux/waybar/colors.css"
ln -sfn "colors-$mode.css" "$REPO/linux/swaync/colors.css"
# hyprlock reads its palette each time it starts, so no reload is needed.
ln -sfn "colors-$mode.conf" "$REPO/linux/hypr/hyprlock/colors.conf"

# Wallpaper follows the mode too -- the blur has to have something to blur, and
# a dark bar over a light wallpaper (or vice versa) looks wrong immediately.
"$REPO/linux/scripts/wallpaper.sh" "$mode" >/dev/null 2>&1 &

# waybar reloads its CSS on SIGUSR2 without dropping the bar or its tray.
pkill -SIGUSR2 -x waybar 2>/dev/null

# swaync has a dedicated CSS reload, so the panel re-themes without restarting
# the daemon -- restarting would drop any notifications already in the tray.
command -v swaync-client >/dev/null 2>&1 && swaync-client --reload-css >/dev/null 2>&1

# rofi reads its theme at launch, so a running instance keeps the old palette.
# It is a transient launcher, so closing it is harmless and avoids a mismatch.
pkill -x rofi 2>/dev/null

exit 0
