#!/usr/bin/env bash
set -euo pipefail
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
TARGET="$BIN_DIR/netspeed-xfce"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/netspeed-xfce"

rm -f "$TARGET"
rm -rf "$STATE_DIR"
echo "NetSpeedMonitor XFCE removed."
echo "If you added Generic Monitor to your XFCE panel, remove it manually:"
echo "Right-click panel > Panel > Panel Preferences > Items > select Generic Monitor > Remove."
