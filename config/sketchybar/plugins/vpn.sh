#!/bin/bash

VPN=$(ps aux | grep openconnect | grep 'zamevpn.o2.cz' | grep -v 'sudo TERMINFO')

if [[ $VPN != "" ]]; then
  sketchybar -m --set vpn icon=􀤆 \
                          label="O2" \
                          drawing=on
else
  sketchybar -m --set vpn drawing=off
fi
