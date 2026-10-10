#!/usr/bin/env bash
# Start or stop a screen recording, like macOS Cmd+Shift+5.
#
#   screen-record.sh region   drag a region with slurp
#   screen-record.sh screen   the focused monitor
#
# Running it again while a recording is going stops and saves it.
# Videos go to ~/Videos with desktop audio.

set -uo pipefail

if pkill -INT -f '^gpu-screen-recorder'; then
  exit 0
fi

mkdir -p ~/Videos
file=~/Videos/"Screen Recording $(date '+%Y-%m-%d at %H.%M.%S').mp4"

case "${1:-region}" in
  region)
    area=$(slurp -f '%wx%h+%x+%y') || exit 0
    target=(-w region -region "$area") ;;
  screen)
    target=(-w "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')") ;;
esac

notify-send -t 2000 "Recording started" "Run the shortcut again to stop."
gpu-screen-recorder "${target[@]}" -f 60 -a default_output -ac aac -o "$file"
notify-send "Recording saved" "$file"
