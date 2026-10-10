#!/usr/bin/env bash
# Commands behind the swaync control-center buttons (swaync/config.json).
#
#   control-center.sh <wifi|bluetooth|dark|record> get    print true/false
#   control-center.sh <wifi|bluetooth|dark|record> set    apply $SWAYNC_TOGGLE_STATE
#   control-center.sh brightness get|set <0-100>
set -uo pipefail

on=${SWAYNC_TOGGLE_STATE:-false}
s=$(dirname "$(readlink -f "$0")")

case "$1 $2" in
  "wifi get")       [ "$(nmcli radio wifi)" = enabled ] && echo true || echo false ;;
  "wifi set")       nmcli radio wifi "$([ "$on" = true ] && echo on || echo off)" ;;
  "bluetooth get")  bluetoothctl show | grep -q "Powered: yes" && echo true || echo false ;;
  "bluetooth set")  bluetoothctl power "$([ "$on" = true ] && echo on || echo off)" ;;
  "dark get")       [ "$(darkman get)" = dark ] && echo true || echo false ;;
  "dark set")       darkman set "$([ "$on" = true ] && echo dark || echo light)" ;;
  "record get")     pgrep -f '^gpu-screen-recorder' >/dev/null && echo true || echo false ;;
  "record set")     swaync-client -cp; setsid "$s/screen-record.sh" screen >/dev/null 2>&1 & ;;
  "brightness get") cat "$XDG_RUNTIME_DIR/brightness" 2>/dev/null ||
                      ddcutil --bus 10 --brief getvcp 10 | awk '{print $4}' ;;
  "brightness set") echo "$3" >"$XDG_RUNTIME_DIR/brightness"
                    ddcutil --bus 10 --noverify --skip-ddc-checks setvcp 10 "$3" ;;
esac
