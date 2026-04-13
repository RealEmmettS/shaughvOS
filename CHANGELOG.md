# shaughvOS Changelog

All notable changes to shaughvOS are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.7.0] — 2026-04-12

### Fixed
- **CRITICAL**: Fixed post-install boot loop in VirtualBox and other VMs — after Clonezilla restore, the ISO boot menu now detects an existing shaughvOS installation and boots from the hard disk automatically (UEFI/GRUB) or offers a "Boot shaughvOS" menu entry (BIOS/syslinux). Previously, the VM rebooted back into the installer because VirtualBox ignores guest-initiated CD eject commands and the default boot order has Optical before Hard Disk.
- Fixed syslinux BIOS boot menu auto-installing without any user interaction — `timeout 0` caused the installer to run immediately on every boot with no visible menu. Now shows the menu and waits for user input.

### Changed
- ISO boot menu (GRUB/UEFI) now uses intelligent auto-detection: `search --file /boot/shaughvos/.hw_model` checks if shaughvOS is installed. If found, defaults to "Boot shaughvOS" with a 5-second timeout. If not found, shows "Install shaughvOS" and waits for user.
- ISO boot menu (syslinux/BIOS) now includes a "Boot shaughvOS" entry using `chain.c32` to chainload the hard disk MBR, matching how Ubuntu and Linux Mint installer ISOs handle the same problem.
- Removed non-functional `postaction.sh` eject script — VirtualBox and most hypervisors ignore guest-initiated optical drive eject commands.

### Added
- `chain.c32` syslinux module bundled in ISO for hard disk chainloading in BIOS boot mode.

---

## [1.6.0] — 2026-04-12

### Fixed
- **CRITICAL**: Fixed GRUB boot menu "Install shaughvOS" entry never being created — the `menuentry` wrapper was missing due to a sed pattern that matched nothing, leaving only a duplicate "shaughvOS Live" entry visible. Install entry is now properly constructed with a `menuentry` block.
- **CRITICAL**: Fixed post-restore poweroff causing the installer to loop — Clonezilla powered off the VM after restoring, and rebooting with the ISO still attached restarted the install process. Now ejects the install media and reboots so the VM boots directly into the installed OS.

### Changed
- ISO boot menu simplified to just two entries: "Install shaughvOS" and "Power off". Removed the "shaughvOS Live" entry (booted raw Clonezilla, not shaughvOS) and "Advanced options" submenu.
- Default desktop changed from `none` to `xfce` in `shaughvos.txt` — makes the configuration self-consistent with the autostart index (2 = desktop autologin) and software install list (ID 25 = Xfce).
- Post-restore action changed from `poweroff` to auto-eject + reboot via a `postaction.sh` script baked into the ISO. Works for both UEFI (GRUB) and BIOS (syslinux) boot modes.
- Syslinux BIOS boot menu cleaned up — removed stray `MENU END` with no matching `MENU BEGIN`.

### Added
- Detailed installation guides in README for Raspberry Pi, Native PC/Laptop/Intel Mac, and VirtualBox VMs. Recommends Balena Etcher for flashing.

---

## [1.5.0] — 2026-04-12

### Fixed
- **CRITICAL**: Fixed Clonezilla ISO installer failing to restore disk image — the imager was deleting critical image metadata files (`clonezilla-img`, `dev-fs.list`, `blkid.list`) "for privacy," causing partclone restore errors and immediate shutdown on first boot in VirtualBox. The `ocs-chkimg` verification ran before the deletion, masking the breakage during build. Now only removes hardware info files (`Info*txt`) while preserving all structural files needed for restore.

### Changed
- "shaughvOS Live" boot option now boots directly into the live environment instead of dumping users into the raw Clonezilla menu with confusing internal options (graphics modes, memtest, etc.). Original Clonezilla options moved to "Advanced options" submenu for both GRUB and SYSLINUX boot modes.

---

## [1.4.0] — 2026-04-12

