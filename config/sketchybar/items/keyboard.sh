#!/usr/bin/env bash

sketchybar --add item keyboard right \
           --set keyboard update_freq=3 script="$PLUGIN_DIR/keyboard.sh"
