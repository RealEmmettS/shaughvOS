# Custom IT OS — Default Toolkit Reference

*A comprehensive install manifest for a DietPi-based IT/cybersecurity technician's OS.*

---

## Notes on Repository Setup

Most of these are in standard Debian repos. A few notes before you start:

- **Kali repos** (optional): Adding the Kali Linux repo (pinned low-priority) gives you access to `metasploit-framework`, `responder`, `crackmapexec`/`nxc`, `impacket-scripts`, `exploitdb`, `wifite`, etc. without cluttering your base. Pin it so nothing installs from Kali unless you explicitly request it.
- **Backports**: Enable `bookworm-backports` (or whatever base release) for newer versions of tools like `nmap`, `wireshark`, `ffuf`.
- **Rust/Cargo**: Some modern tools ship fastest via `cargo install` — worth having the Rust toolchain installed early.
- **pipx**: For Python CLI tools (impacket, certipy, bloodhound.py, etc.), `pipx` keeps them isolated and clean.

---

## 1. Base System & Shell Environment

Foundation layer — what makes the OS pleasant to actually use.

| Tool | Package | Why |
|------|---------|-----|
| zsh | `zsh` | Primary interactive shell; better than bash for daily use |
| fish | `fish` | Alternative shell option; great for novice scripters |
| tmux | `tmux` | Terminal multiplexer — essential for remote/persistent sessions |
| screen | `screen` | Fallback multiplexer when tmux isn't available |
| bash-completion | `bash-completion` | Improves default bash if users stick with it |
| starship | via install script or `cargo install starship` | Fast, customizable prompt |
| vim | `vim` | The editor everyone falls back to |
| neovim | `neovim` | Modern vim; preferred default |
| nano | `nano` | Friendly editor for quick edits |
| micro | `micro` | More intuitive than nano, great default for less-technical users |
| sudo | `sudo` | Obvious |
| curl | `curl` | Non-negotiable |
| wget | `wget` | Script-friendly downloader |
| man-db | `man-db manpages manpages-dev` | Offline manual pages |
| tldr | `tldr` or `tealdeer` | Community-curated cheat sheets |
| less | `less` | Pager (usually default, verify it's there) |

---

## 2. Modern CLI Replacements

These Rust/Go-based replacements are dramatically nicer than the coreutils defaults. Worth installing by default.

| Tool | Package | Replaces / Adds |
|------|---------|-----------------|
| ripgrep | `ripgrep` | grep (10–100x faster) |
| fd-find | `fd-find` | find (ergonomic syntax) |
| bat | `bat` | cat (syntax highlighting, line numbers) |
| eza | via cargo or deb | ls (colors, git-aware) |
| zoxide | `zoxide` | cd (frecency-based jumping) |
| fzf | `fzf` | Fuzzy finder — pipe anything into it |
| btop | `btop` | htop/top replacement (gorgeous) |
| htop | `htop` | Keep as fallback |
| bottom | `cargo install bottom` (binary: `btm`) | htop alternative |
| dust | `cargo install du-dust` | du replacement |
| duf | `duf` | df replacement |
| ncdu | `ncdu` | Interactive disk usage |
| procs | `cargo install procs` | ps replacement |
| hyperfine | `hyperfine` | Benchmarking tool |
| jq | `jq` | JSON processor — absolutely essential |
| yq | via snap/binary | YAML processor |
| sd | `cargo install sd` | sed replacement |
| delta | `git-delta` | Better git diffs |
| glow | via binary | Render Markdown in terminal |
| just | `cargo install just` | Modern make alternative |

---

## 3. Version Control & Development

You'll want these for pulling tools, scripts, and custom tooling.

| Tool | Package | Purpose |
|------|---------|---------|
| git | `git` | Obvious |
| git-lfs | `git-lfs` | Large file handling |
| gh | `gh` (GitHub CLI) | GitHub from terminal |
| lazygit | via binary | TUI for git |
| build-essential | `build-essential` | gcc, make, etc. |
| cmake | `cmake` | Cross-platform build tool |
| gdb | `gdb` | Debugger |
| strace | `strace` | Syscall tracing |
| ltrace | `ltrace` | Library call tracing |
| python3 | `python3 python3-pip python3-venv pipx` | Runtime + package managers |
| nodejs + npm | `nodejs npm` | Runtime (consider NodeSource repo for modern versions) |
| go | `golang` | Many security tools are written in Go |
| rust | via rustup | For installing modern CLI tools |
| ruby | `ruby` | Some pentest tools (wpscan, etc.) |
| perl | Usually pre-installed | Scripting glue |

---

## 4. Network Diagnostics (The IT Bread & Butter)

This is where you'll spend most of your field time.

| Tool | Package | Use Case |
|------|---------|----------|
| iproute2 | `iproute2` | `ip`, `ss` — modern replacements for ifconfig/netstat |
| net-tools | `net-tools` | Legacy `ifconfig`, `netstat`, `arp` (some techs still prefer) |
| dnsutils | `dnsutils` | dig, nslookup, host |
| whois | `whois` | Domain lookups |
| iputils-ping | `iputils-ping` | ping |
| iputils-tracepath | `iputils-tracepath` | tracepath |
| traceroute | `traceroute` | Classic traceroute |
| mtr | `mtr` | Combined ping + traceroute, live updates |
| fping | `fping` | Fast parallel ping for ranges |
| hping3 | `hping3` | TCP/UDP/ICMP ping & custom packet crafting |
| nmap | `nmap` | Port scanning, service detection, scripting engine |
| ncat | `ncat` (part of nmap) | Swiss army netcat |
| netcat-openbsd | `netcat-openbsd` | Classic netcat fallback |
| socat | `socat` | Multi-purpose relay (more powerful than netcat) |
| arp-scan | `arp-scan` | Layer 2 discovery — great for finding stuff on a LAN |
| arping | `arping` | ARP-level pinging |
| netdiscover | `netdiscover` | Passive/active ARP discovery |
| ipcalc | `ipcalc` | Subnet math |
| sipcalc | `sipcalc` | More advanced subnet calculations |
| iperf3 | `iperf3` | Bandwidth testing |
| speedtest-cli | `speedtest-cli` | Ookla speed tests from CLI |
| mtr-tiny | `mtr-tiny` | Non-GUI version |
| nethogs | `nethogs` | Per-process bandwidth |
| iftop | `iftop` | Top-style traffic monitor |
| nload | `nload` | Simple traffic view |
| bmon | `bmon` | Bandwidth monitor with graphs |
| vnstat | `vnstat` | Long-term traffic logging |
| bandwhich | `cargo install bandwhich` | Modern per-process network usage |
| doggo / dog | via binary | Modern dig replacement |
| ethtool | `ethtool` | NIC diagnostics & config |
| mii-tool | `net-tools` | Link status fallback |
| lldpd | `lldpd` | LLDP for discovering managed switch info |
| cdpr | via binary | Cisco Discovery Protocol sniffer — extremely useful in enterprise |

---

## 5. Packet Capture & Analysis

| Tool | Package | Purpose |
|------|---------|---------|
| tcpdump | `tcpdump` | The standard packet sniffer |
| tshark | `tshark` | Wireshark CLI — full dissector capability |
| wireshark | `wireshark` | GUI (optional — only if you ship a GUI) |
| termshark | via binary | Terminal UI over tshark |
| ngrep | `ngrep` | grep for network packets |
| mitmproxy | `mitmproxy` | HTTPS interception proxy |
| nfcapd / nfdump | `nfdump` | NetFlow capture/analysis |

---

## 6. DNS Tools

| Tool | Package | Purpose |
|------|---------|---------|
| bind9-dnsutils | `bind9-dnsutils` | Core dig/host/nslookup |
| dnsrecon | `dnsrecon` | DNS enumeration |
| dnsenum | `dnsenum` | DNS brute force/zone transfer |
| dnstracer | `dnstracer` | Resolution path tracing |
| massdns | from source | Bulk DNS resolver |
| dnsmasq | `dnsmasq` | Lightweight DNS/DHCP server — useful for on-site lab work |

---

## 7. Wireless / Wi-Fi Tools

Essential for field diagnostics and security auditing.

| Tool | Package | Purpose |
|------|---------|---------|
| wireless-tools | `wireless-tools` | Legacy `iwconfig`, `iwlist` |
| iw | `iw` | Modern wireless config |
| wpasupplicant | `wpasupplicant` | WPA/WPA2/WPA3 client |
| hostapd | `hostapd` | Turn the device into an AP (useful for captive portal testing) |
| aircrack-ng | `aircrack-ng` | Full Wi-Fi audit suite |
| kismet | `kismet` | Passive wireless discovery & logging |
| wavemon | `wavemon` | Wi-Fi signal monitor |
| reaver | `reaver` | WPS brute force |
| bully | `bully` | Alternative WPS attack tool |
| wifite | from Kali repo or git | Automated Wi-Fi audit |
| horst | `horst` | Lightweight 802.11 scanner |
| linssid | `linssid` | GUI Wi-Fi scanner (if GUI) |
| mdk4 | `mdk4` | Wi-Fi testing/stress |

---

## 8. Web / HTTP Tools

| Tool | Package | Purpose |
|------|---------|---------|
| curl | `curl` | Essential |
| httpie | `httpie` | Friendlier curl |
| wget | `wget` | Downloader |
| aria2 | `aria2` | Multi-connection downloader |
| gobuster | `gobuster` | Content/DNS bruteforcing |
| ffuf | `ffuf` | Fast web fuzzer (often preferred over gobuster now) |
| feroxbuster | via binary | Rust-based recursive content discovery |
| dirb | `dirb` | Classic directory brute-forcer |
| nikto | `nikto` | Web server vuln scanner |
| wpscan | `wpscan` | WordPress scanner |
| sqlmap | `sqlmap` | SQL injection automation |
| whatweb | `whatweb` | Web tech fingerprinting |
| httpx | via Go install | Fast HTTP probe (from ProjectDiscovery) |
| nuclei | via Go install | Template-based vuln scanner |
| subfinder | via Go install | Subdomain enumeration |
| amass | `amass` | OSINT-driven recon |
| aquatone | via binary | Visual recon / screenshot sweeps |
| gau | via Go install | Fetch known URLs from archives |
| waybackurls | via Go install | Archive.org URL mining |

---

## 9. Password & Credential Tools

| Tool | Package | Purpose |
|------|---------|---------|
| john | `john` | John the Ripper — CPU cracking |
| hashcat | `hashcat` | GPU cracking (less useful on Pi, but good on x86 fork) |
| hydra | `hydra` | Network login brute forcer |
| medusa | `medusa` | Alternative to hydra |
| ncrack | `ncrack` | Nmap's network auth cracker |
| cewl | `cewl` | Custom wordlist from websites |
| crunch | `crunch` | Wordlist generator |
| wordlists | `wordlists` | SecLists + rockyou |
| chntpw | `chntpw` | **Huge** — reset Windows NT/7/10/11 local passwords offline |
| samdump2 | `samdump2` | Extract NTLM hashes from SAM |
| ophcrack | `ophcrack` | Rainbow-table Windows password recovery |
| seclists (manual) | via git | Comprehensive wordlists (passwords, payloads, etc.) |
| pass | `pass` | Unix password manager (for your own creds) |
| gopass | via binary | Modern pass fork with extras |

---

## 10. Exploitation / AD / Offensive Tooling

Ship these even on an "IT" OS — you'll want them for authorized pen tests and internal audits.

| Tool | Package | Purpose |
|------|---------|---------|
| metasploit-framework | from Kali repo or official installer | The framework |
| impacket-scripts | `pipx install impacket` | AD & SMB toolkit (secretsdump, psexec, wmiexec, etc.) |
| nxc (NetExec) | `pipx install netexec` | Successor to crackmapexec — AD swiss army knife |
| responder | from git | LLMNR/NBT-NS/mDNS poisoner |
| evil-winrm | `gem install evil-winrm` | WinRM shell |
| certipy-ad | `pipx install certipy-ad` | AD CS (ESC1–ESC11) attacks |
| bloodhound.py | `pipx install bloodhound` | AD recon collector |
| mimikatz (Windows only) | external | Note in docs; runs from Windows targets |
| exploitdb | `exploitdb` | searchsploit offline DB |
| routersploit | from git | Router/IoT exploitation framework |
| set | `set` (from Kali) | Social Engineer Toolkit |

---

## 11. Forensics & Data Recovery

**This is the stuff that saves clients' data.** Absolute must-haves for Geek Squad-style work.

| Tool | Package | Purpose |
|------|---------|---------|
| testdisk | `testdisk` | Partition recovery — lifesaver |
| photorec | `testdisk` (bundled) | File carving |
| foremost | `foremost` | File carving by signature |
| scalpel | `scalpel` | Configurable file carver |
| extundelete | `extundelete` | Recover deleted files from ext3/ext4 |
| ext4magic | `ext4magic` | Alternative ext4 recovery |
| ntfs-3g | `ntfs-3g` | Read/write NTFS |
| ntfsundelete | `ntfs-3g` (bundled) | Recover deleted NTFS files |
| ddrescue | `gddrescue` | **Critical** — image failing drives |
| dcfldd | `dcfldd` | Forensic dd with hashing |
| dc3dd | `dc3dd` | Another forensic dd |
| sleuthkit | `sleuthkit` | TSK — file system forensics |
| autopsy | `autopsy` | Web UI on top of sleuthkit |
| binwalk | `binwalk` | Firmware / embedded binary analysis |
| bulk-extractor | `bulk-extractor` | Carve emails, CCNs, URLs from images |
| volatility3 | `pipx install volatility3` | Memory forensics |
| foremost | `foremost` | File recovery by headers |
| chkrootkit | `chkrootkit` | Rootkit scanner |
| rkhunter | `rkhunter` | Another rootkit hunter |
| clamav + freshclam | `clamav clamav-freshclam` | Open-source AV engine |
| yara | `yara` | Malware pattern matching |
| exiftool | `libimage-exiftool-perl` | Metadata extraction — huge for investigations |

---

## 12. Disk, Filesystem & Imaging

| Tool | Package | Purpose |
|------|---------|---------|
| parted | `parted` | Partitioning |
| gparted | `gparted` | GUI partitioning (if GUI shipped) |
| fdisk / sfdisk / cfdisk | `fdisk` | Classic partition tools |
| gdisk | `gdisk` | GPT-aware fdisk |
| lsblk / blkid | `util-linux` | Block device listing |
| smartmontools | `smartmontools` | SMART drive health (`smartctl`) |
| hdparm | `hdparm` | ATA drive info & config |
| nvme-cli | `nvme-cli` | NVMe drive management |
| badblocks | `e2fsprogs` | Surface scan |
| e2fsprogs | `e2fsprogs` | ext2/3/4 tools |
| xfsprogs | `xfsprogs` | XFS tools |
| btrfs-progs | `btrfs-progs` | btrfs tools |
| dosfstools | `dosfstools` | FAT tools |
| exfatprogs | `exfatprogs` | Modern exFAT |
| f2fs-tools | `f2fs-tools` | Flash-friendly FS (SD cards, etc.) |
| cryptsetup | `cryptsetup` | LUKS encrypted volumes |
| veracrypt | via binary | Cross-platform encrypted containers |
| gnome-disks / udisks2 | `gnome-disk-utility` | Friendly disk GUI (if GUI) |
| partclone | `partclone` | Efficient partition imaging |
| clonezilla | via ISO or packages | Full disk cloning solution |
| squashfs-tools | `squashfs-tools` | squashfs image mgmt |
| dd (bundled) | `coreutils` | Classic imager |
| pv | `pv` | Progress bar for dd/pipes |

---

## 13. System Monitoring & Diagnostics

| Tool | Package | Purpose |
|------|---------|---------|
| htop | `htop` | Process monitor |
| btop | `btop` | Prettier htop |
| glances | `glances` | Cross-platform overview |
| atop | `atop` | Historical system activity |
| iotop | `iotop` | Per-process disk I/O |
| iostat | `sysstat` | Disk I/O stats |
| vmstat | `procps` | Memory/CPU stats |
| sar | `sysstat` | Historical system metrics |
| nmon | `nmon` | Curses-based monitor |
| sensors | `lm-sensors` | Temperature/voltage |
| powertop | `powertop` | Power analysis |
| stress | `stress` | Load generator |
| stress-ng | `stress-ng` | Richer stress tester |
| sysbench | `sysbench` | Benchmarking |
| memtester | `memtester` | Live RAM test |
| memtest86+ | `memtest86+` | Boot-level RAM test (install as boot option) |
| dstat | `dstat` | Combined stats tool |
| bpytop | `bpytop` | Predecessor to btop, still fine |

---

## 14. Hardware & Firmware Inspection

| Tool | Package | Purpose |
|------|---------|---------|
| lshw | `lshw` | Comprehensive hardware list |
| inxi | `inxi` | Human-readable system info |
| hwinfo | `hwinfo` | Another hardware probe |
| dmidecode | `dmidecode` | SMBIOS/DMI info |
| lspci / pciutils | `pciutils` | PCI devices |
| lsusb / usbutils | `usbutils` | USB devices |
| usbtop | `usbtop` | USB bandwidth monitor |
| pciutils | `pciutils` | Included in lspci |
| fwupd | `fwupd` | Firmware updates on Linux |
| ipmitool | `ipmitool` | IPMI / out-of-band management |
| freeipmi-tools | `freeipmi-tools` | Alt IPMI stack |
| i2c-tools | `i2c-tools` | I2C bus probing |
| read-edid | `read-edid` | Read monitor EDID info |

---

## 15. Firewall / IDS / IPS / Hardening

| Tool | Package | Purpose |
|------|---------|---------|
| ufw | `ufw` | Friendly iptables wrapper |
| iptables | `iptables` | Classic |
| nftables | `nftables` | Modern replacement |
| firewalld | `firewalld` | Dynamic firewall (optional) |
| fail2ban | `fail2ban` | Intrusion prevention |
| lynis | `lynis` | Hardening auditor |
| tiger | `tiger` | System auditor |
| aide | `aide` | File integrity monitoring |
| tripwire | `tripwire` | FIM alternative |
| apparmor / utils | `apparmor apparmor-utils` | MAC policy |
| auditd | `auditd` | Kernel auditing |
| suricata | `suricata` | IDS/IPS |
| snort | `snort` | Classic IDS |
| zeek | `zeek` | Network security monitor (formerly Bro) |

---

## 16. VPN & Tunneling

| Tool | Package | Purpose |
|------|---------|---------|
| openvpn | `openvpn` | Classic VPN |
| wireguard | `wireguard wireguard-tools` | Modern lightweight VPN |
| openconnect | `openconnect` | Cisco AnyConnect-compatible |
| strongswan | `strongswan` | IPsec |
| shadowsocks | `shadowsocks-libev` | Bypass restrictive networks |
| tor + torsocks | `tor torsocks` | Tor client |
| proxychains4 | `proxychains4` | Chain proxies per-command |
| sshuttle | `sshuttle` | "Poor man's VPN" over SSH |
| stunnel | `stunnel4` | SSL tunneling |
| autossh | `autossh` | Persistent SSH tunnels |

---

## 17. Remote Access (In & Out)

| Tool | Package | Purpose |
|------|---------|---------|
| openssh-server | `openssh-server` | SSHd |
| openssh-client | `openssh-client` | SSH client |
| mosh | `mosh` | Resilient mobile shell |
| sshfs | `sshfs` | Mount remote filesystems |
| rsync | `rsync` | Efficient file sync |
| rclone | `rclone` | Cloud storage sync (S3, GDrive, Dropbox, etc.) |
| tigervnc | `tigervnc-standalone-server tigervnc-viewer` | VNC |
| x11vnc | `x11vnc` | Share existing X session |
| noVNC | `novnc` | Browser-based VNC access |
| xrdp | `xrdp` | RDP server for Linux |
| rdesktop | `rdesktop` | Legacy RDP client |
| freerdp2-x11 | `freerdp2-x11` (`xfreerdp`) | Modern RDP client |
| remmina | `remmina` | Multi-protocol remote GUI |
| rustdesk | via binary | Open-source TeamViewer alternative |

---

## 18. File Transfer, Sync & Backup

| Tool | Package | Purpose |
|------|---------|---------|
| rsync | `rsync` | Gold standard |
| rclone | `rclone` | Cloud sync |
| borgbackup | `borgbackup` | Deduplicating backup |
| restic | `restic` | Modern backup with cloud targets |
| duplicity | `duplicity` | GPG-encrypted backup |
| timeshift | `timeshift` | System snapshots |
| lftp | `lftp` | Advanced FTP/HTTP/SFTP |
| croc | via binary | Peer-to-peer file transfer |
| magic-wormhole | `magic-wormhole` | Simple secure transfer |
| woof | via pip | Quick one-off HTTP file serve |
| miniserve | `cargo install miniserve` | Quick HTTP file server |

---

## 19. Archives & Compression

| Tool | Package | Purpose |
|------|---------|---------|
| zip / unzip | `zip unzip` | ZIP |
| p7zip-full | `p7zip-full` | 7z, plus strong cross-format support |
| unrar | `unrar` | RAR (non-free) |
| tar | `tar` | Obvious |
| gzip / bzip2 / xz-utils / zstd | Respective packages | Compression codecs |
| pigz / pbzip2 / pixz | Parallel variants | Faster on multicore |
| cabextract | `cabextract` | Windows .cab files — useful for Windows repair |
| innoextract | `innoextract` | Extract Inno Setup installers |
| chirp (Windows .exe) | via Wine | For weirder extractions |

---

## 20. Reverse Engineering & Binary Analysis

| Tool | Package | Purpose |
|------|---------|---------|
| radare2 | `radare2` | Full RE suite |
| rizin | via binary | Community fork of r2 |
| cutter | via AppImage | GUI for rizin |
| ghidra | via install script | NSA's disassembler (heavy; Java) |
| binwalk | `binwalk` | Firmware analysis |
| strings | `binutils` | ASCII extraction |
| objdump / nm / readelf | `binutils` | ELF inspection |
| hexdump / xxd | `util-linux` / `xxd` | Hex viewers |
| hexyl | `cargo install hexyl` | Pretty hex viewer |
| gdb + gef/pwndbg | gdb + git-installed plugin | Enhanced debugging |
| upx | `upx-ucl` | Pack/unpack binaries |

---

## 21. Containers & Virtualization

| Tool | Package | Purpose |
|------|---------|---------|
| docker-ce + compose | via Docker repo | Container runtime |
| podman | `podman` | Rootless alternative |
| buildah / skopeo | `buildah skopeo` | Image building/copying |
| lxc / lxd | `lxc` | System containers |
| qemu + qemu-utils | `qemu-system qemu-utils` | Emulation / image mounting |
| libvirt + virt-manager | `libvirt-daemon-system virt-manager` | VM management |
| virtualbox | via Oracle repo | Desktop VMs (if x86) |

---

## 22. Windows-Oriented Rescue & Repair Tools

This is the high-leverage stuff for Geek Squad–style work where you're resurrecting Windows machines.

| Tool | Package | Purpose |
|------|---------|---------|
| chntpw | `chntpw` | **Reset Windows local passwords** |
| ntfs-3g + ntfsprogs | `ntfs-3g` | Full NTFS read/write + utilities |
| wine + winetricks | `wine winetricks` | Run Windows binaries when needed |
| cabextract | `cabextract` | Windows `.cab` extraction |
| freerdp | `freerdp2-x11` | RDP into Windows hosts |
| smbclient / cifs-utils | `smbclient cifs-utils` | SMB/CIFS access |
| samba | `samba` | Share files with Windows |
| impacket | `pipx install impacket` | AD/Windows protocol toolkit |
| wimtools | `wimtools` | Manipulate Windows .wim images |
| chntpw companion tools | `reglookup` | Offline Windows registry lookup |
| regripper | from git | Forensic registry parsing |
| libvshadow-utils | `libvshadow-utils` | Access Windows volume shadow copies |

---

## 23. IoT / Embedded / Hardware Hacking

Since this is on a DietPi base, you may want these even more than on a desktop distro.

| Tool | Package | Purpose |
|------|---------|---------|
| minicom | `minicom` | Serial terminal |
| picocom | `picocom` | Lighter serial terminal |
| screen | `screen` | Works as a serial terminal too |
| setserial | `setserial` | Configure serial ports |
| arduino-cli | via binary | Arduino toolchain from CLI |
| avrdude | `avrdude` | AVR programming |
| openocd | `openocd` | JTAG/SWD on-chip debugger |
| flashrom | `flashrom` | SPI flash read/write |
| esptool | `pipx install esptool` | ESP32/ESP8266 flashing |
| rpitools | OS-specific | Pi-specific diagnostics |
| can-utils | `can-utils` | CAN bus tools |
| sigrok-cli / pulseview | `sigrok-cli pulseview` | Logic analyzer frontend |
| hackrf | `hackrf` | SDR hardware tools |
| rtl-sdr | `rtl-sdr` | Cheap SDR support |
| gqrx-sdr | `gqrx-sdr` | SDR GUI receiver |

---

## 24. Bluetooth

| Tool | Package | Purpose |
|------|---------|---------|
| bluez | `bluez` | Linux Bluetooth stack |
| bluez-tools | `bluez-tools` | Extra utilities |
| bluelog | `bluelog` | BT device logging |
| btscanner | `btscanner` | BT discovery |
| spooftooph | `spooftooph` | BT identity spoofing |

---

## 25. Data & Database Tools

| Tool | Package | Purpose |
|------|---------|---------|
| sqlite3 | `sqlite3` | Embedded SQL |
| postgresql-client | `postgresql-client` | psql |
| default-mysql-client | `default-mysql-client` | MySQL/MariaDB client |
| redis-tools | `redis-tools` | redis-cli |
| mongodb-clients | via MongoDB repo | mongosh |
| jq / yq / miller | `jq yq` + `mlr` | JSON/YAML/CSV processing |

---

## 26. OSINT / Reconnaissance (Optional Pack)

| Tool | Package | Purpose |
|------|---------|---------|
| theharvester | `theharvester` | Email/domain intel |
| sherlock | `pipx install sherlock-project` | Username hunter |
| recon-ng | `recon-ng` | Recon framework |
| spiderfoot | from git | Automated OSINT |
| maltego | via binary | Visual OSINT (GUI) |

---

## 27. Logging & Observability (if you want a self-monitoring image)

| Tool | Package | Purpose |
|------|---------|---------|
| rsyslog | `rsyslog` | Syslog |
| logrotate | `logrotate` | Log rotation |
| journalctl | (systemd) | Journal access |
| lnav | `lnav` | Log file navigator — beautiful |
| multitail | `multitail` | Tail multiple logs |
| goaccess | `goaccess` | Web log analyzer |

---

## 28. PXE / Boot-Server Mode (Stretch Goal)

If the OS doubles as a deployable field box for imaging other machines:

| Tool | Package | Purpose |
|------|---------|---------|
| dnsmasq | `dnsmasq` | DHCP + DNS + TFTP in one |
| tftpd-hpa | `tftpd-hpa` | Dedicated TFTP server |
| syslinux / pxelinux | `syslinux pxelinux` | Bootloaders |
| ipxe | `ipxe` | Modern PXE with scripting |
| nfs-kernel-server | `nfs-kernel-server` | Root-over-NFS for thin clients |
| nginx / apache2 | respective | HTTP server for boot assets |

---

## Recommended Tiering

If you want to split this into install levels, here's a reasonable partitioning:

- **Tier 0 (Core)**: Sections 1, 2, 3, 4, 5, 6, 12, 13, 15, 17, 18, 19
- **Tier 1 (IT Tech)**: Tier 0 + 7, 11, 14, 22, 24
- **Tier 2 (Security Analyst)**: Tier 1 + 8, 9, 10, 16, 20, 26
- **Tier 3 (Everything + Kitchen Sink)**: All of it, plus 21, 23, 27, 28

You could implement this as a `dietpi-software` custom menu or a set of metapackages (`qube-tier0`, `qube-tier1`, etc.) so you install only what a given build needs.

---

## Things Worth NOT Installing by Default

A few that are tempting but probably better left to a user-triggered install:

- **GUI apps** (Burp Suite, Maltego, Ghidra) — huge downloads, heavy dependencies. Ship install scripts instead.
- **Metasploit** — large install footprint (~2 GB) and DB setup overhead. Offer as an optional module.
- **Hashcat** on ARM — no GPU support on most Pi hardware makes it niche. Install conditionally.
- **Docker** — it's great, but it bloats a base image. Make it a Tier 1+ option.
- **Anything with a licensing hassle** (Nessus, BurpPro, AnyDesk) — document installation rather than bundling.

---

## Configuration Defaults Worth Shipping

Beyond just installed packages, you'll want some preconfiguration:

- **Sane `~/.bashrc` / `~/.zshrc`** with aliases, starship, fzf keybindings
- **`~/.tmux.conf`** with sensible defaults
- **`~/.ssh/config`** template
- **Pre-populated `/etc/hosts`** for common internal ranges
- **Custom MOTD** showing IP addresses, uptime, drive health at login
- **Preconfigured `ufw` default-deny-incoming**
- **`fail2ban` enabled by default**
- **`unattended-upgrades`** for security patches
- **`chrony`** with sane NTP pools
- **`zram-tools`** for memory compression on low-RAM builds
