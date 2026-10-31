#!/usr/bin/env bash
set -Eeuo pipefail
if [[ "$EUID" -ne 0 ]]; then
    command -v sudo >/dev/null 2>&1 || { echo "sudo is required." >&2; exit 1; }
    exec sudo bash "$0" "$@"
fi
rm -f /usr/share/xsessions/ps3dee.desktop
rm -f /usr/local/bin/ps3dee-session
printf 'PS3DEE login option removed. Ubuntu, Openbox and Xorg were left installed.\n'
