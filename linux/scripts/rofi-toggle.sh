#!/usr/bin/env bash
# Toggle the rofi launcher, the way Cmd+Space toggles Alfred/Spotlight.
set -uo pipefail

# pkill -x matches the exact process name, so this never catches something like
# "rofi-theme-selector". If an instance was running, closing it is the whole job.
if pkill -x rofi 2>/dev/null; then
  exit 0
fi

exec rofi \
  -show combi \
  -modi "combi,drun,run,web:$HOME/.config/dotfiles/linux/scripts/rofi-web.sh" \
  -combi-modi "drun,web" \
  -show-icons
