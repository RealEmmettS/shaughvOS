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

shaughvOS is a custom, lightweight operating system built on a Debian foundation. It ships with a polished Xfce desktop, powerful diagnostic tools, and a streamlined terminal experience — all pre-configured and ready to use out of the box.

Designed for Raspberry Pi 2/3/4/5, x86_64 PCs and laptops, Intel Macs, and virtual machines.

## Features

### QubeTX 300 Series Diagnostics

Three professional-grade diagnostic tools are pre-installed on every shaughvOS system:

- **TR-300** (`tr300`) — Machine report with system info, CPU/memory/disk graphs, network details. Runs automatically on every terminal session.
- **ND-300** (`nd300`) — Network diagnostics with 8 core checks (user mode) and 17 deep diagnostics (technician mode). Includes **SpeedQX** (`speedqx`) quad-provider speed test with bufferbloat grading.
- **SD-300** (`sd300`) — Real-time interactive system diagnostic TUI with 9 monitoring sections.

### Desktop Environment

- **Xfce** with the **Dracula** dark theme — GTK, window manager, terminal, and icons
- **Makira** sans-serif font for system UI
- **IBM Plex Mono** for terminal and code
- Custom desktop wallpaper
- Bottom taskbar with app menu and system tray
- Toggle between desktop and console with `desktop on` / `desktop off`

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
| `tr300 --fast` | Quick machine report |
| `nd300` | Network diagnostics |
| `nd300 -t` | Technician-mode deep diagnostics |
| `speedqx` | Quad-provider speed test |
| `sd300` | Interactive system monitoring TUI |
| `report` | Alias for `tr300` |

## Installation

### Download a pre-built image

Visit the [Releases](https://github.com/RealEmmettS/shaughvOS/releases/latest) page and download the image for your hardware:

| Image | Hardware | CPU | How to flash |
|-------|----------|-----|-------------|
| `shaughvOS_RPi234-aarch64_*.img.xz` | Raspberry Pi 2, 3, 3B+, 4, 4B | ARM 64-bit (aarch64) | Balena Etcher or `dd` to microSD card |
| `shaughvOS_RPi5-aarch64_*.img.xz` | Raspberry Pi 5 | ARM 64-bit (aarch64) | Balena Etcher or `dd` to microSD card |
| `shaughvOS_NativePC-x86_64_*.img.xz` | PCs, laptops, Intel Macs | x86_64 (Intel/AMD) | Balena Etcher or Rufus to USB drive |
| `shaughvOS_VM-x86_64_*.img.xz` | VirtualBox, VMware, UTM, QEMU | x86_64 (virtual) | Import as raw disk image |

> **Which image do I need?**
> - **Raspberry Pi 2/3/4** share the same image — one download covers all three generations.
> - **Raspberry Pi 5** requires its own image due to a different bootloader and device tree.
> - **Native PC** is for booting directly on real hardware via USB (dual-boot or dedicated).
> - **VM** is for running inside a virtual machine (no hardware boot firmware needed).

### Install on an existing Debian system

On a running Debian 12 (Bookworm) or later system:

```bash
sudo bash -c "$(curl -sSfL https://raw.githubusercontent.com/RealEmmettS/shaughvOS/master/.build/images/shaughvos-installer)"
```

Reboot after installation completes.

## Target Hardware

| Target | Architecture | Image | Notes |
|--------|-------------|-------|-------|
| **Raspberry Pi 2/3/4** | aarch64 (ARMv8) | RPi234 | 1-8GB RAM. Shared boot firmware. |
| **Raspberry Pi 5** | aarch64 (ARMv8) | RPi5 | 4-8GB RAM. Separate bootloader. |
| **x86_64 PCs / Laptops** | x86_64 (Intel/AMD) | NativePC | Dual-boot or dedicated USB boot. |
| **Intel Macs** | x86_64 | NativePC | USB boot via Startup Manager (hold Option at boot). |
| **Apple Silicon Macs** | aarch64 | VM | Via UTM or Parallels only (no native boot). |
| **Virtual Machines** | x86_64 / aarch64 | VM | VirtualBox, VMware, UTM, QEMU, Parallels. |

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
[Dracula Theme](https://draculatheme.com/),
[Papirus Icons](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme),
[Plymouth](https://gitlab.freedesktop.org/plymouth/plymouth),
[LightDM](https://github.com/canonical/lightdm),
and [many more](https://github.com/MichaIng/DietPi#3rd-party-sourcescredits).
