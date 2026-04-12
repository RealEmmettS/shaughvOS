# QubeTX 300 Series — shaughvOS Integration Report

This document captures research findings for integrating the QubeTX 300 Series diagnostic tools into shaughvOS. This is a reference for future development sessions — no code changes have been made yet. This is an aspirational goals document, not an implementation plan.

## About shaughvOS

shaughvOS is a next-generation custom operating system. It currently uses DietPi as its foundation (lightweight Debian for SBCs), but the long-term vision is a **complete rebrand** — when finished, all DietPi references will be replaced and the OS will be entirely shaughvOS-branded. This repo is a demonstration of using Claude Code to fully customize an operating system.

The QubeTX 300 Series tools will be bundled as default software, pre-installed on first boot, as part of the core shaughvOS experience.

---

## The QubeTX 300 Series

Three cross-platform Rust CLI tools forming a complete diagnostic suite:

### TR-300 Machine Report (`qube-machine-report`)
- **Repo:** https://github.com/QubeTX/qube-machine-report
- **Binary name:** `tr300`
- **Latest release:** v3.8.0
- **Purpose:** System information report — OS, kernel, hostname, IP addresses, DNS servers, CPU load/memory/disk bar graphs, hypervisor/virtualization detection, session info with last login tracking.
- **Output modes:** Unicode box-drawing tables (default), ASCII fallback, JSON, auto-save markdown.
- **Key flags:** `--fast` (sub-second for auto-run), `--install` (sets up `report` shell alias + auto-run on login), `--json`, `--ascii`
- **Login integration:** TR-300 has a built-in `--install` flag that adds itself to the shell profile as a login report, similar to `dietpi-banner`. This is a natural replacement or supplement to the DietPi banner on shaughvOS.

### ND-300 Network Diagnostic (`qube-network-diagnostics`)
- **Repo:** https://github.com/QubeTX/qube-network-diagnostics
- **Binary names:** `nd300` (diagnostics) + `speedqx` (standalone speed test)
- **Latest release:** v2.8.0
- **Purpose:** Network diagnostics with two modes:
  - **User mode:** 8 core checks — adapters, interfaces, gateway, DNS, public IP, latency, speed test, port connectivity
  - **Technician mode (-t):** 17 deep diagnostics — ARP, routing, connections, listening ports, DHCP, protocol stats, adapter hardware, proxy, VPN, firewall, DNS cache, IPv6, MTU, connection states, bufferbloat, reverse DNS, TLS inspection, traffic counters
- **SpeedQX:** Quad-provider speed test (Cloudflare + M-Lab NDT7 + LibreSpeed + fast.com) with volume-weighted aggregation, bufferbloat grading (A+ through F)
- **Key flags:** `-t` (technician mode), `-d` (DNS config), `-f` (multi-stage network fix), `--fast` (skip speed test), `--json`

### SD-300 System Diagnostic (`qube-system-diagnostics`)
- **Repo:** https://github.com/QubeTX/qube-system-diagnostics
- **Binary name:** `sd300`
- **Latest release:** v1.3.0
- **Purpose:** Real-time interactive TUI for system monitoring with 9 sections (Overview, CPU, Memory, Disk, GPU, Network, Processes, Thermals, Drivers). Two modes:
  - **User mode:** Plain language health status, color-coded indicators
  - **Technician mode:** Raw data, per-core utilization, sparkline graphs, sortable process tables
- **Key flags:** `--user`, `--tech`

---

## Available Release Artifacts (Linux)

All three tools use `cargo-dist` for automated releases via GitHub Actions.

| Tool | `aarch64-unknown-linux-gnu` | `x86_64-unknown-linux-gnu` | `x86_64-unknown-linux-musl` | `armv7l` | `armv6l` | `riscv64` |
|------|:---:|:---:|:---:|:---:|:---:|:---:|
| TR-300 | YES | YES | YES | NO | NO | NO |
| ND-300 | YES | YES | YES | NO | NO | NO |
| SD-300 | YES | YES | YES | NO | NO | NO |

### shaughvOS Architecture Support

