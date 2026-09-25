#!/usr/bin/env fish

set -g VPN_RESOLVER_SOURCE "$HOME/.local/secrets/work-vpn/resolver"
set -g VPN_HOSTS_SOURCE "$HOME/.local/secrets/work-vpn/hosts-o2"

function __work_hosts --argument-names action
    set -l hosts (sed '/^# --- WORK VPN START ---$/,/^# --- WORK VPN END ---$/d' /etc/hosts); or return
    if test "$action" = add
        set -a hosts "# --- WORK VPN START ---" (cat $VPN_HOSTS_SOURCE) "# --- WORK VPN END ---"
    end
    printf '%s\n' $hosts | sudo tee /etc/hosts >/dev/null
end

# Send only the work domains to the work nameservers. On Linux the settings
# live on the VPN interface and go away with it.
function __work_dns_up --argument-names iface
    if test (uname) = Darwin
        sudo mkdir -p /etc/resolver
        sudo cp $VPN_RESOLVER_SOURCE/* /etc/resolver/
        return
    end
    set -l servers (awk '$1 == "nameserver" && $2 ~ /^10\./ && !seen[$2]++ { print $2 }' $VPN_RESOLVER_SOURCE/*)
    set -l domains to2cz.cz "~"(path basename $VPN_RESOLVER_SOURCE/*)
    sudo resolvectl dns $iface $servers
    sudo resolvectl domain $iface $domains
    sudo resolvectl default-route $iface false
end

function __work_dns_down
    test (uname) = Darwin; or return
    for file in $VPN_RESOLVER_SOURCE/*
        sudo rm -f /etc/resolver/(path basename $file)
    end
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder
end

function work-vpn-connect
    echo $WORK_VPN_PASSWORD | sudo openconnect \
        --background \
        --passwd-on-stdin \
        --no-dtls \
        --base-mtu=1200 \
        --reconnect-timeout=60 \
        --interface=o2vpn \
        -c "$HOME/.local/secrets/o2-cz.p12" \
        -s "vpn-slice 10.0.0.0/8 172.26.193.0/24 > /dev/null 2>&1" \
        --servercert pin-sha256:OE43OObPFtjQnefwlZt2qxihd+wjFX+Md33RinqTbwY= \
        zamevpn.o2.cz
    or return
    __work_hosts add
    __work_dns_up o2vpn
end

function work-vpn-disconnect
    sudo pkill -SIGINT -x openconnect
    __work_hosts remove
    __work_dns_down
end

function work-vpn
    switch (gum choose connect disconnect)
        case connect
            work-vpn-connect
        case disconnect
            work-vpn-disconnect
    end
end

function home-vpn
    switch (gum choose connect disconnect)
        case connect
            wg-quick up "$HOME"/.local/secrets/home-vpn.conf
        case disconnect
            wg-quick down "$HOME"/.local/secrets/home-vpn.conf
    end
end

function o2-vpn
    # Each machine is its own peer. wg-quick names the interface after the file.
    set -l iface o2-desktop
    test (uname) = Darwin; and set iface o2-macbook
    set -l conf "$HOME"/.local/secrets/$iface.conf
    switch (gum choose connect disconnect)
        case connect
            wg-quick up $conf; or return
            __work_hosts add
            __work_dns_up $iface
        case disconnect
            wg-quick down $conf
            __work_hosts remove
            __work_dns_down
    end
end
