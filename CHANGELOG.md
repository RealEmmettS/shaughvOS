# shaughvOS Changelog

All notable changes to shaughvOS are documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- **`.gitignore`** — first `.gitignore` for the repo. Covers Claude Code session transcripts (`big_fix_*.txt`), OS metadata (`.DS_Store`, `Thumbs.db`, `desktop.ini`), editor/IDE scratch (`.vscode/`, `.idea/`, `*.swp`, `*~`), image-build artifacts (`*.img`, `*.iso`, `*.squashfs`, `*.img.xz`), Debian packaging output (`*.deb`, `*.changes`, `*.buildinfo`), logs, secrets (`.env*`, `*.pem`, `*.key`), Python (`__pycache__/`, `.venv/`), and Node (`node_modules/`). Existing tracked transcript files (`build_convo_thread.txt`, `fix-calamares-attempt.txt`, etc.) are grandfathered in — only affects untracked files going forward. No shipped-device impact.

---

## [1.17.0] — 2026-04-16

### Fixed
- **Claude Code CLI inaccessible** — installed as root but admin user couldn't traverse `/root/` (mode 0700) to follow the symlink. Now installs as `admin` user so the binary lives at `/home/admin/.claude/bin/claude` with a symlink in `/usr/local/bin/`.
- **`desktop off` crashes the system** — stopped LightDM instantly, killing the terminal and leaving no console (getty autologin was removed for the live session). Now creates getty autologin drop-ins, starts getty, switches to tty1, THEN stops LightDM.
- **Blank square in taskbar** — panel brandmark SVG couldn't render because `librsvg2-common` was missing (`--no-install-recommends` skipped it). Added to the imager's package list. Also fixed the brandmark download which used `|| true` hiding failures.
- **Black logo on dark panel** — GTK symbolic icon auto-recolor wasn't working with Dracula theme. Created white SVG variant (`shaughvos-panel-white.svg`) and reference by absolute path instead of the symbolic icon system.
- **Papirus icon cache stale** — only `hicolor` icon cache was rebuilt, not Papirus-Dark. Now explicitly rebuilds both caches.

### Added
- "Boot from installed system" entry in both GRUB (EFI) and ISOLINUX (BIOS) boot menus — lets users boot the installed OS without removing the ISO from VirtualBox.
- `desktop on/off` added to the terminal useful commands list.
- GTK3 CSS panel button padding — reduces cramped appearance of taskbar buttons.
- Panel size increased from 36px to 40px for better visual spacing.

---

## [1.15.0] — 2026-04-15

### Fixed
- **No web browser** — Firefox ESR was completely absent from the ISO build. Clicking the browser icon gave "Failed to execute child process 'www-browser'". Added `firefox-esr` to the imager's package list and protected it from autoremove in both the imager and Calamares shellprocess.
- **QubeTX tools "command not found"** — The imager downloaded raw tarballs and extracted flat, but cargo-dist tarballs nest binaries in a subdirectory. The binary check always failed silently. Rewrote to use the official cargo-dist installer scripts (`*-installer.sh`) from GitHub Releases, which handle architecture detection and version resolution automatically. Binaries are copied to `/usr/local/bin/` for system-wide access.
- **Makira font missing** — Font downloads used `curl ... || true`, silently swallowing failures from GitHub CDN rate limits. Removed `|| true`, added `--retry 3 --retry-delay 5`, and added a hard build failure if the primary UI font (`Makira-Regular.ttf`) is missing after download.
- **Wallpaper "(null)" error** — `xfce4-desktop.xml` used `monitorscreen` as the property name, which doesn't match any real XRandR output. Xfce requires the exact monitor name (e.g., `Virtual-1` in VirtualBox, `HDMI-1` on hardware). Replaced with entries for 6 common monitor names. Also added a dynamic XDG autostart script (`shaughvos-set-wallpaper`) that detects the actual monitor at login via `xrandr` and sets the wallpaper via `xfconf-query`.
- **DietPi URLs in terminal splash** — `shaughvos-banner` still showed dietpi.com URLs for Website, Contribute, and MOTD. Replaced with shaughvOS GitHub URLs. Also fixed `shaughvos-cloudshell` website variable.
- **Packages removed by autoremove** — Calamares `shellprocess.conf` didn't protect `plymouth`, `papirus-icon-theme`, `nodejs`, `npm`, `dbus-x11`, or `firefox-esr` from `apt-get autoremove`. Added all to `apt-mark manual`.
- **Claude Code CLI install** — Was combined with Node.js install in a single line with `|| true` hiding failures. Split into separate step with visible error reporting. Symlinks to `/usr/local/bin/claude` for system-wide access.

