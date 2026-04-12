# shaughvOS Deployment Guide

This document covers the full release lifecycle: from development on `dev` through tagging, CI, image building, OTA updates, and GitHub Releases.

---

## Branch Flow

```
dev (active development)
 |
 v
beta (pre-release testing)
 |
 v
master (stable release — OTA updates pull from here)
```

All work happens on `dev`. When ready for testing, merge to `beta`. When stable, merge to `master` and tag.

---

## Release Checklist

### 1. Finalize changes on `dev`

```bash
# Ensure all changes are committed
git checkout dev
git status

# Run ShellCheck locally (mirrors CI)
shellcheck -C -xo all shaughvos/shaughvos-*
shellcheck -C -xo all shaughvos/func/shaughvos-*

# Verify zero DietPi references
grep -ri --exclude-dir='.git' --exclude='CHANGELOG.txt' \
  --exclude='README.md' --exclude='rebrand-audit.yml' \
  'dietpi' . | grep -v '.update/patches'
# Should return 0 results (or only allowlisted files)
```

### 2. Update version numbers

Edit `.update/version`:
```bash
G_REMOTE_VERSION_CORE=1
G_REMOTE_VERSION_SUB=1   # bump this for minor releases
G_REMOTE_VERSION_RC=0    # 0 for stable, >0 for release candidates
```

**Version scheme:**
- `CORE` = major version (breaking changes, major features)
- `SUB` = minor version (new features, improvements)
- `RC` = release candidate (0 = stable, 1+ = pre-release)

### 3. Update CHANGELOG.md

Move the `[Unreleased]` section to a new versioned section:

```markdown
## [1.1.0] — 2026-05-15

### Added
- ...

### Changed
- ...
```

Add a fresh empty `[Unreleased]` section at the top.

### 4. Update README if needed

If features changed, update the feature list, installation instructions, or download links.

### 5. Commit the release prep

```bash
git add .update/version CHANGELOG.md README.md
git commit -m "Release v1.1.0

- Bump version to 1.1.0
- Update changelog with release notes"
```

### 6. Merge to master

```bash
# Merge dev -> master
git checkout master
git merge dev

# Push master (this makes OTA updates available immediately)
git push origin master
```

**Important:** Once master is pushed, all deployed shaughvOS devices will see the new version on their next `shaughvos-update` check.

### 7. Create a version tag

```bash
git tag -a v1.1.0 -m "shaughvOS v1.1.0"
git push origin v1.1.0
```

The tag push triggers the automated image build workflow (when configured).

### 8. Create GitHub Release

```bash
gh release create v1.1.0 \
  --title "shaughvOS v1.1.0" \
  --notes-file - << 'EOF'
## shaughvOS v1.1.0

### What's New
(paste from CHANGELOG.md)

### Downloads
Images will be attached when the build workflow completes.

### Installation
1. Download the image for your platform
2. Flash with Balena Etcher, Rufus, or `dd`
3. Boot and enjoy shaughvOS

### Updating
Existing devices: run `shaughvos-update` or reboot (auto-checks on boot).
EOF
```

Once the image build workflow completes, attach the `.img.xz` files to the release.

---

## CI Pipeline

### On every push/PR

| Workflow | File | What it does |
|----------|------|-------------|
| ShellCheck | `shellcheck.yml` | Lints all shell scripts, checks whitespace |
| Rebrand Audit | `rebrand-audit.yml` | Counts remaining DietPi references (target: 0) |

### On version tag push (`v*`)

| Workflow | File | What it does |
|----------|------|-------------|
| Release Images | `release-images.yml` (to be created) | Builds `.img.xz` for RPi 4, x86_64 PC, x86_64 VM |

### Manual dispatch

| Workflow | File | What it does |
|----------|------|-------------|
| Build | `shaughvos-build.yml` | Manually build any hardware model/arch |

---

## OTA Update Flow

### How it works