shaughvOS (DietPi base) supports these Linux architectures:

| Arch ID | `G_HW_ARCH` | `G_HW_ARCH_NAME` | Coverage |
|---------|-------------|-------------------|----------|
| 1 | `armv6l` | Raspberry Pi Zero/1 | NOT COVERED |
| 2 | `armv7l` | Many SBCs (RPi 2/3 32-bit, Orange Pi, etc.) | NOT COVERED |
| 3 | `aarch64` | RPi 3/4/5 64-bit, most modern SBCs | COVERED |
| 10 | `x86_64` | PCs, VMs, NUC, etc. | COVERED |
| 11 | `riscv64` | RISC-V boards | NOT COVERED |

**Gap:** `armv7l` is the biggest missing target — many popular SBCs run 32-bit ARM. Adding `armv7-unknown-linux-gnueabihf` to the `cargo-dist` CI matrix in each tool's repo would close the most important gap. `armv6l` (RPi Zero/1) and `riscv64` are niche but nice-to-have.

---

## Integration Approach

### How `dietpi-software` Installs Prebuilt Binaries

The pattern is well-established. Here is the exact flow used by similar Rust/Go binary installs (File Browser ID=198, DietPi-Dashboard ID=200):

#### 1. Register the software ID (metadata section, ~line 230-1213)

```bash
software_id=<FREE_ID>
aSOFTWARE_NAME[$software_id]='TR-300'
aSOFTWARE_DESC[$software_id]='QubeTX machine report'
aSOFTWARE_CATX[$software_id]=8  # Category 8 = "System Stats & Management"
aSOFTWARE_DOCS[$software_id]='https://reports.qubetx.com/'
# Restrict to architectures with available binaries:
aSOFTWARE_AVAIL_G_HW_ARCH[$software_id,1]=0  # No armv6l
aSOFTWARE_AVAIL_G_HW_ARCH[$software_id,2]=0  # No armv7l (until builds added)
aSOFTWARE_AVAIL_G_HW_ARCH[$software_id,11]=0 # No riscv64
```

#### 2. Install block (in the install section)

The arch mapping pattern from File Browser (line ~11514):

```bash
if To_Install <ID> # TR-300
then
    # Map DietPi arch to GitHub release target triple
    case $G_HW_ARCH in
        3)  local arch='aarch64-unknown-linux-gnu';;
        *)  local arch='x86_64-unknown-linux-gnu';;
    esac

    # Fetch latest release tag from GitHub API
    local ver=$(curl -sSfL 'https://api.github.com/repos/QubeTX/qube-machine-report/releases/latest' | grep -Po '"tag_name": *"\K[^"]+')
    local fallback_url="https://github.com/QubeTX/qube-machine-report/releases/download/v3.8.0/tr-300-$arch.tar.xz"

    # Download and extract
    Download_Install "https://github.com/QubeTX/qube-machine-report/releases/download/$ver/tr-300-$arch.tar.xz" /usr/local/bin/

    G_EXEC chmod +x /usr/local/bin/tr300
fi
```

#### 3. Uninstall block

```bash
if To_Uninstall <ID> # TR-300
then
    [[ -f '/usr/local/bin/tr300' ]] && G_EXEC rm /usr/local/bin/tr300
fi
```

#### 4. Repeat for ND-300 and SD-300

Same pattern with their respective repo URLs and binary names (`nd300`, `speedqx`, `sd300`).

### Finding Free Software IDs

Run on a live shaughvOS system:
```bash
dietpi-software free
```

Or scan `dietpi-software` for unused IDs between existing entries. Three consecutive free IDs are needed.

### First-Boot Automation via `dietpi.txt`

In `dietpi.txt`, the `AUTO_SETUP_INSTALL_SOFTWARE_ID` setting installs software non-interactively on first boot:

```
AUTO_SETUP_AUTOMATED=1
AUTO_SETUP_INSTALL_SOFTWARE_ID=<TR300_ID> <ND300_ID> <SD300_ID>
```

For shaughvOS as a custom OS image, these IDs would be baked into `dietpi.txt` so the tools install automatically on every fresh boot.