### Changed
- **Terminal splash defaults** — Disabled noisy banner sections (device info, LAN IP, disk usage, credits, MOTD) by default. Only the useful commands list is shown above the ASCII art. Users can re-enable sections via `shaughvos-banner`.
- **Useful commands list** — Replaced `cpu` with `tr300 / report` and added `sd300`, `claude`. Now showcases QubeTX diagnostic tools and Claude Code alongside system admin commands.

### Added
- **`shaughvos-init-software` command** — Recovery tool that (re)installs all bundled software: Node.js, npm, Claude Code CLI, QubeTX TR-300/ND-300/SD-300/SpeedQX, and Firefox ESR. Checks network connectivity, reports per-tool pass/fail, idempotent. Run `sudo shaughvos-init-software` anytime if software failed during initial install.
- Dynamic wallpaper autostart script (`/usr/local/bin/shaughvos-set-wallpaper`) — detects actual monitor name via xrandr and applies wallpaper at each login.

---

## [1.14.0] — 2026-04-15

### Fixed
- **Fonts not loading** — The imager created fontconfig aliases (`/etc/fonts/local.conf`) mapping sans-serif to Makira and monospace to IBM Plex Mono, but never downloaded the actual TTF files or ran `fc-cache`. Font manager showed no custom fonts. Now downloads all 13 TTFs (6 Makira + 7 IBM Plex Mono) to `/usr/share/fonts/truetype/shaughvos/` and rebuilds the font cache.
- **Black desktop background** — The imager downloaded the wallpaper JPG but never created `xfce4-desktop.xml` to tell Xfce where to find it. Xfce showed "Unable to load images from folder '(null)'". Now creates `xfce4-desktop.xml`, `xsettings.xml`, and `xfce4-panel.xml` in `/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/`.
- **No GTK theme or icons** — Dracula GTK theme and Papirus-Dark icon theme were referenced in greeter and xfwm4 configs but never installed. Now downloads Dracula theme and installs `papirus-icon-theme` via apt, protected from autoremove with `apt-mark manual`.
- **QubeTX tools "command not found"** — The QubeTX install block swallowed all errors (`2>/dev/null || true`), making download/extraction failures invisible. Now logs to `/var/log/shaughvos-qubetx-install.log` and extracts to dedicated subdirectories for reliable binary detection.
- **ASCII art misspelling** — Terminal splash banner showed "shaughOS" instead of "shaughvOS" (missing the lowercase "v"). Regenerated figlet ASCII art with correct spelling.

### Added
- Full Xfce theming in the imager — `xsettings.xml` (Dracula theme, Papirus-Dark icons, Makira/IBM Plex Mono fonts), `xfce4-desktop.xml` (wallpaper), `xfce4-panel.xml` (bottom panel with shaughvOS brandmark), terminal config (Dracula colors, IBM Plex Mono 11), and panel brandmark SVG.
- Wallpaper variants (dark1, dark2, dark3, 4K) downloaded during ISO build for the wallpaper picker.

---

## [1.13.1] — 2026-04-15

