# debian_config

A collection of personal Debian configuration and setup bash scripts for automating system configuration and maintenance tasks.

## Overview

This repository contains shell scripts designed to automate and streamline Debian-based Linux system configuration. These scripts help quickly set up and configure a Debian environment according to personal preferences and requirements.

## Scripts

### `add_user_sudo.sh`
**Purpose**: Add a user to the sudo group for elevated privileges

**What it does**:
- Verifies the script is run as root (required for user management)
- Takes a username as an argument
- Adds the specified user to the `sudo` group using `usermod -aG sudo`
- Requires system reboot for changes to take full effect

**Usage**: `sudo bash add_user_sudo.sh <username>`

---

### `config_grub.sh`
**Purpose**: Configure GRUB bootloader with custom fonts for HiDPI displays

**What it does**:
- Converts the DejaVu Sans Mono TrueType font to GRUB's native .pf2 format (55pt size)
- Configures `/etc/default/grub` to use the converted font
- Runs `update-grub` to apply the changes
- Ensures idempotent operation — safe to run multiple times
- Requires `fonts-dejavu-core` package to be installed

**Usage**: `sudo bash config_grub.sh`

**Requirements**: `fonts-dejavu-core` package

---

### `config_sources.sh`
**Purpose**: Configure Debian APT repositories and install essential packages

**What it does**:
- Enables `contrib`, `non-free`, and `non-free-firmware` APT components
- Automatically detects and handles both modern DEB822 (.sources) and legacy (sources.list) formats
- Creates a backup of the original sources file before modifications
- Installs Flatpak with Flathub remote for universal app packaging
- Installs essential development packages:
  - `zsh` (feature-rich shell alternative)
  - `git` (version control)
  - `curl` / `wget` (HTTP download tools)
  - `gcc` / `g++` (C/C++ compilers)
  - `build-essential` (compilation tools)
  - `python-is-python3` (Python 3 alias)
  - `linux-headers` (kernel headers for the current kernel)

**Usage**: `sudo bash config_sources.sh`

**Safe to run multiple times**: Includes guards to prevent duplicate entries

---

### `ohmyzsh_setup.sh`
**Purpose**: Install and configure Oh-My-Zsh with useful plugins and aliases

**What it does**:
- Installs Oh-My-Zsh framework in unattended mode
- Installs two popular Zsh plugins:
  - `zsh-syntax-highlighting` — syntax highlighting for commands
  - `zsh-autosuggestions` — command auto-completion suggestions
- Registers both plugins in `~/.zshrc`
- Adds convenience aliases for common tasks:
  - `poweroff` / `reboot` / `hibernate` — power management shortcuts
  - `update` / `upgrade` / `apti` — apt package management shortcuts
- Guards against duplicates on re-runs

**Usage**: `bash ohmyzsh_setup.sh` (run as regular user, NOT root)

**Safe to run multiple times**: All operations are idempotent

---

## Quick Setup Workflow

A typical Debian post-install setup might look like:

```bash
# 1. Configure APT repositories and install essential packages
sudo bash config_sources.sh

# 2. Configure GRUB with better fonts
sudo bash config_grub.sh

# 3. Set up Oh-My-Zsh for your user
bash ohmyzsh_setup.sh

# 4. Add another user to sudo group (if needed)
sudo bash add_user_sudo.sh <username>
```

## Language

- **Shell (100%)**: All scripts are written in bash

## Notes

- These are personal configuration scripts tailored to specific needs
- Each script includes comprehensive error checking and validation
- All scripts are designed to be idempotent (safe to run multiple times)
- Feel free to adapt and modify them for your own use
- Some scripts require root (`sudo`), while others should be run as a regular user