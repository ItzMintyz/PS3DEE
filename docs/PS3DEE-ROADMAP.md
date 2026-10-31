# PS3DEE — Development roadmap

This roadmap separates existing OpenXMB functionality from new PS3DEE system
work. A milestone is complete only when its exit criteria are met and documented.

## Phase 0 — Establish a reproducible baseline

**Status: in progress**

- [x] Create the PS3DEE fork of phenom64/OpenXMB.
- [x] Record the project purpose and the boundary between upstream shell
      functionality and PS3DEE operating-system work.
- [x] Survey the upstream build requirements, features and documented limits.
- [ ] Build the unmodified upstream baseline in a clean Ubuntu test VM.
- [ ] Run the upstream test suite and desktop smoke checks.
- [ ] Record the exact toolchain, dependencies, build result and known failures.

**Exit criteria:** a repeatable build and launch procedure exists, and the
original dashboard works before PS3DEE-specific runtime changes begin.

## Phase 1 — Dashboard session proof of concept

**Status: planned**

- [ ] Select a compositor/session approach using the architecture test matrix.
- [ ] Create a dedicated PS3DEE session entry.
- [ ] Start OpenXMB as the session's dashboard.
- [ ] Verify Vulkan presentation, controller navigation and clean session exit.
- [ ] Preserve a fallback desktop/session for recovery during development.

**Exit criteria:** a user can log into the PS3DEE session and reach the dashboard
without manually starting it from a conventional desktop.

## Phase 2 — Hivemind input foundation

**Status: planned**

- [ ] Document device identity, normalized events and mapping format.
- [ ] Define the input destination and routing contract.
- [ ] Prototype discovery, hot-plug and multiple equal controllers.
- [ ] Integrate with OpenXMB navigation without breaking its current SDL input.
- [ ] Verify that a foreground game retains gameplay input.
- [ ] Implement a configurable Return-to-Dashboard action with safe focus rules.

**Exit criteria:** all dashboard operations are controller-accessible, multiple
controllers can operate the interface, and game input is not stolen by global
system handling.

## Phase 3 — Application Supervisor

**Status: planned**

- [ ] Specify launch, foreground, exit, crash and return states.
- [ ] Prototype tracked application launches as the logged-in user.
- [ ] Integrate fullscreen/focus behavior with the selected compositor.
- [ ] Restore dashboard state after normal exit and application crash.
- [ ] Verify process tracking does not kill unrelated background services.

**Exit criteria:** dashboard-launched applications reliably take the foreground
and the user returns to the dashboard when they finish.

## Phase 4 — System application compatibility

**Status: planned**

- [ ] Validate file pickers, portals and authentication prompts.
- [ ] Test GTK and Qt applications outside GNOME Shell and Plasma sessions.
- [ ] Test XWayland applications and common game launchers.
- [ ] Add polished controller navigation for common system workflows.
- [ ] Document unsupported applications and compatibility workarounds.

**Exit criteria:** common file, settings, browser and utility workflows work
without requiring a conventional desktop session.

## Phase 5 — Unified applications and game library

**Status: planned**

- [ ] Define the provider-neutral catalogue schema.
- [ ] Build the local desktop-entry/native-game provider.
- [ ] Integrate Steam discovery and launch.
- [ ] Evaluate GOG, Epic, Flatpak, Snap and emulator adapters.
- [ ] Add artwork, metadata, install state, favorites and duplicate resolution.
- [ ] Add a provider-aware discovery/store experience after launch flows are
      reliable.

**Exit criteria:** supported sources can be browsed and launched from one
controller-friendly library, with provider requirements clearly represented.

## Phase 6 — Distribution and installer

**Status: planned**

- [ ] Define package boundaries and default system services.
- [ ] Package the session, Hivemind and supervisor.
- [ ] Add safe update, rollback and recovery behavior.
- [ ] Build a reproducible Ubuntu-based image and installer.
- [ ] Test install, first boot, updates and recovery in virtual machines.
- [ ] Publish hardware compatibility notes and checksums.

**Exit criteria:** a new VM can install and boot into PS3DEE, update safely and
recover to a usable system if the custom session fails.

## Phase 7 — Hardware validation and release

**Status: planned**

- [ ] Test integrated and discrete GPUs with Vulkan.
- [ ] Test common Xbox, PlayStation, Nintendo, 8BitDo and generic controllers.
- [ ] Test suspend/resume, audio devices, multiple displays and game focus.
- [ ] Measure dashboard responsiveness and application handoff on real hardware.
- [ ] Document supported hardware and limitations before declaring a release.

**Exit criteria:** release claims are backed by reproducible hardware test
results rather than assumptions based on successful compilation.

## Working rule

Do not build the ISO first. First prove the existing OpenXMB baseline, then the
dedicated graphical session, then Hivemind and application supervision. Packaging
comes after these foundations work together.
