#!/usr/bin/env fish

set -g VPN_RESOLVER_SOURCE "$HOME/.local/secrets/work-vpn/resolver"
set -g VPN_RESOLVER_DEST /etc/resolver
set -g VPN_HOSTS_SOURCE "$HOME/.local/secrets/work-vpn/hosts-o2"
set -g VPN_INTERFACE o2vpn

# /etc/hosts gets one marked block. Adding always removes the old block first,
# so reconnecting never stacks copies. `sed -i` differs between GNU and BSD,
# so the file is rewritten through tee, which works on both.
function __work_hosts --argument-names action
    set -l hosts (sed '/^# --- WORK VPN START ---$/,/^# --- WORK VPN END ---$/d' /etc/hosts)
    # Never write back an empty file if sed failed.
    or return
    test -n "$hosts"; or return

    # Drop trailing blank lines left over from earlier blocks.
    while test (count $hosts) -gt 0; and test -z "$hosts[-1]"
        set -e hosts[-1]
    end

    if test "$action" = add
        set -a hosts "" "# --- WORK VPN START ---" (cat $VPN_HOSTS_SOURCE) "# --- WORK VPN END ---"
    end
    printf '%s\n' $hosts | sudo tee /etc/hosts >/dev/null
end

# Split DNS: only the work domains are resolved by the work nameservers.
# macOS reads /etc/resolver/<domain>. On Linux the same files are turned into
# per-link systemd-resolved settings, which disappear with the interface.
function __work_dns_up --argument-names iface
    if test (uname) = Darwin
        sudo mkdir -p $VPN_RESOLVER_DEST
        sudo cp $VPN_RESOLVER_SOURCE/* $VPN_RESOLVER_DEST/
        return
    end

    set -l servers (awk '$1 == "nameserver" && !seen[$2]++ { print $2 }' $VPN_RESOLVER_SOURCE/*)
    set -l domains (awk '$1 == "search" && !seen[$2]++ { print $2 }' $VPN_RESOLVER_SOURCE/*)
    for file in $VPN_RESOLVER_SOURCE/*
        set -a domains "~"(path basename $file)
    end

    sudo resolvectl dns $iface $servers
    sudo resolvectl domain $iface $domains
    sudo resolvectl default-route $iface false
end

function __work_dns_down
    if test (uname) = Darwin
        for file in $VPN_RESOLVER_SOURCE/*
            sudo rm -f $VPN_RESOLVER_DEST/(path basename $file)
        end
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
    else
        resolvectl flush-caches
    end
end

function work-vpn-connect
    if pgrep -x openconnect >/dev/null
        echo "Work VPN is already connected."
        return 1
    end

    echo $WORK_VPN_PASSWORD | sudo openconnect \
        --background \
        --passwd-on-stdin \
        --no-dtls \
        --base-mtu=1200 \
        --reconnect-timeout=60 \
        --interface=$VPN_INTERFACE \
        -c "$HOME/.local/secrets/o2-cz.p12" \
        -s "vpn-slice 10.0.0.0/8 172.26.193.0/24 > /dev/null 2>&1" \
        --servercert pin-sha256:OE43OObPFtjQnefwlZt2qxihd+wjFX+Md33RinqTbwY= \
        zamevpn.o2.cz
    or return

    # openconnect backgrounds itself once the tunnel is up; give the interface
    # a moment to appear before configuring DNS on it.
    if test (uname) != Darwin
        for i in (seq 20)
            ip link show $VPN_INTERFACE &>/dev/null; and break
            sleep 0.5
        end
    end

    __work_hosts add
    __work_dns_up $VPN_INTERFACE
end

function work-vpn-disconnect
    sudo pkill -SIGINT -x openconnect
    # Wait for vpnc-script/vpn-slice to remove its routes before cleaning up.
    while pgrep -x openconnect >/dev/null
        sleep 0.2
    end

    __work_hosts remove
    __work_dns_down
end

function work-vpn
    switch (gum choose "connect" "disconnect")
        case connect
            work-vpn-connect
        case disconnect
            work-vpn-disconnect
    end
end

function home-vpn
    switch (gum choose "connect" "disconnect")
        case connect
            wg-quick up "$HOME"/.local/secrets/home-vpn.conf
        case disconnect
            wg-quick down "$HOME"/.local/secrets/home-vpn.conf
    end
end

function o2-vpn
    set -l conf "$HOME"/.local/secrets/Macbook-Air.conf
    switch (gum choose "connect" "disconnect")
        case connect
            wg-quick up $conf; or return
            __work_hosts add
            __work_dns_up (path change-extension '' (path basename $conf))
        case disconnect
            wg-quick down $conf
            __work_hosts remove
            __work_dns_down
    end
end
