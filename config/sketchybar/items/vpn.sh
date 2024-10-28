#!/usr/bin/env bash

sketchybar --add item vpn right \
           --set vpn update_freq=5 script="$PLUGIN_DIR/vpn.sh"