1. Deployed devices read `DEV_GITOWNER` and `DEV_GITBRANCH` from `/boot/shaughvos.txt`
2. Defaults: `DEV_GITOWNER=RealEmmettS`, `DEV_GITBRANCH=master`
3. `shaughvos-update` fetches `https://raw.githubusercontent.com/RealEmmettS/shaughvOS/master/.update/version`
4. Compares remote version to local version
5. If newer: downloads pre-patches, pulls code from GitHub, runs patches
6. No custom server needed — GitHub raw content IS the update server

### Triggering an OTA update

Push to `master` with an updated `.update/version` file. That's it. Devices check on:
- Every boot (via `shaughvos-postboot`)
- Manual run: `shaughvos-update`
- Periodic cron check (if configured)

### Live patches (hotfixes)

For urgent fixes between releases, edit `.update/version` on `master`:

```bash
G_LIVE_PATCH_DESC=('Fix critical bug in shaughvos-config')
G_LIVE_PATCH_COND=('(( $G_SHAUGHVOS_VERSION_CORE == 1 && $G_SHAUGHVOS_VERSION_SUB == 0 ))')
G_LIVE_PATCH=('sed -i "s/broken/fixed/" /boot/shaughvos/shaughvos-config')
```

Live patches apply on next boot without a full update cycle.

---

## Image Building

### Build targets

| Target | Model | Arch | Output |
|--------|-------|------|--------|
| Raspberry Pi 4 | `--model 4` | aarch64 | `.img.xz` for SD card |
| x86_64 PC/Laptop | `--model 21` | x86_64 | `.img.xz` for USB |
| x86_64 VM | `--model 20` | x86_64 | `.img.xz` for VirtualBox/VMware |
| Bootable ISO | model 21 + imager | x86_64 | `.iso` via Clonezilla |

### Building locally (WSL2 or Linux host)

```bash
# Clone the repo
git clone https://github.com/RealEmmettS/shaughvOS.git
cd shaughvOS

# Build RPi 4 image
sudo bash .build/images/shaughvos-build --model 4 --arch aarch64 \
  --owner RealEmmettS --branch master

# Build x86_64 PC image
sudo bash .build/images/shaughvos-build --model 21 --arch x86_64 \
  --owner RealEmmettS --branch master
```

Build output is a `.img` file. Use `shaughvos-imager` to shrink and compress:

```bash
sudo bash .build/images/shaughvos-imager --source /path/to/output.img
```

### Quick-test without building images

Install on any Debian 12+ system:

```bash
sudo bash -c "$(curl -sSfL https://raw.githubusercontent.com/RealEmmettS/shaughvOS/master/.build/images/shaughvos-installer)"
```

### Flashing images

| Tool | Platform | Command |
|------|----------|---------|
| Balena Etcher | Windows/Mac/Linux | GUI — select `.img.xz`, select drive, flash |
| Rufus | Windows | Select `.img.xz`, select USB, write |
| `dd` | Linux/Mac | `xz -d < image.img.xz \| sudo dd of=/dev/sdX bs=4M status=progress` |
| Raspberry Pi Imager | Windows/Mac/Linux | Use "custom image" option |

---

## GitHub Release Page Structure

Each release should have:

```
shaughvOS v1.1.0
================

## Downloads
| Platform | File | How to use |
|----------|------|-----------|
| Raspberry Pi 4 | shaughvOS_RPi4-aarch64-Trixie.img.xz | Flash to SD card |
| PC / Laptop | shaughvOS_NativePC-x86_64-Trixie.img.xz | Flash to USB |
| Virtual Machine | shaughvOS_VM-x86_64-Trixie.img.xz | Import as disk |
| Bootable ISO | shaughvOS_NativePC-x86_64-Trixie.iso | Write to USB or mount in VM |

## What's New
(from CHANGELOG.md)

## Checksums
SHA256SUMS.txt attached
```

---

## Emergency Procedures

### Rollback a release

```bash
# On master, revert the merge
git revert HEAD
git push origin master

# Devices will see the reverted .update/version on next check
```

### Force-update a specific device

SSH into the device:
```bash
shaughvos-update 1    # Apply update non-interactively
shaughvos-update -1   # Reapply the last update
```
