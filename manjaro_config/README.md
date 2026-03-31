# manjaro_config

A collection of personal Manjaro and Arch-compatible configuration and setup bash scripts for automating post-install system configuration and maintenance tasks.

## Overview

This directory mirrors the Debian workflow from the parent repo, but the scripts are rewritten for Manjaro and Arch-style systems. They use `pacman`, Arch package names, Manjaro's kernel header naming, the `wheel` admin group, and Arch-compatible GRUB refresh commands.

## Scripts

### `add_user_sudo.sh`
**Purpose**: Add a user to the `wheel` group for administrative privileges

**What it does**:
- Verifies the script is run as root
- Takes a username as an argument
- Adds the specified user to the `wheel` group using `usermod -aG wheel`
- Warns if `wheel` does not appear to be enabled in sudoers
- Reminds the user to log out and back in for the new group membership to apply

**Usage**: `sudo bash add_user_sudo.sh <username>`

---

### `config_grub.sh`
**Purpose**: Configure GRUB with a larger custom font for HiDPI displays

**What it does**:
- Converts the DejaVu Sans Mono TrueType font to GRUB's native `.pf2` format
- Writes `GRUB_FONT=/boot/grub/fonts/myFont.pf2` into `/etc/default/grub`
- Regenerates `/boot/grub/grub.cfg` with `grub-mkconfig`
- Uses Arch/Manjaro font paths and package guidance
- Remains safe to re-run without duplicating settings

**Usage**: `sudo bash config_grub.sh`

**Requirements**: `grub` and `ttf-dejavu`

---

### `config_sources.sh`
**Purpose**: Configure `pacman` and install essential packages

**What it does**:
- Enables the `multilib` repository in `/etc/pacman.conf`
- Creates a backup of `/etc/pacman.conf` before modifications
- Refreshes package databases and upgrades installed packages
- Installs Flatpak and adds the Flathub remote
- Installs essential development packages:
  - `zsh`
  - `git`
  - `curl` / `wget`
  - `gcc`
  - `base-devel`
  - `python`
  - The headers package that matches the currently running Manjaro kernel when possible

**Usage**: `sudo bash config_sources.sh`

**Safe to run multiple times**: Includes guards to prevent duplicate repo entries and duplicate Flatpak remotes

---

### `install_and_config_keyd.sh`
**Purpose**: Install and configure `keyd` for key remapping

**What it does**:
- Installs `keyd` through `pacman`
- Writes `/etc/keyd/default.conf` with a simple remap
- Enables and restarts the `keyd` service
- Backs up the existing config before replacing it

**Usage**: `sudo bash install_and_config_keyd.sh`

**Safe to run multiple times**: Won't rewrite the config if it is already correct

---

### `ohmyzsh_setup.sh`
**Purpose**: Install and configure Oh-My-Zsh with useful plugins and Manjaro-friendly aliases

**What it does**:
- Installs Oh-My-Zsh in unattended mode
- Installs `zsh-syntax-highlighting` and `zsh-autosuggestions`
- Registers those plugins plus `sudo` in `~/.zshrc`
- Adds convenience aliases for power management and `pacman` workflows:
  - `poweroff` / `reboot` / `hibernate`
  - `update` / `upgrade` / `paci`
- Uses the current user's home directory instead of a hard-coded path

**Usage**: `bash ohmyzsh_setup.sh`

**Safe to run multiple times**: All operations are guarded against duplicates

---

### `scale_sddm.sh`
**Purpose**: Enable HiDPI scaling for the SDDM login screen

**What it does**:
- Verifies the script is run as root before writing to `/etc`
- Checks that SDDM appears to be installed before changing its config
- Ensures `/etc/sddm.conf.d` is a real directory
- Writes `/etc/sddm.conf.d/hidpi.conf` with 2x scaling values
- Backs up an existing `hidpi.conf` before replacing it
- Skips rewriting the file when the desired config is already present

**Usage**: `sudo bash scale_sddm.sh`

**Safe to run multiple times**: Won't rewrite the file if it is already correct

---

## Quick Setup Workflow

A typical Manjaro post-install setup:

```bash
# 1. Configure pacman and install essential packages
sudo bash config_sources.sh

# 2. Install and configure key remapping
sudo bash install_and_config_keyd.sh

# 3. Configure GRUB with better fonts
sudo bash config_grub.sh

# 4. Scale the SDDM login screen for HiDPI displays
sudo bash scale_sddm.sh

# 5. Set up Oh-My-Zsh for your user
bash ohmyzsh_setup.sh

# 6. Add another user to the wheel group if needed
sudo bash add_user_sudo.sh <username>
```

## Language

- **Shell (100%)**: All scripts are written in bash

## Notes

- These are personal configuration scripts tailored to Manjaro and Arch-style systems
- Each script includes validation and idempotent guards where practical
- Some scripts require root, while `ohmyzsh_setup.sh` should be run as a regular user
- Feel free to adapt the package list or aliases to fit your own workflow
