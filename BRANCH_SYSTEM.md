## shaughvOS Branch System

### `master` — Stable Release
The stable branch. OTA updates pull from here. Only merged from `dev` or `beta` after testing.

### `beta` — Pre-Release Testing
Pre-release branch for public testing. May be unstable. Once testing passes and issues are resolved, beta is merged to master.

### `dev` — Active Development
The active development branch. All pull requests target `dev`. Potentially unstable and unsupported.

---

## Switching Branches

#### On a fresh image:
1. Flash the shaughvOS image to SD card or USB.
2. Open `/boot/shaughvos.txt` on the boot partition.
3. Change `DEV_GITBRANCH=master` to `DEV_GITBRANCH=beta` (or `dev`).
4. Save, eject, and power on.

#### On an existing installation:
1. Recommended: Backup your system with `shaughvos-backup` (or `shaughvos-backup 1` for a quick backup).
2. Run the following command to switch branches:
    ```sh
    G_DEV_BRANCH beta
    ```
3. Test and report any issues: https://github.com/RealEmmettS/shaughvOS/issues
4. To restore, run `shaughvos-backup` to restore from your backup.
