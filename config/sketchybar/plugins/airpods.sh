#!/bin/bash

airpods=$(switchaudiosource -c | grep -i airpods)

if [ ! -z "$airpods" ]; then
  sketchybar -m --set airpods icon=􀟥 drawing=on label.drawing=off icon.drawing=on
else
  sketchybar -m --set airpods drawing=off label.drawing=off icon.drawing=off
fi
