#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "\${BASH_SOURCE[0]}")/.." && pwd)"
PREFIX="$HOME/.local/opt/ps3dee"
JOBS="\${PS3DEE_BUILD_JOBS:-2}"
INSTALL_DEPS=1
ENABLE_SESSION=0
LAUNCH=1

fail() { printf 'PS3DEE installer: %s\n' "$*" >&2; exit 1; }
usage() {
    cat <<'EOF'
PS3DEE preview installer
Usage: bash scripts/ps3dee-install.sh [options]
  --jobs N          Build with N parallel jobs (default: 2)
  --skip-deps       Do not install build dependencies with APT
  --enable-session  Also add the experimental PS3DEE X11 login session
  --no-launch       Build and install, but do not launch the dashboard
  -h, --help        Show this help
EOF
}
while (($#)); do
    case "$1" in
        --jobs) (($# >= 2)) || fail "--jobs needs a number"; JOBS="$2"; shift 2 ;;
        --skip-deps) INSTALL_DEPS=0; shift ;;
        --enable-session) ENABLE_SESSION=1; shift ;;
        --no-launch) LAUNCH=0; shift ;;
        -h|--help) usage; exit 0 ;;
        *) fail "unknown option: $1 (try --help)" ;;
    esac
done

[[ "$EUID" -ne 0 ]] || fail "run this script as your normal user, not with sudo"
[[ "$JOBS" =~ ^[1-9][0-9]*$ ]] || fail "--jobs must be a positive integer"
[[ -f "$ROOT_DIR/CMakeLists.txt" && -f "$ROOT_DIR/CMakePresets.json" ]] || fail "run this script from a PS3DEE checkout"
[[ -r /etc/os-release ]] || fail "cannot identify this Linux distribution"
# shellcheck disable=SC1091
. /etc/os-release
[[ "\${ID:-}" == "ubuntu" ]] || fail "this first installer currently supports Ubuntu 24.04 and 26.04 only"
case "\${VERSION_CODENAME:-}" in
    noble|resolute) ;;
    *) fail "unsupported Ubuntu release '\${VERSION_CODENAME:-unknown}'; use Ubuntu 24.04 LTS or 26.04 LTS" ;;
esac
[[ "$(dpkg --print-architecture)" == "amd64" ]] || fail "the first preview targets 64-bit x86 PCs (amd64)"

if ((INSTALL_DEPS)); then
    command -v sudo >/dev/null 2>&1 || fail "sudo is required to install build dependencies"
    printf '\n[1/5] Installing Ubuntu build dependencies...\n'
    sudo apt-get update
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential git cmake ninja-build pkg-config python3 \
        clang-19 clang-tools-19 lld-19 g++-14 \
        gettext locales \
        libarchive-dev zlib1g-dev libx11-dev libxtst-dev libcurl4-openssl-dev \
        libavcodec-dev libavformat-dev libavutil-dev libswresample-dev libswscale-dev \
        libfmt-dev libfreetype-dev libglm-dev libharfbuzz-dev libxmp-dev \
        fonts-noto-core fonts-noto-cjk \
        libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev \
        libvulkan-dev vulkan-utility-libraries-dev vulkan-tools \
        glslang-tools spirv-tools vulkan-validationlayers mesa-vulkan-drivers \
        libgtk-3-dev libwebkit2gtk-4.1-dev glib-networking bubblewrap xdg-dbus-proxy apparmor \
        ffmpeg poppler-utils xvfb xauth imagemagick
else
    printf '\n[1/5] Skipping APT dependency installation as requested.\n'
fi

for tool in cmake ninja clang-19 clang++-19 clang-scan-deps-19 g++-14; do
    command -v "$tool" >/dev/null 2>&1 || fail "required build tool '$tool' is missing; rerun without --skip-deps"
done
CMAKE_VERSION="$(cmake --version | awk 'NR == 1 {print $3}')"
dpkg --compare-versions "$CMAKE_VERSION" ge 3.28 || fail "CMake 3.28 or newer is required (found $CMAKE_VERSION)"
GCC14_TRIPLE="$(g++-14 -dumpmachine)"
GCC14_LIBDIR="/usr/lib/gcc/$GCC14_TRIPLE/14"
[[ -d "$GCC14_LIBDIR" ]] || fail "the GCC 14 C++ standard library was not found at $GCC14_LIBDIR"

mkdir -p "$PREFIX"
export CC=clang-19
export CXX=clang++-19
export CXXFLAGS="\${CXXFLAGS:+$CXXFLAGS }--gcc-install-dir=$GCC14_LIBDIR"

printf '\n[2/5] Configuring the OpenXMB shell...\n'
cd "$ROOT_DIR"
cmake --preset default \
    -DCMAKE_C_COMPILER=clang-19 \
    -DCMAKE_CXX_COMPILER=clang++-19 \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

printf '\n[3/5] Building (parallel jobs: %s)...\n' "$JOBS"
cmake --build --preset default --parallel "$JOBS"

printf '\n[4/5] Running registered CTest tests...\n'
ctest --test-dir "$ROOT_DIR/build/default" --output-on-failure

printf '\n[5/5] Installing into %s...\n' "$PREFIX"
cmake --install "$ROOT_DIR/build/default" --prefix "$PREFIX"
[[ -x "$PREFIX/bin/XMS" && -x "$PREFIX/bin/XMS.bin" ]] || fail "the expected XMS launcher or binary is missing after installation"

APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$APP_DIR" "$ICON_DIR"
if [[ -f "$ROOT_DIR/assets/shell/icons/branding/openxmb.png" ]]; then
    install -m 0644 "$ROOT_DIR/assets/shell/icons/branding/openxmb.png" "$ICON_DIR/ps3dee.png"
    ICON_NAME=ps3dee
else
    ICON_NAME=applications-games
fi
cat > "$APP_DIR/ps3dee.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=PS3DEE Preview
Comment=Open the PS3DEE XMB dashboard
Exec="$PREFIX/bin/XMS"
Icon=$ICON_NAME
Terminal=false
Categories=Game;Utility;
StartupNotify=false
EOF
chmod 0644 "$APP_DIR/ps3dee.desktop"
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

if ((ENABLE_SESSION)); then
    printf '\nAdding the optional standalone X11 login session...\n'
    sudo bash "$ROOT_DIR/scripts/ps3dee-enable-session.sh"
fi

printf '\nPS3DEE preview installed.\n'
printf 'Application menu entry: %s\n' "$APP_DIR/ps3dee.desktop"
printf 'Installed files:        %s\n' "$PREFIX"
printf 'Launch manually:        %s/bin/XMS\n' "$PREFIX"
printf 'Uninstall user files:   bash scripts/ps3dee-uninstall.sh\n'
if ((LAUNCH)); then
    printf '\nLaunching the dashboard preview...\n'
    "$PREFIX/bin/XMS" || printf '\nThe dashboard exited with an error. Run it from a terminal to see diagnostics.\n' >&2
fi
