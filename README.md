<h1 align="center"><img src="https://shaughv.s3.us-east-1.amazonaws.com/brandmark/SHAUGHV-Official.svg" alt="SHAUGHV logo" width="180" height="180" loading="lazy"></h1>
<p align="center">
	<b>shaughvOS</b>
	<br>A custom operating system for your devices.
	<br><br>
	lightweight &bull; diagnostic-ready &bull; beautifully themed
	<br><br>
	<a href="https://github.com/RealEmmettS/shaughvOS/releases">Downloads</a> &bull; <a href="https://github.com/RealEmmettS/shaughvOS">Source</a> &bull; <a href="https://github.com/RealEmmettS/shaughvOS/issues">Issues</a>
</p>
<hr>

## What is shaughvOS?

shaughvOS is a custom, lightweight operating system built on a Debian foundation. It comes ready to use out of the box — a polished desktop, professional diagnostic tools, and a streamlined terminal experience, all pre-configured so you can get to work immediately.

shaughvOS is the personal edition developed and used by [Emmett Shaughnessy](https://github.com/RealEmmettS), powered by [QubeTX](https://github.com/QubeTX) diagnostic tooling. It serves as the development testbed and daily-driver OS. An official QubeTX-branded edition for enterprise and professional deployment is in development.

Whether you're setting up a home server on a Raspberry Pi, diagnosing network issues on a client's machine, or just want a clean, fast Linux desktop, shaughvOS has you covered.

**Runs on:** Raspberry Pi 2/3/4/5, x86_64 PCs and laptops, Intel Macs, and virtual machines. Can also run as a live system directly from a USB drive without installing.

## What Can I Do With It?

### For Everyday Users

- **A beautiful, fast desktop** — shaughvOS boots into a polished Xfce desktop with the Dracula dark theme, custom fonts, and a clean taskbar. No bloatware, no clutter.
- **Try before you install** — boot the installer ISO to get a full live desktop you can explore. If you like it, click "Install" and it's on your disk in minutes.
- **Developer tools included** — Node.js, npm, and Claude Code CLI come pre-installed, so you can start coding right away.
- **Easy mode switching** — type `desktop on` for the graphical desktop or `desktop off` for a minimal console. Switch anytime.

**Getting started (the easy way):**

1. **For VirtualBox (try it on your computer):**
   - Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (free, by Oracle) and the [VM Installer ISO](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_VM-x86_64_Installer.iso).
   - Open VirtualBox and click **New**. In the wizard, enter a name (like `shaughvOS`), set **Type** to `Linux` and **Version** to `Debian (64-bit)`. Click **Next**.
   - On the **Hardware** page, set memory to at least `2048 MB` and processors to `2`. Click **Next**.
   - On the **Virtual Hard Disk** page, select **Create a Virtual Hard Disk Now**, set size to `20 GB` or more. Click **Next**, then **Finish**.
   - Before starting, click **Settings** > **Storage**, click the empty disc icon under Controller: IDE, click the small disc icon on the right, and choose **Choose a Disk File**. Select the `.iso` you downloaded. Also go to **Display** and set **Video Memory** to `128 MB`.
   - Click **Start**. The shaughvOS desktop loads and the installer walks you through the rest.
2. **For Raspberry Pi:**
   - Download and install [Balena Etcher](https://etcher.balena.io/) (free, by Balena) and the [Raspberry Pi image](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_RPi234-aarch64.img.xz).
   - Open Etcher, select the `.img.xz` file, select your microSD card, and click **Flash**.
   - Plug the microSD into your Pi and power it on. Done.
4. Default login: username `admin`, password `1234` (you'll be asked to change it on first boot).

### For Technicians & IT Professionals

- **Instant system diagnostics** — three professional-grade QubeTX tools run automatically on every login, giving you CPU, memory, disk, and network status at a glance.
- **Network troubleshooting** — 17 deep diagnostic checks including DNS resolution, gateway reachability, packet loss, MTU testing, and quad-provider speed testing with bufferbloat grading.
- **Portable diagnostic toolkit** — boot from a USB drive on any x86_64 machine to diagnose problems without touching the existing OS.
- **Headless server ready** — switch to console mode for a minimal-footprint server. Perfect for Raspberry Pi home labs, media servers, or IoT projects.

**Quick deployment:**

1. **USB diagnostic boot:** Download the [NativePC Installer ISO](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_NativePC-x86_64_Installer.iso), flash to USB with [Balena Etcher](https://etcher.balena.io/) (free, by Balena), and boot any x86_64 machine from it. Select "shaughvOS Live" for a non-destructive diagnostic session, or "Install shaughvOS" to deploy to the internal drive.
2. **VirtualBox lab:** Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (free, by Oracle). Create a VM (Linux/Debian 64-bit, 4 GB RAM, 2+ CPUs, 20 GB VDI, 128 MB video). Attach the [VM Installer ISO](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_VM-x86_64_Installer.iso) to the IDE optical drive. Boot, select Install, and Calamares handles partitioning and GRUB. SSH is available immediately via Dropbear on port 22.
3. **Raspberry Pi server:** Flash the [RPi image](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_RPi234-aarch64.img.xz) to microSD with [Balena Etcher](https://etcher.balena.io/). After first boot, run `desktop off` to switch to headless mode. Configure via SSH (`ssh admin@<ip>`, password `1234`).
4. **Existing Debian system:** `sudo bash -c "$(curl -sSfL https://raw.githubusercontent.com/RealEmmettS/shaughvOS/master/.build/images/shaughvos-installer)"` — converts any Debian 12+ system in-place.

## Features

### QubeTX 300 Series Diagnostics

Three professional-grade diagnostic tools are pre-installed on every shaughvOS system:

| Tool | Command | What It Does |
|------|---------|--------------|
| **TR-300** | `tr300` | Machine report — system info, CPU/memory/disk graphs, network details. Runs automatically on every terminal session. |
| **ND-300** | `nd300` | Network diagnostics — 8 core checks (user mode) or 17 deep diagnostics (technician mode with `nd300 -t`). |
| **SpeedQX** | `speedqx` | Quad-provider speed test with download/upload speeds and bufferbloat grading. |
| **SD-300** | `sd300` | Real-time interactive system diagnostic TUI with 9 monitoring sections. |

### Desktop Environment

- **Xfce** with the **Dracula** dark theme — GTK, window manager, terminal, and Papirus icons
- **Makira** sans-serif font for system UI
- **IBM Plex Mono** for terminal and code
- Custom desktop wallpaper
- Bottom taskbar with app menu and system tray
- Toggle between desktop and console with `desktop on` / `desktop off`

### Pre-Installed Software

- **Node.js & npm** — JavaScript runtime and package manager
- **Claude Code** — AI-powered coding assistant CLI
- **Dropbear SSH** — lightweight SSH server for remote access
- **Standard Debian tools** — apt, systemd, networking, and the full Debian package ecosystem

### Boot Experience

- **Plymouth boot splash** with the SHAUGHV logo
- **ASCII art banner** on every terminal session
- **TR-300 auto-report** after the splash — instant system overview on login

### Quick Commands

| Command | Description |
|---------|-------------|
| `desktop on` | Switch to desktop mode |
| `desktop off` | Switch to console mode |
| `desktop status` | Show current display mode |
| `tr300` or `report` | Machine report |
| `tr300 --fast` | Quick machine report |
| `nd300` | Network diagnostics (user mode) |
| `nd300 -t` | Network diagnostics (technician mode) |
| `speedqx` | Quad-provider speed test |
| `sd300` | Interactive system monitoring TUI |

## Installation

### Downloads

| Image | Hardware | How to use | Download |
|-------|----------|-----------|----------|
| **Raspberry Pi 2/3/4** | RPi 2, 3, 3B+, 4, 4B (ARM 64-bit) | Flash to microSD | [**Download .img.xz**](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_RPi234-aarch64.img.xz) |
| **Raspberry Pi 5** | RPi 5 (ARM 64-bit) | Flash to microSD | [**Download .img.xz**](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_RPi5-aarch64.img.xz) |
| **Native PC** | PCs, laptops, Intel Macs (x86_64) | Flash to USB drive | [**Download .img.xz**](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_NativePC-x86_64.img.xz) |
| **Native PC Installer** | PCs, laptops, Intel Macs (x86_64) | Boot from USB, installs to internal drive | [**Download .iso**](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_NativePC-x86_64_Installer.iso) |
| **Virtual Machine** | VirtualBox, VMware, UTM, QEMU | Import as raw disk image | [**Download .img.xz**](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_VM-x86_64.img.xz) |
| **VM Installer** | VirtualBox, VMware, UTM, QEMU | Boot ISO in VM, installs to virtual disk | [**Download .iso**](https://github.com/RealEmmettS/shaughvOS/releases/latest/download/shaughvOS_VM-x86_64_Installer.iso) |

> All images and SHA256 checksums are also available on the [Releases](https://github.com/RealEmmettS/shaughvOS/releases/latest) page.

### Raspberry Pi

**What you need:** A Raspberry Pi 2, 3, 4, or 5, a microSD card (8 GB or larger), and another computer to flash the image.

1. Download the correct image for your Pi from the table above.
   - RPi 2, 3, and 4 share the same image.
   - RPi 5 requires its own image (different bootloader).
2. Download and install [Balena Etcher](https://etcher.balena.io/).
3. Open Balena Etcher, select the `.img.xz` file (no need to decompress it), select your microSD card as the target, and click **Flash**.
4. Insert the microSD card into your Pi and power it on.
5. shaughvOS will run first-boot setup automatically — this takes a few minutes. When it finishes, the Xfce desktop appears with autologin.

### Native PC / Laptop / Intel Mac

**Option A: Run directly from USB**

1. Download the **Native PC** `.img.xz` image.
2. Open [Balena Etcher](https://etcher.balena.io/), select the `.img.xz` file, select your USB drive, and click **Flash**.
3. Boot your computer from the USB drive:
   - **PC:** Press `F12`, `F2`, `Esc`, or `Del` during startup to open the boot menu (varies by manufacturer), then select the USB drive.
   - **Intel Mac:** Hold the `Option` key at startup, then select the USB drive from the Startup Manager.
4. shaughvOS runs first-boot setup on the first boot, then starts the Xfce desktop.

**Option B: Install to internal drive**

1. Download the **Native PC Installer** `.iso` image.
2. Flash the `.iso` to a USB drive using [Balena Etcher](https://etcher.balena.io/).
3. Boot from the USB drive (same key as above).
4. The shaughvOS desktop loads in live mode. The **Calamares installer** launches automatically.
5. Follow the installer: choose language, keyboard, partitioning, and user account. Click **Install** to begin.
6. When installation completes, click **Restart**. Remove the USB drive when prompted.

### VirtualBox VM

1. Download the **VM Installer** `.iso` from the table above.
2. Open VirtualBox and click **New** to create a new virtual machine.
3. Configure the VM with these settings:

   | Setting | Value |
   |---------|-------|
   | **Name** | `shaughvOS` (or any name) |
   | **Type** | Linux |
   | **Version** | Debian (64-bit) |
   | **Base Memory** | 2048 MB minimum (4096 MB recommended) |
   | **Processors** | 2 or more |
   | **Hard Disk** | Create a virtual hard disk, VDI, 20 GB or larger |

4. Before starting the VM, open **Settings** and adjust:
   - **Storage:** Click the empty optical drive under Controller: IDE, then click the disk icon on the right and select **Choose a disk file**. Select the `.iso` you downloaded.
   - **Display > Video Memory:** Set to 128 MB.

5. Click **Start**. The boot menu appears with three options:
   - **Install shaughvOS** — boots the live desktop and launches the Calamares installer
   - **shaughvOS Live** — boots the live desktop without launching the installer (safe graphics mode)
   - **Power off** — shuts down the VM

6. Select **Install shaughvOS**. The shaughvOS desktop loads and the Calamares installer opens automatically.
7. Follow the installer: choose your language, keyboard layout, disk partitioning, and create a user account. Click **Install**.
8. When installation completes, click **Restart**. The VM reboots into the installed shaughvOS with the Xfce desktop.

> **Tip:** Remove the ISO from **Settings > Storage** after installation so the VM boots directly from the hard disk.

### Install on an existing Debian system

On a running Debian 12 (Bookworm) or later system:

```bash
sudo bash -c "$(curl -sSfL https://raw.githubusercontent.com/RealEmmettS/shaughvOS/master/.build/images/shaughvos-installer)"
```

Reboot after installation completes.

## Default Credentials

| Account | Username | Password |
|---------|----------|----------|
| **Admin** | `admin` | `1234` |
| **Root** | `root` | `1234` |

You will be prompted to change both passwords on first boot. The `admin` account has full `sudo` access and is used for desktop autologin.

## Target Hardware

| Target | Architecture | Image | Notes |
|--------|-------------|-------|-------|
| **Raspberry Pi 2/3/4** | aarch64 (ARMv8) | RPi234 | 1-8GB RAM. Shared boot firmware. |
| **Raspberry Pi 5** | aarch64 (ARMv8) | RPi5 | 4-8GB RAM. Separate bootloader. |
| **x86_64 PCs / Laptops** | x86_64 (Intel/AMD) | NativePC | Dual-boot or dedicated USB boot. |
| **Intel Macs** | x86_64 | NativePC | USB boot via Startup Manager (hold Option at boot). |
| **Apple Silicon Macs** | aarch64 | VM | Via UTM or Parallels only (no native boot). |
| **Virtual Machines** | x86_64 / aarch64 | VM | VirtualBox, VMware, UTM, QEMU, Parallels. |

## Technical Details

### System Architecture

shaughvOS is built on Debian Trixie (13) with a minimal footprint optimized for single-board computers and lightweight deployments. The system uses:

- **Kernel:** Standard Debian `linux-image-amd64` (x86) or Raspberry Pi kernel (ARM)
- **Init:** systemd with boot-optimized service ordering
- **Display manager:** LightDM with autologin
- **Desktop:** Xfce 4 with Dracula GTK/icon/WM themes
- **SSH:** Dropbear (lightweight) by default, OpenSSH available

### OTA Updates

shaughvOS devices check for updates automatically. When a new version is available, `shaughvos-update` pulls changes from the `master` branch on GitHub and applies incremental patches. No manual download or reinstall required.

### ISO Installer Architecture

The installer ISO uses Debian's `live-boot` system to boot a complete shaughvOS desktop in RAM. The **Calamares** installer framework (used by Manjaro, KDE Neon, Kubuntu, and 20+ Linux distributions) handles disk partitioning, filesystem creation, OS extraction from squashfs, and GRUB bootloader installation — all dynamically configured for your specific hardware.

### Software Management

shaughvOS uses APT (the standard Debian package manager) for all software. The full Debian package repository is available. Additionally, `shaughvos-software` provides a curated menu of pre-configured applications with one-command installs.

## Branch System

| Branch | Purpose |
|--------|---------|
| `master` | Stable release — OTA updates pull from here |
| `beta` | Pre-release public testing |
| `dev` | Active development — PRs target this branch |

## Contributing

shaughvOS is open source but maintained as a personal project. External pull requests are not accepted at this time. If you find a bug or have a suggestion, feel free to [open an issue](https://github.com/RealEmmettS/shaughvOS/issues).

---

## Attribution

shaughvOS is built on the **[DietPi](https://github.com/MichaIng/DietPi)** foundation — an extremely lightweight Debian-based OS for single-board computers. We are grateful to the DietPi project and its contributors for creating the excellent base that shaughvOS builds upon.

### DietPi Credits

- **[Daniel Knight](https://github.com/Fourdee)** — DietPi founder and original project lead
- **[MichaIng](https://github.com/MichaIng)** — DietPi project lead (2019–present), primary maintainer
- **[All DietPi contributors](https://github.com/MichaIng/DietPi/graphs/contributors)** — The community that built and maintains DietPi

DietPi is licensed under GPLv2. shaughvOS preserves this license.

### QubeTX 300 Series

The QubeTX diagnostic tools are developed by [QubeTX](https://github.com/QubeTX) and licensed under the PolyForm Noncommercial License. They are downloaded at install time from GitHub Releases, not embedded in the OS image.

---

## License

shaughvOS Copyright (C) 2026 [Emmett Shaughnessy](https://github.com/RealEmmettS)

Based on DietPi Copyright (C) 2025 [DietPi Contributors](https://github.com/MichaIng/DietPi/graphs/contributors)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>

## 3rd Party Sources

shaughvOS includes or integrates with software from many open-source projects, including:
[Linux kernel](https://github.com/torvalds/linux),
[GNU](https://www.gnu.org/),
[Bash](https://git.savannah.gnu.org/cgit/bash.git),
[Debian](https://salsa.debian.org/),
[Raspberry Pi](https://github.com/raspberrypi),
[Xfce](https://git.xfce.org/),
[Calamares](https://github.com/calamares/calamares),
[Dracula Theme](https://draculatheme.com/),
[Papirus Icons](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme),
[Plymouth](https://gitlab.freedesktop.org/plymouth/plymouth),
[LightDM](https://github.com/canonical/lightdm),
and [many more](https://github.com/MichaIng/DietPi#3rd-party-sourcescredits).
