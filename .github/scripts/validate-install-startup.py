#!/usr/bin/env python3
"""Static install/startup invariants for shaughvOS.

This catches the small wiring drifts that have historically caused broken
installer ISOs, login loops, missing desktop commands, or mismatched docs.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


CRITICAL_PACKAGES = {
    "xfce4",
    "xfce4-session",
    "xfwm4",
    "xfdesktop4",
    "xfce4-panel",
    "thunar",
    "xfce4-terminal",
    "lightdm",
    "lightdm-gtk-greeter",
    "dbus-user-session",
    "dbus-x11",
    "x11-common",
    "xserver-xorg",
    "xserver-xorg-core",
    "xinit",
    "x11-xserver-utils",
    "xserver-xorg-video-fbdev",
    "xserver-xorg-video-vesa",
    "xserver-xorg-input-libinput",
    "polkitd",
    "libpam-systemd",
    "plymouth",
    "plymouth-themes",
    "papirus-icon-theme",
    "librsvg2-common",
    "network-manager",
    "network-manager-gnome",
    "xfce4-power-manager",
    "xfce4-pulseaudio-plugin",
    "pulseaudio",
    "pavucontrol",
}


FORBIDDEN_PENTEST_PATHS = [
    ".build/images",
    "rootfs",
    "shaughvos",
    "README.md",
    "DEPLOYMENT.md",
]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def shell_words(raw: str) -> set[str]:
    words: set[str] = set()
    for token in re.split(r"\s+", raw):
        token = token.strip().strip("'\"")
        if not token or token.startswith("-"):
            continue
        if token in {"&&", "||", "true"} or token.startswith("2>"):
            continue
        words.add(token)
    return words


def apt_install_packages(text: str) -> set[str]:
    joined = re.sub(r"\\\r?\n", " ", text)
    packages: set[str] = set()
    for match in re.finditer(r"apt-get\s+install\s+(?:-[\w-]+\s+)*([^'\"\n;&]+)", joined):
        packages |= shell_words(match.group(1))
    return packages


def apt_mark_packages(text: str) -> set[str]:
    joined = re.sub(r"\\\r?\n", " ", text)
    packages: set[str] = set()
    for match in re.finditer(r"apt-mark\s+manual\s+([^'\"\n]+)", joined):
        packages |= shell_words(match.group(1))
    return packages


def imager_module_downloads(imager: str) -> set[str]:
    for match in re.finditer(r"^\s*for f in ([^;\r\n]+); do\r?$", imager, re.MULTILINE):
        modules = set(match.group(1).split())
        if modules and all(module.endswith(".conf") for module in modules):
            return modules
    return set()


def calamares_sequence_modules(settings: str) -> set[str]:
    modules: set[str] = set()
    for line in settings.splitlines():
        match = re.match(r"\s*-\s+([a-z0-9_-]+)\s*$", line)
        if match:
            modules.add(match.group(1))
    return modules


def direct_shaughvos_aliases(legacy_bash: str) -> set[str]:
    aliases: set[str] = set()
    for match in re.finditer(r"alias\s+(shaughvos-[A-Za-z0-9_-]+)='/boot/shaughvos/\1'", legacy_bash):
        aliases.add(match.group(1))
    return aliases


def symlinked_commands(imager: str) -> set[str]:
    match = re.search(r"for cmd in ([^;]+); do\s*\n\s*chroot \"\$live_root\" ln -sf", imager)
    if not match:
        return set()
    return set(match.group(1).split())


def check_calamares(errors: list[str], imager: str) -> None:
    modules_dir = ROOT / "assets/calamares/modules"
    module_files = {path.name for path in modules_dir.glob("*.conf")}
    downloaded = imager_module_downloads(imager)
    settings_modules = calamares_sequence_modules(read("assets/calamares/settings.conf"))
    configured_modules = {path.stem for path in modules_dir.glob("*.conf")}

    if not downloaded:
        fail(errors, "Could not find Calamares module download loop in shaughvos-imager")
        return

    missing_downloads = module_files - downloaded
    if missing_downloads:
        fail(errors, f"Calamares module configs not downloaded by imager: {sorted(missing_downloads)}")

    missing_files = downloaded - module_files
    if missing_files:
        fail(errors, f"Imager downloads missing Calamares module configs: {sorted(missing_files)}")

    unused_configs = configured_modules - settings_modules
    if unused_configs:
        fail(errors, f"Calamares module configs are not referenced in settings.conf: {sorted(unused_configs)}")


def check_packages(errors: list[str], imager: str) -> None:
    shellprocess = read("assets/calamares/modules/shellprocess.conf")
    imager_installed = apt_install_packages(imager)
    imager_marked = apt_mark_packages(imager)
    shellprocess_marked = apt_mark_packages(shellprocess)

    missing_install = CRITICAL_PACKAGES - imager_installed
    if missing_install:
        fail(errors, f"Critical packages not installed by imager: {sorted(missing_install)}")

    missing_imager_mark = CRITICAL_PACKAGES - imager_marked
    if missing_imager_mark:
        fail(errors, f"Critical packages not apt-mark manual in imager: {sorted(missing_imager_mark)}")

    missing_shellprocess_mark = CRITICAL_PACKAGES - shellprocess_marked
    if missing_shellprocess_mark:
        fail(errors, f"Critical packages not apt-mark manual in Calamares shellprocess: {sorted(missing_shellprocess_mark)}")


def check_autologin_ownership(errors: list[str]) -> None:
    desktop = read("rootfs/usr/local/bin/desktop")
    autologin = read("rootfs/usr/local/bin/autologin")

    forbidden_desktop_snippets = [
        "/etc/systemd/system/getty@tty1.service.d/shaughvos-autologin.conf",
        "/etc/lightdm/lightdm.conf.d/90-shaughvos-autologin.conf",
    ]
    for snippet in forbidden_desktop_snippets:
        if f"rm -f {snippet}" in desktop or f'rm -f "{snippet}"' in desktop:
            fail(errors, f"desktop must not remove autologin-owned file: {snippet}")

    for snippet in forbidden_desktop_snippets:
        if snippet not in autologin:
            fail(errors, f"autologin script does not manage expected file: {snippet}")


def check_cli_symlinks(errors: list[str], imager: str) -> None:
    aliases = direct_shaughvos_aliases(read("rootfs/etc/bashrc.d/shaughvos-legacy.bash"))
    symlinks = symlinked_commands(imager)
    if not symlinks:
        fail(errors, "Could not find shaughvOS CLI symlink loop in shaughvos-imager")
        return

    missing = aliases - symlinks
    if missing:
        fail(errors, f"Direct shaughvOS aliases missing /usr/local/bin symlinks: {sorted(missing)}")

    nonexistent = {cmd for cmd in symlinks if not (ROOT / "shaughvos" / cmd).exists()}
    if nonexistent:
        fail(errors, f"Imager symlinks commands that do not exist under shaughvos/: {sorted(nonexistent)}")


def check_removed_features(errors: list[str]) -> None:
    for rel in FORBIDDEN_PENTEST_PATHS:
        path = ROOT / rel
        paths = [path] if path.is_file() else [p for p in path.rglob("*") if p.is_file()]
        for file_path in paths:
            try:
                text = file_path.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            if "pentest-tools" in text:
                fail(errors, f"Removed pentest-tools reference found in runtime/doc path: {file_path.relative_to(ROOT)}")


def check_required_steps(errors: list[str], imager: str) -> None:
    required_snippets = [
        "G_EXEC chroot \"$live_root\" update-initramfs -u",
        "plymouth-set-default-theme shaughvos",
        "G_EXEC chroot \"$live_root\" systemctl enable lightdm",
        "G_EXEC chroot \"$live_root\" systemctl enable shaughvos-live-check",
    ]
    for snippet in required_snippets:
        if snippet not in imager:
            fail(errors, f"Required imager step missing or not hard-failing: {snippet}")

    forbidden_required_best_effort = [
        'chroot "$live_root" update-initramfs -u 2>/dev/null || true',
        'chroot "$live_root" systemctl enable lightdm 2>/dev/null || true',
        'chroot "$live_root" systemctl enable shaughvos-live-check 2>/dev/null || true',
    ]
    for snippet in forbidden_required_best_effort:
        if snippet in imager:
            fail(errors, f"Required imager step is still best-effort: {snippet}")


def main() -> int:
    errors: list[str] = []
    imager = read(".build/images/shaughvos-imager")

    check_calamares(errors, imager)
    check_packages(errors, imager)
    check_autologin_ownership(errors)
    check_cli_symlinks(errors, imager)
    check_removed_features(errors)
    check_required_steps(errors, imager)

    if errors:
        print("Install/startup invariant check failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print("Install/startup invariant check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
