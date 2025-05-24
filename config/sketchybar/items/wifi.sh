#!/usr/bin/env bash

sketchybar --add item wifi right \
           --set wifi script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change
           # --set wifi update_freq=5 script="$PLUGIN_DIR/wifi.sh"