### Login / Terminal Session Integration

Every new interactive terminal session in shaughvOS will display, in order:

1. **ASCII art shaughvOS splash** — A branded ASCII art logo/banner displayed instantly on shell init
2. **TR-300 machine report** — Runs via `tr300 --fast` immediately after the splash

Both are pre-configured in the OS image — no manual setup by the user.

#### ASCII Splash

A small, fast ASCII art display showing the shaughvOS identity. This is a simple `cat` or `echo` of a static file — zero overhead. Example concept:

```
     _                       _       ___  ____
 ___| |__   __ _ _   _  __ _| |__   / _ \/ ___|
/ __| '_ \ / _` | | | |/ _` | '_ \ | | | \___ \
\__ \ | | | (_| | |_| | (_| | | | || |_| |___) |
|___/_| |_|\__,_|\__,_|\__, |_| |_| \___/|____/
                       |___/
```

The ASCII art file would live at a fixed path (e.g., `/boot/shaughvos/.ascii_banner` or `/etc/shaughvos-banner`) and be `cat`'d by the shell init script before calling `tr300 --fast`. This keeps the splash static and instant — no computation, just a file read.

Options for generating the final art:
- `figlet` / `toilet` with a font like `slant`, `small`, or `standard`
- Hand-crafted ASCII art incorporating the SHAUGHV brandmark style
- Could include version number pulled from a version file

#### TR-300 Auto-Run

TR-300 is pre-configured to run on every terminal session. The `--fast` flag keeps startup sub-second. This replaces the DietPi banner as the default terminal greeting.

#### Implementation

The cleanest approach is to add a new `rootfs/etc/bashrc.d/shaughvos.bash` (or modify the existing `dietpi.bash`) that:
1. `cat`s the ASCII art file
2. Calls `tr300 --fast` (if installed and available)
3. Optionally prints a one-liner with version/hostname

This runs on every interactive shell init, same hook point that DietPi currently uses for its banner via `dietpi-login`.

---

## Target Hardware

shaughvOS aims to run on:

| Target | Architecture | Notes |
|--------|-------------|-------|
| **Raspberry Pi 4** (primary) | `aarch64` | Main SBC target. 2-8GB RAM. |
| **x86_64 PCs / laptops** | `x86_64` | Windows laptops dual-booted or booted from USB. |
| **Mac** (stretch goal) | `x86_64` or `aarch64` | Intel Macs via USB boot or VM. Apple Silicon Macs are harder (no native Linux boot without Asahi Linux patchset), but possible via VM (UTM/Parallels). |
| **Live USB** (stretch goal) | `x86_64` / `aarch64` | Boot without installing — persistence optional. |

### Live USB Feasibility

DietPi already ships x86_64 images that can be written to USB and booted on PCs/laptops. The path to a live USB is:
1. Use the existing DietPi x86_64 UEFI image as the base
2. Configure it to run from removable media without requiring install to disk
3. Optional: overlay filesystem for persistence (save settings across reboots without writing to the base image)

This is a well-trodden path in the Debian world — tools like `live-build` or simply configuring the image with a ramdisk overlay handle it. Not a first priority but very achievable.

### Mac Support

- **Intel Macs:** Can boot standard x86_64 Linux from USB natively. This just works with the x86_64 image.
- **Apple Silicon (M1/M2/M3/M4):** Cannot natively boot non-macOS from USB. Options:
  - **VM (UTM, Parallels, VMware Fusion):** Run the aarch64 image in a VM. Easiest path.
  - **Asahi Linux patchset:** Experimental bare-metal Linux on Apple Silicon, but requires specific kernel patches and is a much bigger effort.
  - Recommendation: VM for Apple Silicon, native boot for Intel Macs.

---

## Desktop Environment

### Decision: Xfce

shaughvOS will use **Xfce** (software ID 25) as its default desktop environment. It's already supported in the codebase with full install/config automation.

