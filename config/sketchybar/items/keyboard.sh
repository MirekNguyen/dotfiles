#!/usr/bin/env bash

sketchybar --add item keyboard right \
           --set keyboard update_freq=2 script="$PLUGIN_DIR/keyboard.sh"
