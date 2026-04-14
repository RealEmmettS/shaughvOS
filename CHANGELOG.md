# shaughvOS Changelog

All notable changes to shaughvOS are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.8.6] — 2026-04-13

### Fixed
- **CRITICAL**: Fixed live ISO black screen after selecting "Install shaughvOS" — three cascading failures prevented the graphical desktop from ever appearing:
  1. systemd default target was `multi-user.target`, so lightdm (installed in v1.8.5) never started — `display-manager.service` is only activated by `graphical.target`. Now set `graphical.target` as default for the live session.
  2. Root's getty autologin on tty1 ran `exec startx` in a loop — the base image's root autologin triggered `shaughvos-login` → `Run_AutoStart(2)` → `exec startx`, which crashed (wrong display driver) and killed the tty. With `quiet splash` kernel params, the crash loop was invisible — just a permanent black screen. Now removed root's getty autologin for the live session.
  3. Wrong X11 display driver — the build container installed `xserver-xorg-video-vmware` (designed for VMware KMS), but VirtualBox with `nomodeset` has no KMS. Xorg had no working driver and crashed immediately. Now install `xserver-xorg-video-fbdev` as a universal fallback that works with any kernel framebuffer.
- Updated Calamares `shellprocess.conf` to also clean up root's getty autologin conf on the installed system.

---

## [1.8.5] — 2026-04-13

### Fixed
- **CRITICAL**: Fixed live ISO booting to CLI instead of Xfce desktop — lightdm (display manager) was never installed in the ISO. The base image uses `exec startx` for root's desktop autologin and doesn't need lightdm, but the live session runs as admin (non-root) and requires it. Added `lightdm` and `lightdm-gtk-greeter` to the imager's package install step.
- **CRITICAL**: Also create the `display-manager.service` symlink directly during ISO build as a reliability measure, in case `systemctl enable lightdm` fails inside the chroot environment.
- Fixed `desktop` command returning "Permission denied" — the script was tracked in git as non-executable (`100644`) due to being created on Windows. Changed to `100755`.

---

## [1.8.4] — 2026-04-13

### Fixed
- **CRITICAL**: Fixed VirtualBox booting straight to CLI instead of the desktop installer — the "Install shaughvOS" GRUB and isolinux entries were missing `nomodeset`, causing the `vmwgfx` kernel driver to fail on VirtualBox's VMSVGA graphics controller. Xorg couldn't start, lightdm failed, and the user got dumped to a text login with no desktop or Calamares. Added `nomodeset` to both boot entries.

### Changed
- Renamed "shaughvOS Live" boot menu entry to "shaughvOS Live (safe graphics)" for clarity, since both entries now use identical boot parameters with `nomodeset`.

---

## [1.8.3] — 2026-04-13

### Fixed
- **CRITICAL**: Fixed installed system having no kernel, initrd, or shaughvOS scripts — `mksquashfs` was run with `-e boot` which excluded the entire `/boot` directory from the squashfs. Calamares extracted an empty `/boot`, leaving the installed system unbootable and missing all shaughvOS tools. Removed the exclusion flag.
- Fixed disabled services (preboot, postboot, ramlog) persisting to the installed system — added Calamares `services-systemd` module config to re-enable these services during installation. They are disabled in the live session only.
- Fixed NOPASSWD sudo and live-session autologin config persisting to the installed system — added Calamares `shellprocess` module to remove live-only artifacts (`/etc/sudoers.d/live-admin`, `/etc/lightdm/lightdm.conf.d/shaughvos-autologin.conf`) after extraction.

### Added
- Calamares `services-systemd.conf` — re-enables shaughvos-preboot, shaughvos-postboot, and shaughvos-ramlog on the installed system.
- Calamares `shellprocess.conf` — post-install cleanup of live-session-only artifacts.

---

## [1.8.2] — 2026-04-13

### Fixed
- **CRITICAL**: Fixed Calamares installer never launching in live-boot ISO — `.install_stage` was stuck at `10` (build marker), causing `shaughvos-login` to enter error/first-run mode on every shell instead of normal login. Now set to `2` (setup complete) for the live session.
- **CRITICAL**: Fixed `admin` user having no sudo access in live session — Calamares desktop entry runs `sudo calamares` but admin had no sudoers rule, causing silent failure from XDG autostart (no terminal for password prompt). Added NOPASSWD sudo for the live session.
- Fixed `shaughvos-postboot` service still enabled in live-boot environment — could interfere with the live session by running post-install scripts that expect a real installed system.
- Fixed desktop autostart index not set for live session — `desktop status` now reports correctly and the autostart system knows to run in desktop mode.

---

## [1.8.1] — 2026-04-13

