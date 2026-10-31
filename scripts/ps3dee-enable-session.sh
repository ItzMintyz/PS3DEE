#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "\${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "$EUID" -ne 0 ]]; then
    command -v sudo >/dev/null 2>&1 || { echo "sudo is required." >&2; exit 1; }
    exec sudo bash "$0" "$@"
fi
REAL_USER="\${SUDO_USER:-}"
[[ -n "$REAL_USER" && "$REAL_USER" != "root" ]] || {
    echo "Run this with sudo from the desktop user's account, not from a root login." >&2
    exit 1
}
USER_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
[[ -n "$USER_HOME" && -x "$USER_HOME/.local/opt/ps3dee/bin/XMS" ]] || {
    echo "PS3DEE was not found under $USER_HOME/.local/opt/ps3dee." >&2
    echo "Run scripts/ps3dee-install.sh as $REAL_USER first." >&2
    exit 1
}
command -v apt-get >/dev/null 2>&1 || { echo "APT is required." >&2; exit 1; }
printf 'Installing Xorg and the lightweight Openbox window manager...\n'
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends xserver-xorg openbox
install -Dm0755 "$ROOT_DIR/scripts/ps3dee-session" /usr/local/bin/ps3dee-session
install -Dm0644 "$ROOT_DIR/share/xsessions/ps3dee.desktop" /usr/share/xsessions/ps3dee.desktop
printf '\nPS3DEE login session added.\n'
printf 'Log out, open the login-screen session chooser, and select "PS3DEE (Preview)".\n'
printf 'Your existing Ubuntu session has not been removed or changed.\n'
printf 'Remove the login option with: sudo bash scripts/ps3dee-disable-session.sh\n'
