#!/usr/bin/env bash
set -Eeuo pipefail
PREFIX="$HOME/.local/opt/ps3dee"
APP_ENTRY="$HOME/.local/share/applications/ps3dee.desktop"
APP_ICON="$HOME/.local/share/icons/hicolor/256x256/apps/ps3dee.png"
if [[ "$EUID" -eq 0 ]]; then
    echo "Run this as the desktop user, without sudo." >&2
    exit 1
fi
rm -rf -- "$PREFIX"
rm -f -- "$APP_ENTRY" "$APP_ICON"
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi
printf 'PS3DEE user files removed.\n'
printf 'The source checkout and APT build dependencies were left untouched.\n'
printf 'Remove the optional login session first with:\n'
printf '  sudo bash scripts/ps3dee-disable-session.sh\n'
