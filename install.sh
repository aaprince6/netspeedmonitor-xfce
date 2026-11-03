#!/usr/bin/env bash
set -euo pipefail

APP="NetSpeedMonitor XFCE"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
DEST="$BIN_DIR/netspeed-xfce"

if [[ ! -f "$SCRIPT_DIR/src/netspeed-xfce.sh" ]]; then
    echo "Error: src/netspeed-xfce.sh not found. Run this installer from the extracted project directory." >&2
    exit 1
fi

mkdir -p "$BIN_DIR"
install -m 0755 "$SCRIPT_DIR/src/netspeed-xfce.sh" "$DEST"

echo "$APP installed: $DEST"
echo
echo "Next steps:"
echo "  1. Install the XFCE panel plugin if needed:"
echo "       sudo apt install xfce4-genmon-plugin"
echo "  2. Right-click the XFCE panel > Panel > Add New Items > Generic Monitor."
echo "  3. Open Generic Monitor Properties and set Command to:"
echo "       $DEST"
echo "  4. Set the update period to 1 second."
echo
echo "The monitor combines eligible physical adapters by default."
echo "Run '$DEST' once in a terminal to test it."
