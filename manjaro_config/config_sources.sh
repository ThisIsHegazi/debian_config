#!/bin/bash

set -euo pipefail

# =============================================================================
# Manjaro Post-Install Setup Script
# =============================================================================
# Enables the multilib repository in pacman, installs Flatpak with Flathub,
# and installs essential development packages.
# =============================================================================

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

PACMAN_CONF="/etc/pacman.conf"
PACMAN_CONF_BACKUP="$PACMAN_CONF.bak"

if [ ! -f "$PACMAN_CONF" ]; then
    echo "Error: $PACMAN_CONF was not found."
    exit 2
fi

cp "$PACMAN_CONF" "$PACMAN_CONF_BACKUP"
echo "Backup created at $PACMAN_CONF_BACKUP"

if grep -Eq '^[[:space:]]*\[multilib\][[:space:]]*$' "$PACMAN_CONF"; then
    echo "multilib is already enabled."
elif grep -Eq '^[[:space:]]*#\[multilib\][[:space:]]*$' "$PACMAN_CONF"; then
    sed -i '/^#\[multilib\]$/,/^#Include = \/etc\/pacman.d\/mirrorlist$/ s/^#//' "$PACMAN_CONF"
    echo "Enabled the multilib repository."
else
    cat >>"$PACMAN_CONF" <<'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
    echo "Added the multilib repository."
fi

detect_headers_package() {
    local kernel_release kernel_version major minor candidate

    kernel_release="$(uname -r)"
    kernel_version="${kernel_release%%-*}"
    major="${kernel_version%%.*}"
    minor="${kernel_version#*.}"
    minor="${minor%%.*}"
    candidate="linux${major}${minor}-headers"

    if pacman -Ssq "^${candidate}$" | grep -qx "$candidate"; then
        printf '%s\n' "$candidate"
        return 0
    fi

    if pacman -Ssq '^linux-headers$' | grep -qx 'linux-headers'; then
        printf '%s\n' "linux-headers"
        return 0
    fi

    return 1
}

HEADERS_PACKAGE=""
if HEADERS_PACKAGE="$(detect_headers_package)"; then
    echo "Detected kernel headers package: $HEADERS_PACKAGE"
else
    echo "Warning: could not determine a matching kernel headers package for $(uname -r)."
    echo "Continuing without installing kernel headers."
fi

PACKAGES=(
    zsh
    git
    curl
    wget
    gcc
    base-devel
    python
    flatpak
)

if [ -n "$HEADERS_PACKAGE" ]; then
    PACKAGES+=("$HEADERS_PACKAGE")
fi

echo "Refreshing package databases and upgrading installed packages..."
pacman -Syu --noconfirm --needed "${PACKAGES[@]}"

echo "Configuring Flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Done."
