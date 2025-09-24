#!/usr/bin/env fish

function work-vpn-connect
    echo $WORK_VPN_PASSWORD | sudo openconnect --passwd-on-stdin --background -c /Users/mireknguyen/.local/secrets/o2-cz.p12 -s 'vpn-slice 10.0.0.0/8 172.26.193.0/24' zamevpn.o2.cz --servercert pin-sha256:pUMlm+u8GjTUgL8GiyTG+odQaUMD9FGpQQNTki/pTgQ=
end

function work-vpn-disconnect
    sudo pkill -9 openconnect

    # Flush DNS
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
    networksetup -setairportpower en0 off
    networksetup -setairportpower en0 on

    # Route flush
    networksetup -setairportpower en0 off
    sudo route flush
    sudo ifconfig en1 down
    sudo ifconfig en1 up
    networksetup -setairportpower en0 on
end

function work-vpn
    set option (gum choose "connect" "disconnect")
    switch $option
        case "connect"
            work-vpn-connect
        case "disconnect"
            work-vpn-disconnect
    end
end


function home-vpn
  set option (gum choose "connect" "disconnect")
  switch $option
    case "connect"
      wg-quick up "$HOME"/.local/secrets/home-vpn.conf
    case "disconnect"
      wg-quick down "$HOME"/.local/secrets/home-vpn.conf
  end
end
