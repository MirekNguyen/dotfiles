#!/usr/bin/env zsh

work-vpn-connect () {
  eval "echo "$WORK_VPN_PASSWORD" | sudo openconnect --passwd-on-stdin --background $WORK_VPN_PARAMS"
}

work-vpn-disconnect () {
  sudo pkill -9 openconnect
  # flush dns
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  networksetup -setairportpower en0 off
  networksetup -setairportpower en0 on

  # route flush
  networksetup -setairportpower en0 off
  sudo route flush
  sudo ifconfig en1 down
  sudo ifconfig en1 up
  networksetup -setairportpower en0 on
}

work-vpn () {
  option="$(gum choose "connect" "disconnect")"
  case $option in
    "connect")
      work-vpn-connect
      ;;
    "disconnect")
      work-vpn-disconnect
      ;;
  esac
}
