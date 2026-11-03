# NetSpeedMonitor XFCE

A lightweight real-time upload/download speed indicator for the **XFCE panel**, powered by Bash and XFCE Generic Monitor (Genmon).

It displays combined traffic across eligible physical network adapters by default, for example:

- `↓ 12.5 MB/s` — download
- `↑ 2.4 MB/s` — upload

Download is green; upload is blue. Hover over the indicator to see the adapters being counted and the current rates.

## Features

- Live upload and download rates, refreshed by XFCE Generic Monitor.
- Combines traffic across physical/network-device-backed adapters by default.
- Automatically detects available adapters; no hard-coded `eth0` or `wlan0`.
- Human-readable B/s, KB/s and MB/s units.
- Colored download/upload indicators and a tooltip.
- No root privileges required for normal operation.
- Small Bash implementation with no extra runtime dependencies beyond standard Kali/Debian utilities.

## Requirements

- Linux with `/sys/class/net` statistics exposed by the kernel.
- Bash, `awk`, `date`, and standard core utilities.
- XFCE panel and the `xfce4-genmon-plugin` package for the panel display.

On Kali Linux or Debian:

```bash
sudo apt update
sudo apt install xfce4-genmon-plugin
```

## Install

Clone the repository and run the installer:

```bash
git clone https://github.com/aaprince6/netspeedmonitor-xfce.git
cd netspeedmonitor-xfce
chmod +x install.sh uninstall.sh
./install.sh
```

The installer copies the monitor to `~/.local/bin/netspeed-xfce`.

## Add it to the XFCE panel

1. Right-click the XFCE panel.
2. Choose **Panel → Add New Items**.
3. Select **Generic Monitor** and click **Add**.
4. Right-click the new Generic Monitor item and open **Properties**.
5. Set **Command** to:

   ```text
   /home/YOUR_USERNAME/.local/bin/netspeed-xfce
   ```

   Replace `YOUR_USERNAME` with your Linux username. If you used a custom `XDG_BIN_HOME`, use the installed path instead.

6. Set the update period to **1 second**.
7. Close the properties window. The first sample may show zero; rates appear after the next refresh.

You can test the script in a terminal:

```bash
~/.local/bin/netspeed-xfce
sleep 1
~/.local/bin/netspeed-xfce
```

The script prints Genmon markup (`<txt>` and `<tool>`), so it is intended to be run by Generic Monitor rather than as a standalone terminal dashboard.

## Adapter selection and counting

By default, the monitor counts interfaces that have a backing device in `/sys/class/net/INTERFACE/device`. This normally includes physical Ethernet, Wi-Fi and USB network adapters, while excluding loopback and many virtual interfaces such as Tailscale, Docker and bridges.

This is a **sum of interface counters**, not a deduplicated measurement of internet traffic. If the same packets traverse more than one counted adapter (for example, in a bridge, router, bond, or forwarding setup), the total can be counted more than once. Interface counter semantics also vary by driver and network topology.

Optional environment variables:

| Variable | Default | Description |
|---|---|---|
| `NETSPEED_INCLUDE_VIRTUAL` | `0` | Set to `1` to include interfaces without a physical device backing. |
| `NETSPEED_EXCLUDE_IFACES` | `lo` | Space-separated interface names to exclude. |

Example command in Generic Monitor to include virtual adapters but exclude Tailscale:

```bash
NETSPEED_INCLUDE_VIRTUAL=1 NETSPEED_EXCLUDE_IFACES="lo tailscale0" /home/YOUR_USERNAME/.local/bin/netspeed-xfce
```

Note: environment variables are applied to each script invocation. Keep the same options for every refresh so the rate calculation remains consistent.

## Troubleshooting

### Generic Monitor shows no output

- Confirm the command path is correct and executable:

  ```bash
  ls -l ~/.local/bin/netspeed-xfce
  ~/.local/bin/netspeed-xfce
  ```

- Confirm Genmon is installed:

  ```bash
  dpkg -l | grep xfce4-genmon-plugin
  ```

### Speeds stay at zero

- Generate network traffic and wait for at least two refreshes.
- Check that the adapter is up:

  ```bash
  ip -br link
  ```

- Inspect kernel counters:

  ```bash
  cat /sys/class/net/eth0/statistics/rx_bytes
  cat /sys/class/net/eth0/statistics/tx_bytes
  ```

  Replace `eth0` with your interface name.

### Interface is not included

Check whether it has a device link:

```bash
ls -l /sys/class/net/INTERFACE/device
```

If it is virtual, use `NETSPEED_INCLUDE_VIRTUAL=1` and configure exclusions as needed.

## Uninstall

From the project directory:

```bash
./uninstall.sh
```

Then remove the Generic Monitor item from the XFCE panel if you added it.

## Contributing

Issues and pull requests are welcome. Please include your distribution, XFCE version, Genmon version, interface type, and relevant command output when reporting a bug. Do not include passwords, public IPs, or other sensitive information.

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
