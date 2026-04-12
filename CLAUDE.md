# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

**shaughvOS** — a custom operating system currently built on a [DietPi](https://github.com/MichaIng/DietPi) (lightweight Debian) foundation. The long-term goal is a **complete rebrand** — when finished, all DietPi references will be gone and the OS will be entirely shaughvOS. This repo is a demonstration of using Claude Code to fully customize an operating system.

See `QUBETX_INTEGRATION.md` for the full aspirational goals document covering all planned features.

## Target Hardware

- **Raspberry Pi 4** (primary) — aarch64
- **x86_64 PCs / laptops** — dual-boot or USB boot
- **Intel Macs** — native USB boot (Apple Silicon via VM only)
- **Live USB** — stretch goal

## Bundled Software & Experience

### QubeTX 300 Series (pre-installed on first boot)
- **TR-300** (`tr300`) — Machine report. Auto-runs on every terminal session via `--fast` flag.
- **ND-300** (`nd300` + `speedqx`) — Network diagnostics + quad-provider speed test.
- **SD-300** (`sd300`) — Real-time interactive system diagnostic TUI.
- Repos: `QubeTX/qube-machine-report`, `QubeTX/qube-network-diagnostics`, `QubeTX/qube-system-diagnostics`

### Desktop Environment
- **Xfce** (software ID 25) — default desktop, auto-login on boot
- **Dracula theme** — GTK, terminal, window manager, icons
- **Makira** — system UI sans-serif font (`assets/fonts/Makira/`)
- **IBM Plex Mono** — terminal/monospace font (`assets/fonts/IBMPlexMono/`)
- **Desktop wallpaper:** `assets/desktop_background.jpg`
- **`desktop on/off`** — simple terminal commands to toggle between desktop and CLI mode

### Boot & Terminal Experience
1. **Boot splash:** SHAUGHV logo (white on black) via Plymouth (`assets/shaughv-logo.svg`, rendered white for dark boot screen)
2. **Terminal session:** ASCII art shaughvOS splash, then TR-300 machine report
3. All custom commands get proper **man pages** and `--help` flags

## Assets

```
assets/
  shaughv-logo.svg         Official OS logo / boot splash source
  desktop_background.jpg   Default Xfce wallpaper
  fonts/
    Makira/                System UI font (6 weights, TTF)
    IBMPlexMono/           Terminal font (7 weights + italics, TTF)
```

## Branch System

- `master` — stable release
- `beta` — pre-release public testing
- `dev` — active development; **PRs must target `dev`**

## Linting

ShellCheck is the only linter, run on every push/PR via CI (`.github/workflows/shellcheck.yml`).

**Run locally** (mirrors CI exactly):
```bash
shellcheck -C -xo all <file(s)>
```

CI also enforces:
- No trailing whitespace
- No triple-or-more consecutive blank lines

**Disabled ShellCheck rules** (`.shellcheckrc`): `SC2004,SC2119,SC2155,SC2188,SC2243,SC2244,SC2250,SC2312,SC2317`

## Codebase Architecture

### Key Directories

- `dietpi/` — User-facing tools (`dietpi-config`, `dietpi-software`, `dietpi-update`, etc.). All extensionless Bash scripts.
- `dietpi/func/` — Shared library functions. The critical file is `dietpi-globals`.
- `dietpi/misc/` — Helper scripts.
- `rootfs/` — Files overlaid onto the system root at install time (systemd units, apt config, cron jobs, sysctl, bashrc.d).
- `.update/` — Versioning (`version`), incremental migration patches (`patches`, `pre-patches`).
- `.meta/` — Supplementary migration scripts, not deployed to devices.
- `assets/` — shaughvOS branding: logo, wallpaper, fonts.
- `dietpi.txt` — First-boot automation config (deployed to `/boot/`). Key=value settings scraped by programs.

### dietpi-globals — The Foundation

Every script begins with:
```bash
. /boot/dietpi/func/dietpi-globals
readonly G_PROGRAM_NAME='DietPi-SomeTool'
G_CHECK_ROOT_USER "$@"
G_CHECK_ROOTFS_RW
G_INIT
```

Key `G_*` function families:
- **`G_EXEC`** — Wrapped command execution with error handling
- **`G_WHIP`** — Whiptail dialog wrappers (`G_WHIP_YESNO`, `G_WHIP_MENU`, etc.)
- **`G_DIETPI-NOTIFY`** — Formatted console output (levels 0-3, hierarchy support)
- **`G_CHECK_*`** — Precondition checks (root, rootfs R/W, etc.)
- **`G_HW_*`** — Hardware model/memory/revision variables (populated from `/boot/dietpi/.hw_model`)

**Critical convention**: Always use `local` for index variables in `for`/`while` loops, or `unset` them afterwards. Failure causes hard-to-debug issues (see: MichaIng/DietPi#1454).

### Software Installation

`dietpi/dietpi-software` is the main installer. Software is identified by numeric IDs. New software follows the pattern: register metadata with `aSOFTWARE_NAME`/`aSOFTWARE_DESC`/`aSOFTWARE_CATX`, add install block with `To_Install <ID>`, add uninstall block with `To_Uninstall <ID>`. Use `Download_Install` for GitHub release binaries. See File Browser (ID 198) and DietPi-Dashboard (ID 200) as reference implementations.

### Update / Patch System

`dietpi-update` orchestrates updates:
1. Fetches `.update/version` from remote branch (version numbers + live patch arrays)
2. Runs `.update/pre-patches` (before APT/code updates)
3. Pulls new code from GitHub
4. Runs `.update/patches` (incremental, version-gated migrations)

### Boot Sequence

Systemd services: `dietpi-fs_partition_resize` -> `dietpi-preboot` -> `dietpi-firstboot` (first run only) -> `dietpi-postboot`. Interactive shells source `dietpi-globals` via `/etc/bashrc.d/dietpi.bash`. Desktop autostart controlled by `dietpi-autostart` (index stored in `/boot/dietpi/.dietpi-autostart_index`).

## Current Version

Based on DietPi v10.2 RC3 (`.update/version`). Minimum upgrade path: v8.0+, Debian 7+.
