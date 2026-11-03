#!/usr/bin/env bash
# NetSpeedMonitor XFCE - real-time network speed for the XFCE Generic Monitor.
# Copyright (c) 2026 NetSpeedMonitor XFCE contributors
# SPDX-License-Identifier: MIT

set -u
export LC_ALL=C

APP_NAME="NetSpeedMonitor XFCE"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/netspeed-xfce"
STATE_FILE="$STATE_DIR/traffic.state"

# Optional environment overrides:
#   NETSPEED_INCLUDE_VIRTUAL=1 includes interfaces without a physical device.
#   NETSPEED_EXCLUDE_IFACES="lo tailscale0 docker0" excludes named interfaces.
INCLUDE_VIRTUAL="${NETSPEED_INCLUDE_VIRTUAL:-0}"
EXCLUDE_IFACES=" ${NETSPEED_EXCLUDE_IFACES:-lo} "

mkdir -p "$STATE_DIR" 2>/dev/null || {
    printf '<txt>↓ -- ↑ --</txt>\n<tool>Cannot create cache directory: %s</tool>\n' "$STATE_DIR"
    exit 0
}

rx_total=0
tx_total=0
interfaces=()

for iface_path in /sys/class/net/*; do
    [[ -e "$iface_path" ]] || continue
    iface="${iface_path##*/}"

    [[ "$EXCLUDE_IFACES" == *" $iface "* ]] && continue

    if [[ "$INCLUDE_VIRTUAL" != "1" && ! -e "$iface_path/device" ]]; then
        continue
    fi

    if [[ -r "$iface_path/operstate" ]]; then
        operstate="$(<"$iface_path/operstate")"
        [[ "$operstate" == "down" ]] && continue
    fi

    rx_file="$iface_path/statistics/rx_bytes"
    tx_file="$iface_path/statistics/tx_bytes"
    [[ -r "$rx_file" && -r "$tx_file" ]] || continue

    rx_value="$(<"$rx_file")"
    tx_value="$(<"$tx_file")"
    [[ "$rx_value" =~ ^[0-9]+$ && "$tx_value" =~ ^[0-9]+$ ]] || continue

    rx_total=$((rx_total + rx_value))
    tx_total=$((tx_total + tx_value))
    interfaces+=("$iface")
done

if ( ${#interfaces[@]} == 0 ); then
    printf '<txt><span foreground="#AAAAAA">↓ --  ↑ --</span></txt>\n'
    printf '<tool>No eligible network adapters found. Check interface filters.</tool>\n'
    exit 0
fi

now_ns="$(date +%s%N)"
old_rx=0
old_tx=0
old_time=0

if [[ -r "$STATE_FILE" ]]; then
    read -r old_rx old_tx old_time < "$STATE_FILE" || true
fi

printf '%s %s %s\n' "$rx_total" "$tx_total" "$now_ns" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

down_bps=0
up_bps=0
if [[ "$old_time" =~ ^[0-9]+$ && "$old_time" -gt 0 && "$now_ns" =~ ^[0-9]+$ && "$now_ns" -gt "$old_time" ]]; then
    elapsed_ns=$((now_ns - old_time))
    if [[ "$old_rx" =~ ^[0-9]+$ && "$old_tx" =~ ^[0-9]+$ && "$rx_total" -ge "$old_rx" && "$tx_total" -ge "$old_tx" ]]; then
        down_bps=$(awk -v n="$rx_total" -v o="$old_rx" -v t="$elapsed_ns" 'BEGIN { if (t > 0) printf "%.0f", (n-o)*1000000000/t; else print 0 }')
        up_bps=$(awk -v n="$tx_total" -v o="$old_tx" -v t="$elapsed_ns" 'BEGIN { if (t > 0) printf "%.0f", (n-o)*1000000000/t; else print 0 }')
    fi
fi

format_speed() {
    awk -v speed="${1:-0}" 'BEGIN {
        if (speed >= 1048576) printf "%.1f MB/s", speed/1048576
        else if (speed >= 1024) printf "%.0f KB/s", speed/1024
        else printf "%.0f B/s", speed
    }'
}

download="$(format_speed "$down_bps")"
upload="$(format_speed "$up_bps")"
interface_list="${interfaces[*]}"

printf '<txt><span foreground="#4ADE80">↓</span> %s  <span foreground="#60A5FA">↑</span> %s</txt>\n' "$download" "$upload"
printf '<tool>%s\nAdapters: %s\nDownload: %s\nUpload: %s</tool>\n' "$APP_NAME" "$interface_list" "$download" "$upload"
