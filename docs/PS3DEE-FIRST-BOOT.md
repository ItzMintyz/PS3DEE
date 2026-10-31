# PS3DEE first boot preview

This is the first runnable PS3DEE system prototype. It builds the existing
OpenXMB shell, installs it into the current user's home directory, and can add
an optional standalone X11 login session.

It is **not yet a bootable ISO or a finished distribution**. The first target
is Ubuntu 26.04 LTS (Resolute) on amd64; Ubuntu 24.04 LTS (Noble) is also
supported by the initial build script.

## 1. Build and launch the dashboard

Open a terminal in Ubuntu and run:

```bash
git clone --branch ps3dee/project-foundation https://github.com/ItzMintyz/PS3DEE.git
cd PS3DEE
bash scripts/ps3dee-install.sh
```

The installer:
- Installs the documented Clang 19 / GCC 14, CMake, Vulkan, SDL2, FFmpeg,
  WebKitGTK and other development dependencies through APT.
- Configures the upstream default CMake preset and builds with two jobs by
  default (use --jobs 1 on memory-limited machines).
- Runs the tests registered with CTest.
- Installs the application and its runtime assets under
  ~/.local/opt/ps3dee.
- Adds a PS3DEE Preview application entry to the normal app menu.
- Launches the dashboard after a successful build and install.

Useful alternatives:

```bash
bash scripts/ps3dee-install.sh --no-launch
bash scripts/ps3dee-install.sh --jobs 1
```

## 2. Add PS3DEE to the login-screen session chooser

After the preview installs successfully, run:

```bash
sudo bash scripts/ps3dee-enable-session.sh
```

This installs Xorg and Openbox, then adds PS3DEE (Preview) to
/usr/share/xsessions. It does not remove GNOME, change the default Ubuntu
session, or make PS3DEE the automatic login.

Log out. At the login screen, open the session chooser (usually the gear icon)
and select PS3DEE (Preview). Choose Ubuntu again to return to the original
desktop.

The session starts Openbox as a lightweight window manager and launches the
OpenXMB dashboard fullscreen. The dashboard remains behind applications opened
from its Applications menu; closing an application should reveal the dashboard
again. The session is X11-only at this stage.

To remove only the PS3DEE login option:

```bash
sudo bash scripts/ps3dee-disable-session.sh
```

This leaves Ubuntu, Openbox and Xorg installed.

## 3. Remove the preview

```bash
bash scripts/ps3dee-uninstall.sh
```

This removes only the PS3DEE files installed in the current user's home
directory. It does not uninstall the build dependencies or delete the source
checkout.

## Current limits

- The OpenXMB application is the existing upstream dashboard, not yet a deeply
  customized PS3DEE interface.
- The standalone session is experimental and currently uses Xorg + Openbox;
  a Wayland compositor/session has not been selected.
- There is no custom installer, live ISO, package repository, first-run wizard,
  dedicated settings centre, application supervisor or unified game store yet.
- Controller hot-plug and consistent controller ownership still need focused
  integration work.
- The scripts have been committed, but no Ubuntu desktop build or physical-GPU
  test was run in this environment. A successful local build and session test
  are still required before calling this a validated release.

The existing Ubuntu desktop remains available as the recovery path throughout
this preview.
