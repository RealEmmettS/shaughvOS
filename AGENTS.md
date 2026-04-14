# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## What This Is

**shaughvOS** — a custom operating system built on a Debian foundation (originally forked from [DietPi](https://github.com/MichaIng/DietPi)). The rebrand is **complete** — all DietPi references have been replaced with shaughvOS branding. The repo lives at `RealEmmettS/shaughvOS` as a fully independent project.

### CRITICAL: Upstream Independence

shaughvOS is a **fully independent project**. It is NOT a contributor to, nor affiliated with, MichaIng/DietPi in any capacity.

- **Never** push, PR, comment on, or interact with `MichaIng/DietPi` in any way
- **Never** add an `upstream` remote pointing to DietPi — the only remote should be `origin` → `RealEmmettS/shaughvOS`
- **GitHub CLI (`gh`)**: GitHub still considers this repo a fork. If an `upstream` remote exists, `gh` silently resolves API calls to `MichaIng/DietPi` instead of `RealEmmettS/shaughvOS`. Always verify `gh repo view --json nameWithOwner` returns `RealEmmettS/shaughvOS`. If it doesn't, check `git remote -v` and remove any upstream remote.
- Some workflow files reference `MichaIng` for **legitimate upstream infrastructure** (Armbian build system, package maintainer metadata, author attribution). These are dependencies, not contributions.

### Release Verification Checklist

**IMPORTANT**: Do NOT create GitHub Releases manually with `gh release create`. The `release-images.yml` CI workflow automatically creates the Release and attaches build artifacts (ISO images, checksums) when a `v*` tag is pushed. Manually creating a release first causes CI to fail with "a release with the same tag name already exists."

After tagging and pushing a new release:
1. Confirm the release workflow triggered: `gh run list --workflow=release-images.yml --limit 1`
2. Wait for all build jobs to complete (typically 15-20 minutes)
3. Verify the GitHub Release was created with all expected assets: `gh api repos/RealEmmettS/shaughvOS/releases --jq '.[0] | "\(.tag_name): \(.assets | length) assets"'`
4. Test download links from README and the homepage
5. If any builds failed, check logs: `gh run view <run-id> --log-failed`
6. If CI release step failed due to existing release: delete the release (`gh release delete <tag> --yes`), delete the tag (`git push --delete origin <tag>`), then re-push the tag to re-trigger CI

### Key Documents
- `QUBETX_INTEGRATION.md` — aspirational goals and feature research
- `CHANGELOG.md` — all changes, follows [Keep a Changelog](https://keepachangelog.com/) format
- `DEPLOYMENT.md` — full release lifecycle: versioning, tagging, CI, image building, OTA updates, GitHub Releases

### Deployment & Releases
See `DEPLOYMENT.md` for the full reference. Below is the exact step-by-step workflow Codex should follow when asked to "deploy", "release", "bump", "tag", or any variation:

#### Release Workflow (execute in order)

**Step 1 — Prepare all release files (one commit, one push, then tag):**

1. **Bump version** — Edit `.update/version`, increment `G_REMOTE_VERSION_SUB` (or `_CORE` for breaking changes). Set `G_REMOTE_VERSION_RC=0` for stable.
2. **Update CHANGELOG.md** — Move `[Unreleased]` contents into a new `## [X.Y.0] — YYYY-MM-DD` section. Add a fresh empty `[Unreleased]` section at the top. Follow [Keep a Changelog](https://keepachangelog.com/) format with `### Fixed`, `### Changed`, `### Added`, `### Removed` subsections.
3. **Update AGENTS.md version refs** — Find/replace old version string (e.g., `v1.5.0` -> `v1.8.0`) in this file.
4. **Update README.md** if features/install process changed.

**Step 2 — Single commit with everything, then tag before push:**

5. **Stage specific files** — `git add .update/version CHANGELOG.md AGENTS.md README.md` (and any other changed files). Never `git add -A`.
6. **Commit** — `git commit -m "Release vX.Y.0 — <one-line summary>"`
7. **Tag the commit** — `git tag vX.Y.0` (tag BEFORE pushing so the tag and commit go out together)
8. **Push commit and tag** — `git push origin master && git push origin vX.Y.0` (NEVER use `--tags` — it pushes all local tags including old DietPi-era ones that break CI)

**Step 3 — Monitor and verify (hands off — CI does the rest):**

9. **NEVER run `gh release create`** — CI creates the Release and attaches build artifacts automatically. Manual creation blocks CI (see memory: `feedback_release_verification.md`).
10. **Monitor CI** — `gh run list --workflow=release-images.yml --limit 1` (also check `shellcheck.yml`)
11. **Verify release** (~15-20 min) — `gh api repos/RealEmmettS/shaughvOS/releases --jq '.[0] | "\(.tag_name): \(.assets | length) assets"'`
12. **If CI fails** — Check logs: `gh run view <run-id> --log-failed`. If release step failed due to existing release: delete release, delete tag, re-push tag.

#### Version Scheme
- `CORE` = major version (breaking changes)
- `SUB` = minor version (features, fixes)
- `RC` = release candidate (0 = stable)

#### OTA Updates
Pushing to `master` with a bumped `.update/version` is sufficient for OTA — devices auto-detect via `raw.githubusercontent.com`.

## Target Hardware

- **Raspberry Pi 4** (primary) — aarch64
- **x86_64 PCs / laptops** — dual-boot or USB boot
- **Intel Macs** — native USB boot (Apple Silicon via VM only)
- **Live USB** — stretch goal

## Bundled Software & Experience

### QubeTX 300 Series (software IDs 218-220, pre-installed on first boot)
- **TR-300** (`tr300`) — Machine report. Auto-runs on every terminal session via `--fast` flag.
- **ND-300** (`nd300` + `speedqx`) — Network diagnostics + quad-provider speed test.
- **SD-300** (`sd300`) — Real-time interactive system diagnostic TUI.
- Repos: `QubeTX/qube-machine-report`, `QubeTX/qube-network-diagnostics`, `QubeTX/qube-system-diagnostics`

### Desktop Environment
- **Xfce** (software ID 25) — default desktop, auto-login on boot
- **Dracula theme** — GTK, terminal, window manager, Papirus-Dark icons
- **Makira** — system UI sans-serif font (`assets/fonts/Makira/`)
- **IBM Plex Mono** — terminal/monospace font (`assets/fonts/IBMPlexMono/`)
- **Desktop wallpaper:** `assets/desktop_background.jpg`
- **Panel brandmark:** SHAUGHV logo as GTK symbolic icon — auto-recolors with theme (light on dark, dark on light)
- **`desktop on/off/status`** — toggle between desktop and CLI mode (`rootfs/usr/local/bin/desktop`)

### Boot & Terminal Experience
1. **Boot splash:** SHAUGHV logo (white on black) via Plymouth (`rootfs/usr/share/plymouth/themes/shaughvos/`)
2. **Terminal session:** ASCII art shaughvOS splash + TR-300 machine report (`rootfs/etc/bashrc.d/shaughvos.bash`)
3. All custom commands have **man pages** (`rootfs/usr/share/man/man1/`) and `--help` flags

## Assets

```
assets/
  shaughv-logo.svg         Official OS logo / boot splash source
  shaughv-logo-white.svg        White variant for dark backgrounds (Plymouth, Calamares)
  shaughvos-panel-symbolic.svg  GTK symbolic icon for panel (auto-recolors with theme)
  desktop_background.jpg        Default Xfce wallpaper
  desktop_background_dark1.png  Dark wallpaper — retro Mac + green lamp
  desktop_background_dark2.png  Dark wallpaper — retro Mac + warm lamp light
  desktop_background_dark3.png  Dark wallpaper — retro Mac + glowing green lamp
  desktop_background_4k.png     Uncompressed 4K version of default wallpaper
  fonts/
    Makira/                System UI font (6 weights, TTF)
    IBMPlexMono/           Terminal font (7 weights + italics, TTF)
```

## Branch System

- `master` — stable release (OTA updates pull from here)
- `beta` — pre-release public testing
- `dev` — active development

## Linting

ShellCheck is the only linter, run on every push/PR via CI (`.github/workflows/shellcheck.yml`).

**Run locally** (mirrors CI exactly):
```bash
shellcheck -C -xo all <file(s)>
```

CI also enforces:
- No trailing whitespace
- No triple-or-more consecutive blank lines
- Zero DietPi references (`.github/workflows/rebrand-audit.yml`)

**Disabled ShellCheck rules** (`.shellcheckrc`): `SC2004,SC2119,SC2155,SC2188,SC2243,SC2244,SC2250,SC2312,SC2317`

## Codebase Architecture

### Key Directories

- `shaughvos/` — User-facing tools (`shaughvos-config`, `shaughvos-software`, `shaughvos-update`, etc.). All extensionless Bash scripts.
- `shaughvos/func/` — Shared library functions. The critical file is `shaughvos-globals`.
- `shaughvos/misc/` — Helper scripts.
- `rootfs/` — Files overlaid onto the system root at install time (systemd units, apt config, cron jobs, sysctl, bashrc.d, man pages, Plymouth theme, desktop command).
- `.update/` — Versioning (`version`), incremental migration patches (`patches`, `pre-patches`).
- `.build/` — Image building tools (`shaughvos-build`, `shaughvos-imager`, `shaughvos-installer`).
- `.meta/` — Supplementary migration scripts, not deployed to devices.
- `assets/` — shaughvOS branding: logo, wallpaper, fonts.
- `shaughvos.txt` — First-boot automation config (deployed to `/boot/`). Key=value settings.

### shaughvos-globals — The Foundation

Every script begins with:
```bash
. /boot/shaughvos/func/shaughvos-globals
readonly G_PROGRAM_NAME='shaughvOS-SomeTool'
G_CHECK_ROOT_USER "$@"
G_CHECK_ROOTFS_RW
G_INIT
```

Key `G_*` function families:
- **`G_EXEC`** — Wrapped command execution with error handling
- **`G_WHIP`** — Whiptail dialog wrappers (`G_WHIP_YESNO`, `G_WHIP_MENU`, etc.)
- **`G_SHAUGHVOS-NOTIFY`** — Formatted console output (levels 0-3, hierarchy support)
- **`G_CHECK_*`** — Precondition checks (root, rootfs R/W, etc.)
- **`G_HW_*`** — Hardware model/memory/revision variables (populated from `/boot/shaughvos/.hw_model`)

**Critical convention**: Always use `local` for index variables in `for`/`while` loops, or `unset` them afterwards.

### Software Installation

`shaughvos/shaughvos-software` is the main installer. Software is identified by numeric IDs. Pattern: register metadata with `aSOFTWARE_NAME`/`aSOFTWARE_DESC`/`aSOFTWARE_CATX`, add install block with `To_Install <ID>`, add uninstall block with `To_Uninstall <ID>`. Use `Download_Install` for GitHub release binaries. See File Browser (ID 198) and QubeTX TR-300 (ID 218) as reference implementations.

### OTA Update System

`shaughvos-update` orchestrates updates from `RealEmmettS/shaughvOS`:
1. Fetches `.update/version` from `raw.githubusercontent.com/RealEmmettS/shaughvOS/master/`
2. Runs `.update/pre-patches` (before APT/code updates)
3. Pulls new code from GitHub
4. Runs `.update/patches` (incremental, version-gated migrations)

### Boot Sequence

Systemd services: `shaughvos-fs_partition_resize` -> `shaughvos-preboot` -> `shaughvos-firstboot` (first run only) -> `shaughvos-postboot`. Interactive shells source `shaughvos-globals` via `/etc/bashrc.d/shaughvos-legacy.bash`. Terminal splash and TR-300 auto-run via `/etc/bashrc.d/shaughvos.bash`. Desktop autostart controlled by `shaughvos-autostart` (index stored in `/boot/shaughvos/.shaughvos-autostart_index`).

### Image Building

Three tools in `.build/images/`:
- **`shaughvos-build`** — Creates images from scratch for specific hardware models
- **`shaughvos-imager`** — Shrinks and compresses images for release (`.img.xz`). For x86 ISOs, creates a live-boot ISO with squashfs + Calamares installer (replaces the old Clonezilla approach).
- **`shaughvos-installer`** — Converts a running Debian 12+ system into shaughvOS

### ISO Installer Architecture

The installer ISO boots a full shaughvOS live environment using Debian's `live-boot` system. The root filesystem is compressed as squashfs. **Calamares** (industry-standard installer used by 20+ Linux distros) handles disk partitioning, filesystem creation, squashfs extraction, and GRUB installation — dynamically configured for the target hardware.

Configuration: `assets/calamares/` contains settings.conf, branding, and module configs.

Pre-installed software: Node.js, npm, Codex CLI.

#### Live ISO Boot Chain (critical — many non-obvious requirements)

The live session differs fundamentally from the base image's boot flow. The base image uses root autologin → `exec startx` (no display manager). The live ISO uses lightdm → admin autologin → Xfce → Calamares autostart.

**Imager must configure** (all in Step 5b of `.build/images/shaughvos-imager`):
1. `graphical.target` as systemd default — base image uses `multi-user.target`; lightdm only starts under `graphical.target`
2. Root's getty autologin removed — otherwise root's `exec startx` conflicts with lightdm and crash-loops invisibly
3. `xserver-xorg-video-fbdev` + `xserver-xorg-video-vesa` installed — fbdev needs `/dev/fb0`, vesa works directly with VBE as universal fallback
4. `lightdm` + `lightdm-gtk-greeter` installed — base image has no display manager
5. `.install_stage=2` — prevents login script's first-run error handler
6. Calamares launcher script (`/usr/local/bin/launch-calamares`) — uses `xhost` + `sudo -E` + `LIBGL_ALWAYS_SOFTWARE=1`. Never use bare `sudo calamares` — Debian 12's sudo strips DISPLAY/XAUTHORITY even with NOPASSWD
7. Admin NOPASSWD sudo with `env_keep` for DISPLAY, XAUTHORITY, XDG_RUNTIME_DIR, DBUS_SESSION_BUS_ADDRESS
8. polkit rule (`49-shaughvos-live.rules`) for password-free admin access
9. `nomodeset` on ALL GRUB/isolinux boot entries AND in `/etc/default/grub` — VirtualBox VMSVGA + vmwgfx fails without it. The `/etc/default/grub` setting carries to the installed system via squashfs extraction + Calamares bootloader module
10. Remove `quiet` from "Install" boot entry — show boot messages for diagnostics; keep `quiet splash` only on "Live (safe graphics)" entry
11. Never exclude `/boot` from squashfs — strips kernel, initrd, and all shaughvOS scripts
12. Explicit `update-initramfs -u` after all package installs — ensures live-boot hooks are in initramfs

13. LightDM greeter configured with desktop wallpaper background, Makira font, Dracula theme, Papirus-Dark icons
14. System-wide fontconfig defaults — Makira for sans-serif/serif, IBM Plex Mono for monospace (`/etc/fonts/local.conf`)
15. `xserver-xorg-input-libinput` explicitly installed — safety measure for input drivers
16. `apt-get clean` + `autoremove` + list cleanup before squashfs creation — reduces ISO size

**Calamares module configs** (`assets/calamares/modules/`): `unpackfs.conf`, `bootloader.conf`, `partition.conf`, `users.conf`, `welcome.conf`, `finished.conf`, `services-systemd.conf` (re-enables preboot/postboot/ramlog), `shellprocess.conf` (comprehensive post-install cleanup — see below).

**Calamares shellprocess.conf cleanup sequence** (runs inside target chroot, BEFORE bootloader module):
1. Remove live-session files: sudoers, autologin, polkit rule, launcher script, Calamares .desktop files, `/etc/calamares/`
2. Purge packages: `live-boot`, `calamares`, `calamares-settings-debian` + autoremove
3. Security: delete SSH host keys + `ssh-keygen -A` (regenerate unique keys per install)
4. Remove stale `.check_user_passwords` flag (prevents false password-change prompts)
5. Rebuild initramfs (without live-boot hooks)
6. NOTE: Does NOT run `update-grub` — the `bootloader` module runs after shellprocess and handles GRUB itself

#### Desktop Autostart Mechanism

Two mechanisms exist (important for understanding conflicts):
- **Root (legacy):** getty autologin on tty1 → `shaughvos-login` → `Run_AutoStart(2)` → `exec startx` — does NOT use a display manager
- **Non-root (modern):** lightdm (`display-manager.service`) → autologin → Xfce session — comment in `shaughvos-login:34` confirms "non-root autologins are done via LightDM service since v7.2"
- **`desktop` command:** Uses `systemctl start/stop lightdm` — works with the lightdm mechanism

### Installed System LightDM Configuration (v1.11.0+)

After Calamares installs from the live ISO, the installed system's LightDM state:
- `/etc/lightdm/lightdm.conf.d/50-shaughvos.conf` — persistent config with `user-session=xfce` (survives shellprocess cleanup)
- `/etc/lightdm/lightdm-gtk-greeter.conf` — greeter appearance (wallpaper, Makira font, Dracula theme, Papirus-Dark icons)
- `/etc/lightdm/lightdm.conf.d/live-autologin.conf` — **REMOVED** by shellprocess (was only for the live session)
- `/etc/default/grub` has `GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=0 nomodeset quiet splash"` — enables Plymouth boot splash

### Plymouth Boot Splash (v1.11.0+)

Plymouth requires three things on the installed system:
1. `quiet splash` in `/etc/default/grub` — injected by imager into squashfs
2. Plymouth theme set + initramfs rebuilt — handled by `shaughvos-software` during base image build
3. `rootfs/etc/systemd/system/plymouth-quit.service.d/shaughvos-delay.conf` — 5-second minimum splash duration via `ExecStartPre=/bin/sleep 5`

**Important:** `quiet splash` was intentionally removed from the live ISO "Install" boot entry (v1.8.7) for diagnostics. The GRUB defaults only affect the installed system's everyday boot.

## Key Learnings & Gotchas

### Imager Runs Outside Repo Checkout in CI
The imager is downloaded via `curl` and runs from `/tmp/shaughvos-build`. It does NOT have access to the repo's `assets/` directory via `$FP_ORIGIN`. To access repo files, download from GitHub using `curl` with `$G_GITOWNER`/`$G_GITBRANCH` variables (set by shaughvos-globals).

### LightDM Session Config Must Survive Calamares
Calamares `shellprocess.conf` removes `live-autologin.conf` (which contained `autologin-session=xfce`). Without a persistent `user-session=xfce` somewhere, LightDM has no session config and login loops (black screen → back to greeter). Use named files in `.conf.d/` that shellprocess doesn't target.

### Greeter Wallpaper Must Not Rely on `curl || true`
The base image's `shaughvos-software` downloads wallpapers with `curl ... || true` (silent fail). If the download fails, the greeter shows a black background. The imager now checks if the file exists and downloads from GitHub if missing.

### Never Use `git push --tags`
Push specific tags only (e.g., `git push origin v1.11.0`). `--tags` leaks old DietPi-era tags that break CI workflows.

### Never Create GitHub Releases Manually
CI (`release-images.yml`) creates the Release and attaches build artifacts automatically when a `v*` tag is pushed. Running `gh release create` first blocks CI with "release already exists."

### Tag Retag Workflow (When CI Fails)
1. Delete remote tag: `git push --delete origin v1.X.0`
2. Delete local tag: `git tag -d v1.X.0`
3. Fix the code, commit
4. Retag: `git tag v1.X.0`
5. Push: `git push origin master && git push origin v1.X.0`

### Rootfs Overlay Mechanism
Files in `rootfs/` are copied to `/` by the installer via `cp -a "$dir/rootfs/." /` (shaughvos-installer:861). Systemd drop-ins, config files, and service units placed in `rootfs/etc/systemd/system/` automatically end up on the installed system.

### Live ISO vs Installed System Boot — Two Different Worlds
- **Live ISO:** lightdm + admin autologin → Xfce → Calamares autostart. Getty autologin REMOVED.
- **Installed system:** lightdm (graphical.target) → greeter → user login → Xfce session. Uses `50-shaughvos.conf` for session config, NOT `live-autologin.conf`.
- **Base image (non-ISO):** root getty autologin → `exec startx`. No display manager. Completely different path.

## Current Version

shaughvOS v1.11.0 (`.update/version`). Minimum Debian version: 7+.
