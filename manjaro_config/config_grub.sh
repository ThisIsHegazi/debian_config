#!/bin/bash

set -euo pipefail

# =============================================================================
# GRUB Font Setup Script for Manjaro/Arch
# =============================================================================
# Converts a TrueType font into GRUB's native .pf2 format and configures GRUB
# to use it, giving the bootloader a larger, more readable font at startup.
# =============================================================================

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

GRUB_FILE="/etc/default/grub"
FONT_OUTPUT="/boot/grub/fonts/myFont.pf2"
GRUB_CFG="/boot/grub/grub.cfg"

find_font_source() {
    local candidate

    for candidate in \
        /usr/share/fonts/TTF/DejaVuSansMono.ttf \
        /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf
    do
        if [ -f "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    return 1
}

if ! command -v grub-mkfont >/dev/null 2>&1; then
    echo "Error: grub-mkfont is not available."
    echo "Install GRUB first with: sudo pacman -S grub"
    exit 2
fi

FONT_SOURCE="$(find_font_source || true)"
if [ -z "$FONT_SOURCE" ]; then
    echo "Error: DejaVu Sans Mono was not found."
    echo "Install it with: sudo pacman -S ttf-dejavu"
    exit 3
fi

mkdir -p "$(dirname "$FONT_OUTPUT")"

echo "Converting font to pf2 format..."
grub-mkfont -s 55 -o "$FONT_OUTPUT" "$FONT_SOURCE"
echo "Font created at $FONT_OUTPUT"

echo "Updating $GRUB_FILE..."
if grep -q "^GRUB_FONT=$FONT_OUTPUT" "$GRUB_FILE"; then
    echo "GRUB_FONT is already set correctly. Skipping."
elif grep -Eq '^[[:space:]]*#?[[:space:]]*GRUB_FONT=' "$GRUB_FILE"; then
    sed -i "s|^[[:space:]]*#\?[[:space:]]*GRUB_FONT=.*|GRUB_FONT=$FONT_OUTPUT|" "$GRUB_FILE"
    echo "Updated existing GRUB_FONT entry."
else
    printf '\nGRUB_FONT=%s\n' "$FONT_OUTPUT" >> "$GRUB_FILE"
    echo "Added GRUB_FONT entry."
fi

echo "Regenerating GRUB configuration..."
grub-mkconfig -o "$GRUB_CFG"

echo "Done. The new font will be active on the next boot."