### Fixed
- Fixed live-boot ISO failing to reach desktop — `/etc/fstab` from build environment contained invalid PARTUUIDs causing mount errors in the live overlay. Now cleared for live-boot; Calamares regenerates correct fstab during installation.
- Fixed cascade of systemd service failures during live boot — disabled `shaughvos-fs_partition_resize`, `shaughvos-firstboot`, `shaughvos-preboot`, and `shaughvos-ramlog` services that expect real installed hardware. These are re-enabled by Calamares during installation.
- Fixed `admin`/`1234` login not working in live session — password now explicitly set via `chpasswd` during ISO build since first-boot setup doesn't run in live mode.
- Fixed LightDM desktop not starting in live session — added autologin configuration for `admin` user with Xfce session.

---

## [1.8.0] — 2026-04-13

### Changed
- **MAJOR**: Replaced Clonezilla disk imaging installer with a proper live-boot + Calamares installer. The ISO now boots a full shaughvOS live desktop environment, and Calamares (the industry-standard Linux installer used by Manjaro, KDE Neon, Kubuntu, and 20+ distros) handles partitioning, filesystem creation, and GRUB installation dynamically for the target hardware. This fixes the boot loop issue in VirtualBox and other VMs where Clonezilla's raw block copy didn't properly configure the bootloader for the target disk controller.
- ISO boot menu now shows three entries: "Install shaughvOS" (live desktop + installer auto-launch), "shaughvOS Live" (live desktop with safe graphics), and "Power off". Both GRUB (UEFI) and isolinux (BIOS) menus display the shaughvOS background image.
- ISO is now a proper hybrid ISO supporting both legacy BIOS and UEFI boot with separate EFI boot partition, generated via xorriso with isohybrid MBR + GPT.
- ISO build dependencies changed from Clonezilla/partclone to squashfs-tools, grub-pc-bin, grub-efi-amd64-bin, mtools, dosfstools, syslinux-efi.
- ISO build pipeline now copies the shrunken root filesystem to a temporary 3 GiB ext4 image before installing packages, since the imager's shrink step truncates the .img to minimum size before the ISO path runs.
- Updated README with comprehensive installation guides for Raspberry Pi, Native PC, and VirtualBox — VirtualBox instructions now describe the Calamares-based install flow.
- Default desktop set to Xfce (`AUTO_SETUP_DESKTOP=xfce` in shaughvos.txt) for consistency with autostart index 2 (desktop autologin).

### Added
- **Calamares installer** with full shaughvOS branding — Dracula-themed sidebar (background #282a36, text #f8f8f2, highlight #50fa7b), shaughv logo, custom welcome/locale/keyboard/partition/users/summary flow, and automatic GRUB bootloader installation.
- **Live boot support** via Debian's `live-boot` package — the ISO boots a complete shaughvOS desktop in RAM. Users can try the full OS (Xfce desktop, QubeTX 300 Series tools, everything) before committing to install.
- **Node.js, npm, and Claude Code CLI** pre-installed as default software in the live environment and installed system.
- Calamares auto-launches on live desktop boot via XDG autostart entry (`/etc/xdg/autostart/calamares-installer.desktop`). Desktop shortcut also available in application menu for manual launch.
- Calamares module configurations: `unpackfs.conf` (squashfs extraction from `/run/live/medium/live/filesystem.squashfs`), `bootloader.conf` (GRUB with `efiBootloaderId: shaughvos`), `partition.conf` (GPT default, ext4, EFI system partition), `users.conf` (autologin, sudo groups), `welcome.conf` (8 GB storage / 1 GB RAM requirements), `finished.conf` (auto-restart).
- Detailed release deployment workflow documented in CLAUDE.md with step-by-step instructions for version bumping, changelog, tagging, pushing, and CI monitoring.
- `upload-artifact` and `download-artifact` GitHub Actions bumped to v5 for Node.js 24 compatibility (ahead of June 2nd 2026 deprecation deadline).

### Fixed
- **CRITICAL**: Fixed post-install boot loop in VirtualBox — Clonezilla's raw block copy didn't install GRUB for the target hardware's disk controller. VirtualBox BIOS enumerates IDE before SATA, so the ISO's `chain.c32 hd0` pointed to the IDE optical drive instead of the SATA hard disk. Calamares eliminates this by running `grub-install` during installation.
- Fixed GRUB "Install shaughvOS" menuentry that was never properly created in v1.5.0 — sed pattern matched nothing because the `menuentry` line wasn't indented.
- Fixed syslinux BIOS boot menu silently auto-reinstalling — `timeout 0` caused the installer to run immediately on every boot with no visible menu.
- Fixed non-functional `postaction.sh` eject script — VirtualBox and most hypervisors ignore guest-initiated optical drive eject commands.

### Removed
- Clonezilla disk imaging — no longer downloads or uses Clonezilla Live for ISO creation. The `CLONING_TOOL='Clonezilla'` variable name is retained as a legacy trigger in the build system but the implementation is entirely live-boot + Calamares.
- `chain.c32` syslinux module, GRUB auto-detect logic, and `localboot` entries — no longer needed since Calamares installs GRUB properly on the target disk.
- Old DietPi-era tags (v9.x, v10.x) cleaned from remote repository.

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