### Fixed
- **CRITICAL**: Login loop after install AND live session crash — the actual root cause discovered after 5 release iterations (v1.11.0–v1.13.0): **Xfce was never installed in the ISO rootfs.** The build pipeline defers Xfce installation to first boot via `shaughvos.txt`, but the imager sets `.install_stage=2` which suppresses first-boot software install. The live ISO had `lightdm` (a login screen) pointing at Xfce (a desktop that didn't exist). All previous fixes (session configs, compositor disable, displaymanager module, etc.) were correct but addressed downstream effects of this upstream cause.
  - Added full Xfce desktop stack to the imager's `apt-get install`: `xfce4`, `xfce4-session`, `xfwm4`, `xfdesktop4`, `xfce4-panel`, `thunar`, `xfce4-terminal`, `xinit`, `dbus-user-session`, `dbus-x11`, `x11-xserver-utils`.
  - Expanded `apt-mark manual` before pre-squashfs `autoremove` to protect ALL critical desktop/session packages. shaughvOS's aggressive APT config (`AutoRemove::RecommendsImportant "false"`) makes autoremove strip packages that stock Debian would protect.
  - Added per-user xfce4 config cleanup before squashfs creation to prevent compositor override.
  - Pre-installed `dbus-x11` in the imager (previously only installed by shellprocess post-install, which could silently fail due to no network in chroot).

### Added
- **QubeTX 300 Series tools pre-installed on ISO** — TR-300 (machine report), ND-300 + SpeedQX (network diagnostics), and SD-300 (system diagnostics) are now downloaded from GitHub Releases during ISO build, matching the Claude Code CLI install pattern. Previously deferred to first boot which was suppressed by `.install_stage=2`.

---

## [1.13.0] — 2026-04-15

### Fixed
- **CRITICAL**: Login loop after install (visual glitch -> back to login screen) — two root causes survived from v1.12.0:
  1. `displaymanager.conf` was missing from the Calamares module download loop in the imager. The `displaymanager` module was in `settings.conf`'s exec sequence but its config file was never copied to the chroot, so LightDM was never properly configured for the installed user.
  2. xfwm4 compositor was not explicitly disabled in the imager — it relied on the base image's `shaughvos-software`-generated config. On VirtualBox with `nomodeset` (no hardware GL), the compositor crashed on login, producing a "random colors" visual glitch that crashed the session back to the greeter. Now enforced directly in the imager as a safety net.
- **Plymouth boot splash not showing** — three root causes resolved:
  1. `plymouth` and `plymouth-themes` packages were never installed in the live ISO build. Added to the imager's `apt-get install`.
  2. `shaughvos-logo-white.png` was missing from `rootfs/usr/share/plymouth/themes/shaughvos/` — the Plymouth script referenced it but only `.plymouth` and `.script` files existed. Generated 400x400 PNG from `assets/shaughv-logo-white.svg`.
  3. Plymouth theme was never registered (`plymouth-set-default-theme shaughvos`) and never included in the initramfs. Added theme registration + `update-initramfs -u` after package install.

### Added
- **"Try shaughvOS" live boot option** — renamed "shaughvOS Live (safe graphics)" to "Try shaughvOS (without installing)". Uses a `shaughvos.live=1` kernel parameter + `shaughvos-live-check.service` (systemd oneshot, runs before LightDM) to suppress Calamares autostart. Users can explore the desktop without the installer launching. The "Install shaughvOS" shortcut remains in the Applications menu for manual install. Cleaned up from installed systems by `shellprocess.conf`.

---

## [1.12.0] — 2026-04-14

### Fixed
- **CRITICAL**: Fixed login loop on installed system (v1.11.0 fix was insufficient) — the Xfce session crashed immediately after login due to multiple cascading issues:
  1. `apt-get autoremove` in Calamares shellprocess could silently remove packages critical to the desktop session (D-Bus, session manager). Now marks all critical desktop/session packages as manually installed before autoremove runs.
  2. Missing D-Bus session bus fallback — `dbus-x11` was not installed, so if `dbus-user-session`'s systemd --user integration failed, there was no fallback `dbus-launch`. Now installs `dbus-x11` as belt-and-suspenders.
  3. xfwm4 compositor could crash with nomodeset/fbdev/vesa (no hardware GL) on VirtualBox. Disabled compositor in default config.
  4. Missing Calamares `displaymanager` module — `doAutologin: true` in `users.conf` was never acted on because the `displaymanager` module wasn't in the exec sequence. Added it with LightDM + Xfce configuration.
- Fixed black greeter background (v1.11.0 fix was insufficient) — the conditional wallpaper download skipped re-download if a file existed (even if corrupt/empty). Now always downloads fresh from GitHub.

### Added
- Diagnostic session wrapper (`/usr/local/bin/shaughvos-xsession-wrapper`) — logs session startup info (user, DISPLAY, D-Bus, available sessions, critical packages) to `/var/log/lightdm/shaughvos-session.log` on every login attempt. Enables rapid diagnosis of future login issues.

---

## [1.11.0] — 2026-04-14

### Fixed
- **CRITICAL**: Fixed login loop on installed system — after entering credentials at the LightDM greeter, the screen went black and returned to the greeter. Root cause: Calamares shellprocess removes `live-autologin.conf` (which specified the Xfce session), leaving LightDM with no session configuration. Added persistent `50-shaughvos.conf` with `user-session=xfce` that survives cleanup.
- Fixed black LightDM greeter background — wallpaper file at `/usr/share/backgrounds/shaughvos/` depended on a `curl || true` download during base image build that could silently fail. Now copied directly from repo `assets/` during ISO build.
- Fixed Plymouth boot splash not showing on installed system — `/etc/default/grub` was missing `quiet splash`. Added to the GRUB defaults injected during ISO build (only affects installed system, not the live ISO boot entry).

### Added
- Plymouth boot splash now shows for a minimum of 5 seconds — even on fast-booting systems, the shaughvOS branding is visible before transitioning to the login screen. Uses a systemd drop-in on `plymouth-quit.service` with no boot performance impact.

---

## [1.10.0] — 2026-04-13

### Added
- **SHAUGHV panel brandmark** — replaces the default Xfce mouse icon on the Applications Menu button with the SHAUGHV logo. Uses a GTK3 symbolic icon (`shaughvos-panel-symbolic.svg`) that automatically recolors to match the active theme — white on dark themes (Dracula), black on light themes. No scripts or detection logic needed.
- **4 additional desktop wallpapers** — retro Mac + green banker's lamp in multiple lighting variants:
  - `desktop_background_dark1.png` — dark, lamp off
  - `desktop_background_dark2.png` — dark, warm lamp light
  - `desktop_background_dark3.png` — dark, glowing green lamp
  - `desktop_background_4k.png` — uncompressed 4K version of the default wallpaper (light background)
  All wallpapers are downloaded to `/usr/share/backgrounds/shaughvos/` during Xfce install and are selectable via Settings > Desktop.
- **White logo variant** (`shaughv-logo-white.svg`) — Dracula-themed white (`#f8f8f2`) version of the SHAUGHV logo for use on dark backgrounds (Plymouth, Calamares, etc.).

---

## [1.9.0] — 2026-04-13

### Fixed
- **SECURITY**: Regenerate SSH host keys on installed system — `shaughvos-firstboot` (which normally does this) is disabled for Calamares installs. Without key regeneration, every installed system shared the same SSH host keys from the base image. Added `ssh-keygen -A` to Calamares `shellprocess` cleanup.
- **CRITICAL**: Overhauled Calamares `shellprocess.conf` post-install cleanup — previous versions left live-session artifacts on the installed system:
  - Calamares autostart `.desktop` files (caused Calamares to re-launch on every login)
  - `live-boot` package with initramfs hooks (confused the installed system's boot, scanned for squashfs on every boot)
  - `calamares` and `calamares-settings-debian` packages (wasted disk space)
  - `/etc/calamares/` config directory
  - Stale password change flag (`/var/lib/shaughvos/.check_user_passwords`) that triggered unnecessary prompts
  All now cleaned up. Initramfs is rebuilt without live-boot hooks before GRUB regeneration.
- Fixed Calamares branding showing version `1.8.0` instead of current version in the installer UI.
- Fixed DietPi MOTD URL in daily cron — was fetching from `dietpi.com/motd`, now points to shaughvOS's own MOTD file.
- Fixed DietPi documentation URL in `shaughvos-cloudshell.service` — was still pointing to `dietpi.com`.
- Removed redundant `update-grub` from `shellprocess.conf` — the Calamares `bootloader` module runs after `shellprocess` and handles GRUB installation and config generation itself.

### Added
- **LightDM greeter visual configuration** — desktop wallpaper as login screen background, Makira font, Dracula GTK theme, Papirus-Dark icons. The login screen is no longer a plain black background.
- **System-wide fontconfig defaults** — Makira set as default sans-serif/serif font, IBM Plex Mono as default monospace font via `/etc/fonts/local.conf`. All applications (terminal, file manager, settings, login screen) now use the correct shaughvOS fonts by default.
- **shaughvOS MOTD file** (`.update/motd`) — replaces the dietpi.com MOTD URL with shaughvOS-branded content.
- ISO size reduction: `apt-get clean` + `autoremove` + apt list cleanup before squashfs creation.

---

## [1.8.8] — 2026-04-13

### Fixed
- **CRITICAL**: Fixed keyboard and mouse unresponsive on installed system — the installed system's GRUB was missing `nomodeset`. Calamares's bootloader module reads `/etc/default/grub` from the squashfs, which had `consoleblank=0` but no `nomodeset`. Without it, VirtualBox's `vmwgfx` kernel module error can freeze input handling. Now inject `nomodeset` into `/etc/default/grub` during ISO build so it carries through to the installed system.
- Fixed potential input driver absence — explicitly install `xserver-xorg-input-libinput` in the imager's package list as a safety measure. The base image should already include it, but `--no-install-recommends` could theoretically cause apt to resolve a conflict by removing it.
- Fixed Calamares `shellprocess` potentially removing autologin created by the `users` module — renamed the live-session autologin config from `shaughvos-autologin.conf` to `live-autologin.conf` so it doesn't collide with Calamares's own autologin output.
- Added `update-grub` to Calamares `shellprocess` to regenerate the installed system's GRUB config with the correct kernel parameters including `nomodeset`.

---

## [1.8.7] — 2026-04-13

### Fixed
- **CRITICAL**: Fixed Calamares installer never launching — `Exec=sudo calamares` in the desktop entry silently failed because Debian 12's `sudo` resets the environment by default, stripping `DISPLAY` and `XAUTHORITY`. With `Terminal=false`, the X11 connection failure was completely invisible. Every major distro (Debian, Manjaro, Lubuntu) uses `pkexec` or `sudo -E` with `xhost` — never bare `sudo`. Replaced with a launcher script that preserves the X11 environment.
- **CRITICAL**: Fixed persistent black screen by removing `quiet splash` from the "Install shaughvOS" boot entry. With `quiet`, ALL boot errors (Xorg crashes, service failures, live-boot issues) were hidden — the user was stuck on VT7 with no visible feedback. Boot messages are now visible during install for diagnostics. The "Live (safe graphics)" entry retains `quiet splash` for a polished fallback.
- Added `xserver-xorg-video-vesa` as additional Xorg fallback driver — works directly with VESA BIOS Extensions via `libx86emu`, doesn't need `/dev/fb0` or KMS. Catches cases where `fbdev` driver fails.
- Added `LIBGL_ALWAYS_SOFTWARE=1` to Calamares launcher for VirtualBox compatibility — Qt5 apps render black when VirtualBox's OpenGL 2.1 doesn't meet Qt's requirements.
- Added `sudoers env_keep` for `DISPLAY`, `XAUTHORITY`, `XDG_RUNTIME_DIR`, and `DBUS_SESSION_BUS_ADDRESS` — defense in depth so `sudo` never strips display variables in the live session.
- Added explicit `update-initramfs -u` after all package installs in the ISO build — ensures live-boot initramfs hooks are definitely included.

### Added
- Calamares launcher script (`/usr/local/bin/launch-calamares`) — grants root X11 access via `xhost`, preserves environment with `sudo -E`, forces software GL rendering.
- polkit rule (`49-shaughvos-live.rules`) — grants admin password-free `pkexec` access in the live session (how every major distro handles Calamares authentication).
- Both new artifacts are cleaned up on the installed system by Calamares `shellprocess` module.

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
