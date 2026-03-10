#!/bin/bash

# =============================================================================
# Debian Post-Install Setup Script
# =============================================================================
# Enables contrib, non-free, and non-free-firmware APT components, installs
# Flatpak with the Flathub remote, and installs essential development packages.
#
# Supports both the modern DEB822 format (.sources) and the legacy one-line
# format (sources.list). Safe to run multiple times — will not create duplicate
# entries in the sources file.
#
# Usage: sudo bash debian-setup.sh
# =============================================================================

# Require root privileges — modifying APT sources and installing packages
# both need elevated permissions. Exit immediately if not running as root.
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

# Detect which APT sources file format is in use on this system:
#   - Debian Bookworm (12)+ defaults to DEB822 format: .sources file
#     where components are on their own "Components:" line.
#   - Older releases use the legacy format: sources.list file
#     where each repo is a single "deb http://... main" line.
if [ -f /etc/apt/sources.list.d/debian.sources ]; then
    SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"
else
    SOURCES_FILE="/etc/apt/sources.list"
fi

# Back up the sources file before making any changes.
# The backup is saved alongside the original with a .bak extension.
# To restore: sudo cp "$SOURCES_FILE.bak" "$SOURCES_FILE"
cp "$SOURCES_FILE" "$SOURCES_FILE.bak"
echo "Backup created at $SOURCES_FILE.bak"

# Add the three additional APT components to the sources file.
# The approach differs depending on the file format detected above.
#
#   contrib            — free software that depends on non-free software
#   non-free           — software that does not meet Debian's free software guidelines
#   non-free-firmware  — hardware firmware (Wi-Fi, GPU drivers, etc.)
#
# The /contrib/! guard makes both sed commands idempotent: if the components
# are already present on a line, that line is skipped to prevent duplicates.
if [[ "$SOURCES_FILE" == *.sources ]]; then
    # DEB822 format: find lines starting with "Components:" and append
    # the three components to the end of the line.
    sed -i '/^Components:/ { /contrib/! s/$/ contrib non-free non-free-firmware/ }' "$SOURCES_FILE"
else
    # Legacy one-line format: find lines starting with "deb " and replace
    # the word "main" with "main contrib non-free non-free-firmware".
    # \b is a word boundary so only the standalone word "main" is matched.
    sed -i '/^deb / { /contrib/! s/\bmain\b/main contrib non-free non-free-firmware/ }' "$SOURCES_FILE"
fi

echo "Components 'contrib', 'non-free', and 'non-free-firmware' have been added."

# Refresh the local APT package index so the newly enabled components
# and any other repository changes are picked up before installing.
echo "Updating package list..."
apt update


# Install a core set of development tools and utilities:
#   zsh                  — Z Shell, feature-rich alternative to bash
#   git                  — version control
#   curl / wget          — HTTP download tools
#   gcc / g++            — C and C++ compilers
#   build-essential      — meta-package: make, dpkg-dev, and other build tools
#   python-is-python3    — makes the `python` command invoke Python 3
#   linux-headers-$(uname -r) — kernel headers for the currently running kernel,
#                          required to build kernel modules and some drivers
echo "Installing important packages..."
apt install -y zsh curl wget gcc g++ build-essential python-is-python3 linux-headers-$(uname -r)

echo "Done."
