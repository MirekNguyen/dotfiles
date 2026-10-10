#!/usr/bin/env bash
# The launcher, toggled like Cmd+Space toggles Alfred/Spotlight.
#
#   rofi-toggle.sh [tab]   tab: apps (default), calc, clipboard, wallpaper
#
# One window with tabs; Ctrl+Tab / Ctrl+Shift+Tab switch between them.
# Apps also lists the web bookmarks. Calc shows its live result in the message
# box, which the combined Apps tab can't do, hence a tab of its own.
set -uo pipefail

# pkill -x matches the exact process name, so this never catches something like
# "rofi-theme-selector". If an instance was running, closing it is the whole job.
if pkill -x rofi 2>/dev/null; then
  exit 0
fi

s="$HOME/.config/dotfiles/linux/scripts"

# Per-tab layout. The Apps tab opens as a bare search bar (require-input in
# config.rasi); the others list their entries straight away. Script modes can't
# change the layout once open, so it is set here for the tab rofi starts on.
tab=${1:-apps}
case "$tab" in
  apps)      tab=combi; layout='' ;;
  clipboard) tab=Clipboard; layout='listview { require-input: false; lines: 8; } element-icon { size: 56px; }' ;;
  wallpaper) tab=Wallpaper; layout='listview { require-input: false; columns: 3; lines: 3; } element { orientation: vertical; } element-icon { size: 150px; } element-text { horizontal-align: 0.5; }' ;;
  *)         layout='' ;;
esac

exec rofi \
  -show "$tab" \
  -modi "combi,calc,Clipboard:$s/rofi-clipboard.sh,Wallpaper:$s/wallpaper.sh" \
  -combi-modi "drun,web:$s/rofi-web.sh" \
  -combi-hide-mode-prefix \
  -display-combi "Apps" -display-calc "Calc" \
  -kb-accept-alt "" -kb-custom-1 "Shift+Return" \
  -no-history -hint-result "" -hint-welcome "" \
  -calc-command "echo -n '{result}' | wl-copy" \
  -show-icons \
  -theme-str 'mainbox { children: [ inputbar, message, listview, mode-switcher ]; }' \
  -theme-str 'message { margin: 12px 0 0 0; padding: 12px 18px; border: 1px; border-color: @border-glass; border-radius: 14px; background-color: @bg-input; }' \
  -theme-str 'textbox { font: "Adwaita Sans 15"; }' \
  -theme-str 'mode-switcher { margin: 12px 0 0 0; spacing: 6px; }' \
  -theme-str 'button { padding: 6px; border-radius: 10px; text-color: @fg-secondary; }' \
  -theme-str 'button selected { background-color: @bg-hover; text-color: @fg-primary; }' \
  -theme-str "$layout"
