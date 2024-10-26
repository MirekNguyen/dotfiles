#!/bin/bash

SSID="$(ipconfig getsummary en0 | grep -w "SSID" | cut -d: -f2 | xargs)"
if echo "$SSID" | grep -q 'iPhone'; then
  sketchybar -m --set wifi icon=􀉤  drawing=on label="Hotspot"
elif [ ! -z "$SSID" ]; then
  sketchybar -m --set wifi icon=􀙇 drawing=on label.drawing=off
else
  sketchybar -m --set wifi icon=􀙈 drawing=on label="Not connected"
fi
