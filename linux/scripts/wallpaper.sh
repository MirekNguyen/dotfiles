#!/usr/bin/env bash
# Wallpaper via awww (started in autostart.lua).
#
#   wallpaper.sh rotate   new random wallpaper every 30 minutes (autostart)
#   wallpaper.sh random   switch to a random one now
#   wallpaper.sh          rofi script mode: a tab in the launcher, see rofi-toggle.sh
#
# Images live in the separate wallpapers repo. gradients/ is a subfolder, so
# it is left out of the rotation.

set -uo pipefail

dir=~/Pictures/wallpapers/linux
thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper-thumbs"

images() { find "$dir" -maxdepth 1 -type f -regex '.*\.\(jpe?g\|png\|gif\|webp\)' | sort; }

set_wallpaper() {
  awww img "$1" --transition-type fade --transition-duration 1 --transition-fps 120
}

case "${1:-}" in
  rotate)
    while true; do
      sleep 1800
      set_wallpaper "$(images | shuf -n 1)"
    done ;;
  random)
    set_wallpaper "$(images | shuf -n 1)" ;;
  *)
    # Selection pass from rofi.
    if [ -n "${ROFI_INFO:-}" ]; then
      set_wallpaper "$ROFI_INFO" >/dev/null 2>&1 &
      exit 0
    fi
    mkdir -p "$thumbs"
    images | while read -r f; do
      name=$(basename "${f%.*}")
      t="$thumbs/$name.jpg"
      [ -s "$t" ] || magick "$f[0]" -thumbnail 480x270^ -gravity center -extent 480x270 "$t"
      printf '%s\0info\x1f%s\x1ficon\x1f%s\n' "$name" "$f" "$t"
    done ;;
esac
