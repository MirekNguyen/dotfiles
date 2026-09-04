#!/usr/bin/env fish

set -g VPN_RESOLVER_SOURCE "$HOME/.config/work-vpn/resolver"
set -g VPN_RESOLVER_DEST /etc/resolver
set -g VPN_HOSTS_SOURCE "$HOME/.config/work-vpn/hosts-o2"

function work-vpn-connect
    sudo cp "$VPN_RESOLVER_SOURCE"/* "$VPN_RESOLVER_DEST"/
    echo -e "\n# --- WORK VPN START ---" | sudo tee -a /etc/hosts >/dev/null
    sudo cat $VPN_HOSTS_SOURCE | sudo tee -a /etc/hosts >/dev/null
    echo -e "# --- WORK VPN END ---\n" | sudo tee -a /etc/hosts >/dev/null
    echo $WORK_VPN_PASSWORD | sudo openconnect \
          --background \
          --passwd-on-stdin \
          --no-dtls \
          --base-mtu=1200 \
          --reconnect-timeout=60 \
          -c "$HOME/.local/secrets/o2-cz.p12" \
          -s "vpn-slice 10.0.0.0/8 172.26.193.0/24 > /dev/null 2>&1" \
          zamevpn.o2.cz \
          --servercert pin-sha256:OE43OObPFtjQnefwlZt2qxihd+wjFX+Md33RinqTbwY=
end

function work-vpn-disconnect
    sudo pkill -SIGINT openconnect

    echo "🧹 Cleaning up /etc/hosts..."
    sudo sed -i '' '/# --- WORK VPN START ---/,/# --- WORK VPN END ---/d' /etc/hosts

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

    for file in (ls $VPN_RESOLVER_SOURCE)
        if test -e "$VPN_RESOLVER_DEST/$file"
            sudo rm "$VPN_RESOLVER_DEST/$file"
        end
    end

end

function work-vpn
    set option (gum choose "connect" "disconnect")
    switch $option
        case connect
            work-vpn-connect
        case disconnect
            work-vpn-disconnect
    end
end

function home-vpn
    set option (gum choose "connect" "disconnect")
    switch $option
        case connect
            wg-quick up "$HOME"/.local/secrets/home-vpn.conf
        case disconnect
            wg-quick down "$HOME"/.local/secrets/home-vpn.conf
    end
end


function o2-vpn
    sudo cp "$VPN_RESOLVER_SOURCE"/* "$VPN_RESOLVER_DEST"/
    echo -e "\n# --- WORK VPN START ---" | sudo tee -a /etc/hosts >/dev/null
    sudo cat $VPN_HOSTS_SOURCE | sudo tee -a /etc/hosts >/dev/null
    echo -e "# --- WORK VPN END ---\n" | sudo tee -a /etc/hosts >/dev/null
    set option (gum choose "connect" "disconnect")
    switch $option
        case connect
            wg-quick up "$HOME"/.local/secrets/Macbook-Air.conf
        case disconnect
            echo "🧹 Cleaning up /etc/hosts..."
            sudo sed -i '' '/# --- WORK VPN START ---/,/# --- WORK VPN END ---/d' /etc/hosts

            wg-quick down "$HOME"/Downloads/Macbook-Air.conf
            for file in (ls $VPN_RESOLVER_SOURCE)
                if test -e "$VPN_RESOLVER_DEST/$file"
                    sudo rm "$VPN_RESOLVER_DEST/$file"
                end
            end

    end
end
