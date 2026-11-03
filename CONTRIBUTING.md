# Contributing

Thanks for considering a contribution!

## Before opening an issue

- Check whether the issue already exists.
- Include your distribution, kernel, XFCE and `xfce4-genmon-plugin` versions.
- Include `ip -br link` output with sensitive details removed.
- Describe whether the affected interface is physical, virtual, bridged, bonded or routed.

## Pull requests

- Keep the monitor lightweight and dependency-free where practical.
- Preserve compatibility with Bash available on supported Debian/Kali systems.
- Test shell syntax with `bash -n src/netspeed-xfce.sh install.sh uninstall.sh`.
- Test the script on at least one physical interface and, if possible, one virtual interface.
- Update README and CHANGELOG when behavior or user-facing options change.

## Style

Use clear variable names, quote expansions, and explain non-obvious interface handling. Do not add telemetry or transmit user data.