**Why Xfce:**
- ~400MB RAM idle — runs great on Raspberry Pi 4 (1-8GB) and any x86_64 machine
- Highly themeable — can be made to look very modern and polished with the right GTK theme, icon pack, and panel layout
- Already registered as software ID 25 in `dietpi-software` with all dependencies wired up (`aSOFTWARE_DEPS` = X11, ALSA, browser)
- Zorin OS Lite (the lightweight Zorin variant) actually uses Xfce under the hood — so the "Zorin feel" is achievable
- Rock-solid stability, actively maintained, works across all target architectures

### Theming: Dracula

shaughvOS will use the **Dracula** theme — a minimal, well-known dark color scheme with a full ecosystem of matching components.

- **GTK theme:** [Dracula GTK](https://draculatheme.com/gtk) — dark, flat, consistent
- **Xfce terminal:** [Dracula Xfce Terminal](https://draculatheme.com/xfce4-terminal) — matching terminal colors
- **Icon pack:** Dracula icons or Papirus-Dark (pairs well with Dracula)
- **Panel layout:** Bottom taskbar with app menu, system tray — similar to Windows/Zorin layout
- **Window manager theme:** Dracula WM theme (ships with the GTK package)
- **Wallpaper:** `assets/desktop_background.jpg` — vintage Macintosh with green banker's lamp on a neutral linen background. Already committed to the repo. This is the default desktop wallpaper for shaughvOS.
- **System UI font:** **Makira** (sans-serif) — clean, modern sans-serif with 6 weights (Regular, Medium, SemiBold, Bold, ExtraBold, Black). Used for window titles, menus, panel text, and all desktop UI.
- **Monospace font:** **IBM Plex Mono** — 7 weights + italics (14 files). Used for terminal emulator, code editors, and any fixed-width display.
- Font files are committed to the repo at `assets/fonts/Makira/` and `assets/fonts/IBMPlexMono/` (TTF format).
- At install time, fonts are copied to `/usr/share/fonts/truetype/shaughvos/` and registered via `fc-cache`.

The Dracula ecosystem covers everything in one consistent aesthetic: https://draculatheme.com/

### First-Boot Desktop Automation

In `dietpi.txt`:
```
AUTO_SETUP_INSTALL_SOFTWARE_ID=25   # Xfce (plus the QubeTX tool IDs)
AUTO_SETUP_AUTOSTART_TARGET_INDEX=2 # Desktop autologin
```

This installs Xfce and boots directly into the desktop on first run. Combined with pre-configured theming, the user gets a fully branded shaughvOS desktop experience out of the box.

### Quick-Toggle Commands: `desktop on` / `desktop off`

shaughvOS will include simple shortcut commands to toggle between desktop and CLI mode, since Emmett will be switching between them frequently.

Under the hood, this is already supported by `dietpi-autostart <index>`:
- Index `0` = Console (no autologin)
- Index `7` = Console with autologin
- Index `2` = Desktop with autologin (LightDM-based for non-root users)
- Index `16` = Desktop without autologin (LightDM login screen)

The autostart index is stored in `/boot/dietpi/.dietpi-autostart_index` and applied at boot.

**Implementation:** Add shell aliases or small wrapper scripts so users can type:

```bash
desktop on     # Sets autostart to desktop autologin (index 2), then starts the desktop
desktop off    # Sets autostart to console autologin (index 7), then stops the desktop
```

The wrapper would:
1. Call `dietpi-autostart 2` (or `7`) to persist the setting for next boot
2. Immediately start or stop the display manager (`systemctl start/stop lightdm`) for the current session

This could be implemented as:
- **Option A:** A single script at `/usr/local/bin/desktop` that takes `on`/`off` as arguments
- **Option B:** Two shell aliases in `rootfs/etc/bashrc.d/shaughvos.bash`
- **Option C:** Alias `gui` as a synonym (`gui on` / `gui off`)

Option A is cleanest — a proper script with root check and status feedback. Could also support `desktop status` to show current mode.

### Implementation Checklist (Desktop)
- [ ] Set Xfce (ID 25) as default install in `dietpi.txt`
- [ ] Set `AUTO_SETUP_AUTOSTART_TARGET_INDEX=2` for desktop autologin
- [ ] Install and configure Dracula GTK theme + WM theme
- [ ] Install Dracula Xfce Terminal color scheme
- [ ] Install Dracula-compatible icon pack (Dracula icons or Papirus-Dark)
- [ ] Configure Xfce panel layout (bottom taskbar, app menu, system tray)
- [ ] Set `assets/desktop_background.jpg` as default Xfce wallpaper (copy to `/usr/share/backgrounds/shaughvos/` at install time)
- [ ] Install Makira as default system UI font (copy `assets/fonts/Makira/*.ttf` to `/usr/share/fonts/truetype/shaughvos/`, run `fc-cache`, set in Xfce appearance settings)
- [ ] Install IBM Plex Mono as default monospace/terminal font (copy `assets/fonts/IBMPlexMono/*.ttf`, set in Xfce Terminal preferences)
- [ ] Pre-configure all Xfce settings so desktop is polished on first login
- [ ] Create `/usr/local/bin/desktop` script for `desktop on` / `desktop off` / `desktop status` toggle
- [ ] (Optional) Add `gui` as a synonym alias

### Documentation: Man Pages & Help

All custom shaughvOS commands need proper documentation accessible from the terminal:

- **Man pages** (`man desktop`, `man tr300`, etc.) — standard Unix man format, installed to `/usr/share/man/man1/`
- **`--help` flags** — every custom script/command must support `--help` with usage info (the QubeTX tools already have this built in)
- **`help` or `shaughvos help`** — (optional) a master help command listing all shaughvOS-specific commands and what they do

#### Custom commands that need man pages:
- `desktop` — toggle desktop on/off/status
- `report` — alias for `tr300` machine report
- Any other shaughvOS-specific wrapper commands added in the future

#### Man page implementation:
Man pages are simple groff/troff-formatted text files. They go in `rootfs/usr/share/man/man1/` and get installed with the OS. Example structure:
```
rootfs/usr/share/man/man1/desktop.1
rootfs/usr/share/man/man1/shaughvos.1   # (optional) master reference
```

After install, `man-db` indexes them automatically — no extra config needed.

### Implementation Checklist (Documentation)
- [ ] Write man page for `desktop` command
- [ ] Write man page for any other shaughvOS-specific commands
- [ ] (Optional) Create a `shaughvos` master command/man page listing all custom commands
- [ ] Verify `--help` works for all custom scripts
- [ ] Ensure man pages are installed to `/usr/share/man/man1/` via rootfs overlay

---

## Licensing

- **QubeTX 300 Series:** PolyForm Noncommercial License
- **shaughvOS (DietPi base):** GPLv2

Since Emmett owns both projects, this is not a blocker. However, the tools cannot be embedded as binaries in the OS image itself (PolyForm is not GPL-compatible for redistribution). The standard approach — downloading at install time from GitHub Releases — is how DietPi already handles all non-GPL software (Plex, Steam, Spotifyd, etc.). This is the correct pattern.

---

## Implementation Checklist

### Prerequisites (in the QubeTX tool repos, not shaughvOS)
- [ ] Add `armv7-unknown-linux-gnueabihf` target to `cargo-dist` CI in all three repos
- [ ] (Optional) Add `armv6-unknown-linux-gnueabihf` and `riscv64gc-unknown-linux-gnu` targets
- [ ] Verify that the `aarch64-unknown-linux-gnu` binaries work on Raspberry Pi OS / Debian aarch64

### In shaughvOS (`dietpi-software` modifications)
- [ ] Pick 3 free software IDs (or 4 if SpeedQX gets its own entry)
- [ ] Add metadata entries for TR-300, ND-300, SD-300 in the software registration section
- [ ] Add install blocks with arch mapping and GitHub Release download
- [ ] Add uninstall blocks
- [ ] Add `dietpi.txt` entries: set `AUTO_SETUP_INSTALL_SOFTWARE_ID` with the new IDs
- [ ] Set `AUTO_SETUP_AUTOMATED=1` in `dietpi.txt` for the shaughvOS default image

### Login / terminal experience
- [ ] Create ASCII art shaughvOS splash banner file (e.g., `/boot/shaughvos/.ascii_banner`)
- [ ] Add `rootfs/etc/bashrc.d/shaughvos.bash` that: (1) displays ASCII splash, (2) calls `tr300 --fast`
- [ ] Replace DietPi banner with the new shaughvOS splash + TR-300 sequence
- [ ] Add `report` shell alias pointing to `tr300` for convenience

### OS Logo & Boot Splash

The official shaughvOS logo is the SHAUGHV brandmark, committed to the repo at `assets/shaughv-logo.svg`.

**Uses:**
- **Boot splash screen** — displayed during OS boot (via Plymouth, the standard Linux boot splash system). Plymouth supports themed splash screens with custom logos. The SVG will need a PNG render at appropriate resolutions (e.g., 256x256, 512x512) since Plymouth uses bitmap images.
- **OS icon** — used in desktop "About" dialogs, login screen branding, file manager, and anywhere the OS identifies itself.
- **Favicon / app icon** — if shaughvOS ever has a web dashboard or settings app.

**Boot splash (Plymouth) implementation:**
1. Create a Plymouth theme at `rootfs/usr/share/plymouth/themes/shaughvos/`
2. Render a **white version** of the logo for the boot splash (boot screens use a black background, so the default dark SVG won't be visible). The original SVG needs its fill color changed to white before rendering to PNG.
3. Include the white logo PNG, black background, and a `shaughvos.plymouth` config file
4. Set it as the default theme: `plymouth-set-default-theme shaughvos`
5. Plymouth is already available in Debian repos — just needs `plymouth` and `plymouth-themes` packages

This replaces the default Debian/DietPi text boot with a clean graphical splash showing the SHAUGHV logo.

### Implementation Checklist (Logo & Boot Splash)
- [ ] Create white variant of `assets/shaughv-logo.svg` for boot splash (white fill on black background)
- [ ] Render white logo to PNGs at needed resolutions (256x256, 512x512, etc.)
- [ ] Create Plymouth theme in `rootfs/usr/share/plymouth/themes/shaughvos/`
- [ ] Set shaughvOS Plymouth theme as default
- [ ] Add `plymouth` package to default install dependencies
- [ ] Use logo in Xfce "About" / system info dialogs
- [ ] (Optional) Use logo on LightDM login screen

### Branding (part of the full shaughvOS rebrand)
- [ ] Replace all user-facing "DietPi" strings with "shaughvOS" throughout the codebase
- [ ] Update login banner / TR-300 title to display "shaughvOS" branding
- [ ] Set default hostname: `AUTO_SETUP_NET_HOSTNAME=shaughvOS`
- [ ] Full rebrand is the end goal — when complete, no DietPi references should remain in the user-facing experience

---

## Key Files to Modify

| File | Purpose |
|------|---------|
| `dietpi/dietpi-software` | Register IDs (~line 1102+), install blocks, uninstall blocks |
| `dietpi.txt` | Set `AUTO_SETUP_INSTALL_SOFTWARE_ID` and `AUTO_SETUP_AUTOMATED=1` |
| `dietpi/dietpi-login` | (Optional) Replace or augment login banner with TR-300 |
| `rootfs/etc/bashrc.d/dietpi.bash` | (Optional) Add TR-300 auto-run for interactive shells |
| `dietpi/func/dietpi-banner` | (Optional) Customize for shaughvOS branding |

---

## Reference: Existing Analogues in `dietpi-software`

These are existing software titles that follow the exact same "download prebuilt binary from GitHub" pattern:

| ID | Name | Language | Pattern |
|----|------|----------|---------|
| 198 | File Browser | Go | Arch case-switch, GitHub API latest, `Download_Install`, `/opt/` dir, systemd service |
| 200 | DietPi-Dashboard | Rust | GitHub API latest, uses `$G_HW_ARCH_NAME` directly, `/opt/` dir, systemd service |
| 99 | Prometheus Node Exporter | Go | GitHub release download, arch mapping |

The QubeTX tools are simpler than all of these since they are standalone CLI binaries with no services, no users, no config directories — just download, extract, and place in `/usr/local/bin/`.
