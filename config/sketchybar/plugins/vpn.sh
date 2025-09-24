#!/bin/bash

if ps aux | grep -q '[o]penconnect.*zamevpn.o2.cz'; then
  sketchybar -m --set vpn icon=􀤆 \
                          label="O2" \
                          drawing=on
elif ps aux | grep -q '[w]g-quick.*\.conf'; then
  sketchybar -m --set vpn icon=􀤆 \
                          label="HOME" \
                          drawing=on
else
  sketchybar -m --set vpn drawing=off
fi
