#!/system/bin/sh

# Load configuration
. /data/adb/box/scripts/box.config

# Stop the proxy core
if [ -f /data/adb/box/run/box.pid ]; then
    kill -15 $(cat /data/adb/box/run/box.pid) 2>/dev/null
    sleep 1
    [ -z "$(pidof ${bin_name})" ] || killall -9 "${bin_name}" 2>/dev/null
    rm -f /data/adb/box/run/box.pid
else
    killall -9 "${bin_name}" 2>/dev/null
fi

# Stop inotify monitoring
pkill -f /data/adb/box/scripts/ctr.inotify 2>/dev/null
killall inotifyd 2>/dev/null

# Disable TPROXY/iptables rules
/data/adb/box/scripts/box.tproxy disable

# Disable TUN forwarding (aligned with box.service)
if [ -n "${tun_device}" ]; then
    ip rule del pref 5000 2>/dev/null
    ip rule del pref 5010 2>/dev/null
    ip rule del pref 5020 2>/dev/null
    ip rule del pref 5030 2>/dev/null
    ip rule del pref 5040 2>/dev/null
    ip rule del pref 5050 2>/dev/null
    ip rule del pref 6000 2>/dev/null
    ip rule del pref 7000 2>/dev/null
    ip rule del pref 8000 2>/dev/null
    iptables -w 100 -D FORWARD -o ${tun_device} -j ACCEPT 2>/dev/null
    iptables -w 100 -D FORWARD -i ${tun_device} -j ACCEPT 2>/dev/null
    ip6tables -w 100 -D FORWARD -o ${tun_device} -j ACCEPT 2>/dev/null
    ip6tables -w 100 -D FORWARD -i ${tun_device} -j ACCEPT 2>/dev/null
    ip link delete "${tun_device}" 2>/dev/null
fi

# Clean up runtime files
rm -rf /data/adb/box/run/*.log /data/adb/box/run/box.pid /data/adb/box/run CLOUDFLARE_TOKEN 2>/dev/null