### Fixed
- **CRITICAL**: Fixed `.update/patches` file completely missed during rebrand — it still referenced `/boot/dietpi/func/dietpi-globals` (path doesn't exist on shaughvOS), causing every `shaughvos-update` to crash during the incremental patching phase. This was the root cause of VM installation crashes after partition table editing.
- **CRITICAL**: Fixed fallback version defaults in `shaughvos-globals` — defaults were DietPi-era `10.2.3` instead of shaughvOS `1.3.0`. If `/boot/shaughvos/.version` was missing (e.g., during filesystem corruption), the system would think it was at v10.2.3, breaking the entire update flow.
- **CRITICAL**: Added version guard in `.update/pre-patches` — all DietPi-era patches (v7.0-v10.1) would fire on shaughvOS v1.x due to version numbering mismatch, including patches that inject `dietpi.com/apt` into APT sources.
- Fixed `shaughvos-login` first-run update failing on VMs with slow network — added 60-second network connectivity wait loop before calling `shaughvos-update`
- Fixed `fs_partition_resize.sh` infinite reboot loop — added reboot counter (max 3) to prevent VMs from getting stuck in boot loops during partition resize
- Fixed `shaughvos-bugreport` attempting to upload to DietPi's SFTP server (`ssh.dietpi.com:29248`) — now saves reports locally to `/var/tmp/shaughvos/bugreports/`
- Fixed `G_GET_WAN_IP()` GeoIP function calling `dietpi.com/geoip` — replaced with `ifconfig.co`
- Fixed `G_DEV_TEST_FIRMWARE()` trying to download test packages from `dietpi.com` — disabled with clear error message
- Fixed installer writing DietPi SSH known_hosts to `/root/.ssh/known_hosts`
- Replaced all user-facing `dietpi.com/forum` URLs with `github.com/RealEmmettS/shaughvOS` links (bug report template, backup prompt, login error messages)

---

## [1.3.0] — 2026-04-12

### Changed
- Default credentials: username `admin` (was `shaughvos`), password `1234` (was `shaughvos`)
- Desktop autologin user changed from `root` to `admin`
- Boot menu submenu rebranded from "Clonezilla live" to "shaughvOS Live" (GRUB and syslinux)
- ISO publisher string updated from dietpi.com to shaughvOS GitHub repo
- DNS check domain changed from `dietpi.com` to `google.com`
- Chromium autostart URL changed from `dietpi.com` to shaughvOS GitHub repo
- Software install confirmation dialog URL updated from `dietpi.com/docs/software/` to GitHub wiki
- All service user group references updated from `shaughvos` group to `admin` group

### Fixed
- Fixed broken `shaughvOS-Website` URL in desktop icon download that caused first-boot install failure (exit code 22)
- Fixed 5 broken `$G_GITOWNER/DietPi/` curl URLs in `.update/patches` (pointed to non-existent repo)
- Fixed install confirmation dialog still referencing `dietpi.com/docs/software/`

### Removed
- Removed shaughvOS-Dashboard (ID 200) from software catalog — referenced non-existent upstream repo `nonnorm/shaughvos-dashboard`

### Added
- Default credentials table in README
- `admin` user account with full sudo access as the primary non-root user

---

## [1.2.0] — 2026-04-12

### Added
- Clonezilla-based installer ISO generation for x86 targets (NativePC and VM) in release workflow
- Raspberry Pi 5 added to deployment documentation build targets table
- Upstream independence rules and release verification checklist in CLAUDE.md

### Changed
- Release workflow artifact handling now supports multiple output files per build target
- Release image filenames are now version-agnostic (e.g., `shaughvOS_RPi234-aarch64.img.xz`) so download URLs remain stable across releases
- README download table updated with stable, version-agnostic download links
- DEPLOYMENT.md updated with complete build target matrix and ISO documentation

### Fixed
- Replaced leftover DietPi Clonezilla installer backgrounds with shaughvOS-branded images (from `assets/desktop_background.jpg`), fixing x86 ISO build failure

---

## [1.1.0] — 2026-04-12

### Added
- Raspberry Pi 5 build target in release image workflow
- RPi 2/3/4 image descriptor renamed from `RPi4-aarch64` to `RPi234-aarch64` for clarity

### Fixed
- FAT volume label `SHAUGHVOSSETUP` (14 chars) exceeded 11-char FAT limit, shortened to `SHAUGHVOS`

---

## [1.0.0] — 2026-04-12

First release of shaughvOS — a complete OS rebrand built on the DietPi foundation.

### Added
- GPL-2.0 license (upstream compliance with DietPi)
- QubeTX 300 Series integration (software IDs 218-220):
  - TR-300 (`tr300`) — machine report with system info and resource graphs
  - ND-300 (`nd300` + `speedqx`) — network diagnostics and quad-provider speed test
  - SD-300 (`sd300`) — real-time interactive system diagnostic TUI
- Xfce desktop with Dracula theme (GTK, WM, terminal, Papirus-Dark icons)
- Makira sans-serif font for system UI
- IBM Plex Mono font for terminal
- Custom desktop wallpaper (`assets/desktop_background.jpg`)
- `desktop on/off/status` toggle command (`rootfs/usr/local/bin/desktop`)
- Plymouth boot splash with SHAUGHV logo (white on black)
- ASCII art terminal splash with TR-300 auto-run (`rootfs/etc/bashrc.d/shaughvos.bash`)
- Man pages: `desktop(1)`, `shaughvos(1)`
- Rebrand audit CI workflow (`.github/workflows/rebrand-audit.yml`)
- Release image build workflow for RPi4, x86 PC, and x86 VM targets
- Xfce bottom panel layout (app menu, tasklist, systray, clock, actions)
- Xfce Terminal Dracula color scheme

### Changed
- **Complete rebrand from DietPi to shaughvOS:**
  - Renamed `dietpi/` directory to `shaughvos/`
  - Renamed all 27 scripts, 17 library functions, 9 systemd services
  - Renamed `dietpi.txt` to `shaughvos.txt`
  - Replaced all internal path references (`/boot/dietpi/` -> `/boot/shaughvos/`, etc.)
  - Replaced all branding strings (DietPi -> shaughvOS)
  - Replaced all function names (G_DIETPI-NOTIFY -> G_SHAUGHVOS-NOTIFY, etc.)
  - Updated all GitHub URLs to `RealEmmettS/shaughvOS`
  - Updated all GITOWNER defaults to `RealEmmettS`
- Restored `dietpi.com` for upstream infrastructure URLs (package downloads, forums, APIs)
- Version reset from DietPi v10.2 RC3 to shaughvOS v1.0.0
- Default hostname: `shaughvOS`
- Default password: `shaughvos`
- Default autostart: desktop autologin (Xfce, index 2)
- Auto-install: Xfce (25) + QubeTX TR-300 (218) + ND-300 (219) + SD-300 (220)
- `AUTO_SETUP_AUTOMATED=1` for unattended first boot
- README rewritten with shaughvOS branding and DietPi attribution
- SECURITY.md, BRANCH_SYSTEM.md, GitHub templates updated for shaughvOS
- CLAUDE.md updated to reflect post-rebrand codebase

### Fixed
- Release image build: run from clean directory to avoid rootfs conflict with repo checkout
- Release image build: ensure DNS resolution inside chroot container
- Release image build: use branch name instead of tag name for GitHub archive extraction
- Release image build: add missing LICENSE file required by installer
- Release image build: shorten FAT volume label from 14 to 9 chars (FAT max is 11)

### Removed
- `dietpi-survey` — DietPi telemetry system (sent data to DietPi servers)
- `SURVEY_OPTED_IN` config and all survey references across the codebase
- All DietPi branding, logos, and references (except attribution in README)

---

## [0.0.0] — 2026-04-12

Initial fork from [DietPi v10.2 RC3](https://github.com/MichaIng/DietPi) by Emmett Shaughnessy.

- Added shaughvOS documentation, branding assets, and custom fonts
- Added `QUBETX_INTEGRATION.md` aspirational goals document
- Added SHAUGHV logo (`assets/shaughv-logo.svg`)
- Added desktop wallpaper (`assets/desktop_background.jpg`)
- Added Makira font (6 weights) and IBM Plex Mono font (14 variants)
