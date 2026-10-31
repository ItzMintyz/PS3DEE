# PS3DEE — Proposed architecture

This document describes the intended system boundary around the existing
OpenXMB application. Components marked **planned** are design targets, not
implemented services.

## Session model

The target user flow is:

```text
UEFI firmware
    |
Ubuntu Linux + systemd
    |
Graphical login / PS3DEE session
    |
Display compositor (decision pending)
    |
OpenXMB dashboard
    |
    +---- launch ----> Application Supervisor
    |                       |
    |                       +---- fullscreen foreground application
    |                       |
    +<--- application exits / return-home action
```

The dashboard should remain alive while an application is foregrounded so that
its navigation position, library selection and transient state can be restored.
System services continue running in the background; “one foreground app” does
not mean shutting down networking, audio, updates or other required services.

## 1. Base operating system

**Selected direction:** Ubuntu 26.04 LTS, x86-64 and UEFI for the first target.

Use the distribution's kernel, systemd, Mesa/Vulkan drivers, PipeWire, APT and
existing hardware support. Snap is supported as part of the chosen Ubuntu base;
Flatpak is optional and should be integrated only where it improves application
availability.

PS3DEE should not implement its own kernel, init system, package manager,
graphics driver stack or compositor. The custom work belongs in the graphical
session, application lifecycle, input policy, catalogue and image integration.

## 2. Graphical session and compositor — planned

A dedicated graphical session is required. The compositor is responsible for
display ownership, fullscreen surfaces, focus and compatibility with native
Wayland and XWayland applications.

A Wayland-first approach is preferred, but the compositor is **not selected**.
Evaluate lightweight and full-featured options (including labwc and KWin) against
the same test matrix before committing. Do not choose one based only on
appearance or package size.

The test matrix must include:

- OpenXMB's Vulkan/SDL window and input behavior.
- Steam and other game launchers, including games that use XWayland.
- GTK and Qt applications, file pickers and authentication prompts.
- xdg-desktop-portal integration and screen capture.
- Multiple displays, resolution changes, suspend/resume and controller hot-plug.
- Returning focus to the dashboard after an application exits or crashes.

GNOME Shell and KDE Plasma are not the intended user experience. Their
application toolkits and individual applications may still be used without
running their complete desktop sessions.

## 3. Dashboard — existing OpenXMB foundation

OpenXMB remains the dashboard and visual foundation. Its current codebase uses
C++23 modules, CMake, Vulkan, SDL2 and AuroreEngine. It already contains menu,
theme, profile, media and application integration code.

The initial strategy is to build and test the existing application as-is. Then
add narrow integration points for session state, Hivemind and the supervisor.
Avoid a broad rewrite or bulk rename of upstream identifiers before there is a
working baseline.

The application currently has its own controller handling and an emulator host
with multi-gamepad support. Hivemind must integrate with these paths rather than
compete with them or break existing mappings.

## 4. Hivemind — planned shared input layer

Hivemind is the common input layer for the dashboard and supported applications.

Intended responsibilities:

- Discover controllers and input devices, including hot-plug and disconnects.
- Normalize device events and mappings across Xbox, PlayStation, Nintendo,
  8BitDo and generic HID devices where the operating system exposes them.
- Give every connected controller equal standing; do not hard-code Player 1 as
  the privileged dashboard controller.
- Route input to an explicit destination: dashboard, foreground application,
  emulator or another registered target.
- Support configurable system actions, including a user-mappable
  Return-to-Dashboard action.
- Expose device identity and connection state for diagnostics and settings.

Conceptual path:

```text
Controller / HID device
        |
Device discovery + mapping
        |
Normalized event stream
        |
Hivemind routing policy
        +----> Dashboard
        +----> Foreground application
        +----> Emulator / registered input target
```

Hivemind must not indiscriminately grab every controller event. A game must
continue receiving gameplay input. System shortcuts need an explicit, configurable
routing mechanism, and hardware-specific Guide/Home behavior must be tested rather
than assumed.

Simultaneous conflicting navigation input from multiple controllers needs a
documented deterministic policy. No player hierarchy should be introduced as a
shortcut for resolving that design question.

## 5. Application Supervisor — planned

The supervisor owns the lifecycle of applications launched from the dashboard.

Responsibilities:

- Resolve a catalogue entry to a provider-specific launch request.
- Launch the application as the logged-in user, never as root.
- Place the application in a tracked process group or systemd user scope/cgroup.
- Ask the compositor/session to make it the foreground fullscreen experience.
- Keep the dashboard state available while the application runs.
- Detect normal exit, crash and launch failure.
- Restore the dashboard and return input focus when the foreground application
  ends or the user invokes the configured home action.
- Avoid terminating unrelated system services or background applications.

The implementation mechanism (D-Bus service, user service, library or a small
combination) is still open. The lifecycle contract should be specified before
choosing the mechanism.

## 6. Application and game catalogue — planned extension

Keep the user-facing catalogue independent from individual storefronts. Use
provider adapters to discover and launch entries from sources such as:

- Native Linux desktop applications and manually added commands.
- Steam.
- GOG and Epic titles through supported third-party tooling where available.
- Flatpak and Snap applications.
- Emulators and user-provided game files.

Each catalogue entry should describe its provider, stable identifier, title,
artwork/metadata, install state, launch request, compatibility notes and
available actions. Avoid duplicating entries when a game is exposed by more than
one source.

Provider adapters must respect the source platform's authentication, purchase,
licensing and DRM requirements. A unified front end does not imply that every
game can be installed or launched without its provider.

## 7. Storefront — later planned layer

A PS3DEE storefront can eventually present discovery, metadata and install
actions in one console-style interface. Initially it should coordinate existing
providers rather than invent a new game distribution or payment system.

The store must be clear about which provider handles a purchase or installation,
and should not imply that PS3DEE owns or redistributes third-party game content.

## 8. Desktop application compatibility

The environment should be able to launch useful desktop applications without
exposing a conventional desktop as the primary interface. Reuse existing GTK and
Qt applications and the services they require.

Compatibility work includes portals, file chooser dialogs, authentication
prompts, clipboard behavior, notifications, accessibility and XWayland. GNOME
Shell and Plasma are not required merely to run their respective applications.

## 9. Packaging and system integration — planned

Only after the session and lifecycle work is stable should PS3DEE add system
packages, session entries, defaults, recovery behavior and an Ubuntu-based
installer/image.

The installer must preserve a usable recovery path and must not make a custom
session the only way to access the machine during development. VM testing comes
before installation on physical hardware.

## Open design decisions

- Which compositor and display/session manager satisfy the compatibility matrix?
- Should Hivemind begin as an in-process library, a user service, or both?
- Which IPC and lifecycle contract should the supervisor expose?
- How should Return-to-Dashboard be mapped without stealing a game's controls?
- Which provider adapters belong in the first library milestone?
- What is the smallest useful first installer/image scope?
