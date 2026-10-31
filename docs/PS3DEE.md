# PS3DEE — Project overview

**PS3DEE** is a planned, open-source, controller-first Linux desktop environment
with a PlayStation 3-inspired XrossMediaBar experience.

The idea is to make a computer behave more like a console: the machine starts
into a dashboard, the dashboard is the primary navigation surface, applications
open as focused fullscreen experiences, and leaving an application returns the
user to the dashboard. A keyboard and mouse remain supported, but normal system
operation should not require them.

PS3DEE is being developed as a downstream project built around
[OpenXMB](https://github.com/phenom64/OpenXMB). It is not a rewrite of OpenXMB and
does not claim authorship of the upstream work.

## Product goals

1. **Dashboard-first session.** Start a dedicated graphical session with the
   XMB shell as the home surface. Avoid a conventional desktop full of panels,
   desktop icons and overlapping windows.
2. **Controller-first operation.** Navigation, launching, settings, search,
   power actions and returning home must be usable from a controller.
3. **Hivemind input.** Treat connected controllers as equal devices. Support
   hot-plugging, consistent mappings and deliberate routing of input to either
   the dashboard or the foreground application. There is no privileged
   Player 1 controller.
4. **Reliable application handoff.** Launch an application, give it the
   foreground, preserve dashboard state, and restore the dashboard when the
   application exits.
5. **One library.** Present games from multiple providers and local sources in
   one navigable library, without pretending that provider authentication,
   DRM or installation requirements disappear.
6. **A practical Linux base.** Reuse the Linux kernel, systemd, graphics drivers,
   audio stack, package management and existing desktop application toolkits.
   PS3DEE is a desktop environment and system integration project, not a new
   kernel or package manager.

## Planned base platform

The current project direction is:

- Ubuntu 26.04 LTS as the initial distribution base.
- x86-64 PCs with UEFI as the first target.
- Ubuntu's normal Linux kernel, systemd, Mesa/Vulkan and PipeWire stack.
- APT as the system package manager, with Snap support and optional Flatpak
  support where useful.
- A dedicated graphical session rather than GNOME Shell or KDE Plasma as the
  main user experience.

The exact display manager, Wayland compositor and session integration are not
selected yet. Candidate compositor/session approaches must be tested with
OpenXMB, games, GTK applications, portals and XWayland before a decision is made.

## What the fork already provides

The upstream OpenXMB codebase is a substantial starting point. Its existing
documentation describes:

- A native C++23, Vulkan and SDL2 XMB-style shell using AuroreEngine.
- Horizontal categories, menus, themes, profiles and persistent settings.
- Music, photos, documents and video features.
- Application discovery from desktop entries, plus game-folder/manifest and
  RPCS3 library workflows.
- A software-rendering libretro host with controller input.
- Optional browser and optical-media integrations.
- Linux, Windows and macOS build and packaging workflows.

These are upstream application capabilities. They do **not** by themselves mean
that PS3DEE already has a complete operating-system session, compositor policy,
system-wide controller service, application supervisor or bootable ISO.

## What PS3DEE adds

The downstream work is to design, implement and validate the system around the
existing shell:

- A dedicated login-to-dashboard session.
- **Hivemind**, the shared controller discovery, mapping and input-routing layer.
- An application supervisor for fullscreen handoff, process tracking and return
  to the dashboard.
- A provider-based application and game catalogue.
- A consistent system-app experience, including file picking, authentication
  prompts and compatibility with GTK/Qt applications.
- Packaging, installation and eventually a custom Ubuntu-based image.

The roadmap records these as planned work, not completed features.

## Project boundaries

- Keep the existing OpenXMB implementation and its upstream history intact.
- Preserve all existing copyright notices, acknowledgements, license files and
  third-party license boundaries.
- Make PS3DEE-specific changes in clearly scoped commits and keep the fork
  synchronisable with upstream.
- Do not bundle commercial games, ROMs, BIOS files, firmware or other content
  that the project does not have permission to redistribute.
- Do not bypass storefront authentication or game DRM.
- Use original project artwork and branding; do not present PS3DEE as an official
  Sony or PlayStation product.

## Current engineering status

The repository is a fork of OpenXMB and the initial source/documentation survey
has been recorded. This documentation commit does not claim that the upstream
application has been compiled or tested as a PS3DEE session. The first technical
gate is to reproduce the existing build and runtime in a clean Ubuntu test
environment before changing core application behavior.
