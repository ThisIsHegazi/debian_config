#!/bin/bash

# =============================================================================
# GRUB Font Setup Script
# =============================================================================
# Converts a TrueType font into GRUB's native .pf2 format and configures GRUB
# to use it, giving the bootloader a larger, more readable font at startup.
#
# Font used: DejaVu Sans Mono (included in the fonts-dejavu-core package)
# Font size: 55pt — suitable for HiDPI/large displays; adjust -s to taste
#
# Usage: sudo bash grub-font.sh
# =============================================================================

# Require root — writing to /boot and /etc/default/grub both need elevated
# permissions.
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

FONT_SOURCE="/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
FONT_OUTPUT="/boot/grub/fonts/myFont.pf2"
GRUB_FILE="/etc/default/grub"

# Verify the source font file exists before attempting conversion.
# If the fonts-dejavu-core package is not installed this will fail early
# with a clear message rather than a cryptic grub-mkfont error.
if [ ! -f "$FONT_SOURCE" ]; then
    echo "Error: Source font not found at $FONT_SOURCE"
    echo "Install it with: sudo apt install fonts-dejavu-core"
    exit 2
fi

# Convert the TrueType font to GRUB's .pf2 bitmap format.
# -s sets the point size. The output goes into /boot/grub/fonts/ which is
# on the boot partition and therefore accessible to GRUB before the OS mounts.
echo "Converting font to pf2 format..."
grub-mkfont -s 55 -o "$FONT_OUTPUT" "$FONT_SOURCE"

# Abort if the font conversion failed — there is no point updating the GRUB
# config to point at a file that does not exist.
if [ $? -ne 0 ]; then
    echo "Error: grub-mkfont failed. Aborting."
    exit 3
fi
echo "Font created at $FONT_OUTPUT"

# Write the GRUB_FONT setting into /etc/default/grub.
# Three cases are handled to make this idempotent:
#   1. The variable is already set correctly — do nothing.
#   2. The variable exists but with a different value (or commented out) —
#      replace it in-place using sed so there is only ever one definition.
#   3. The variable is absent entirely — append it to the file.
echo "Updating $GRUB_FILE..."
if grep -q "^GRUB_FONT=$FONT_OUTPUT" "$GRUB_FILE"; then
    # Case 1: already configured correctly, nothing to do.
    echo "GRUB_FONT is already set correctly. Skipping."
elif grep -q "GRUB_FONT=" "$GRUB_FILE"; then
    # Case 2: a GRUB_FONT line exists (active or commented) — overwrite it.
    sed -i "s|.*GRUB_FONT=.*|GRUB_FONT=$FONT_OUTPUT|" "$GRUB_FILE"
    echo "Updated existing GRUB_FONT entry."
else
    # Case 3: no GRUB_FONT line exists — append one.
    echo "GRUB_FONT=$FONT_OUTPUT" >> "$GRUB_FILE"
    echo "Added GRUB_FONT entry."
fi

# Regenerate the GRUB configuration file from /etc/default/grub and the
# scripts in /etc/grub.d/. This is what actually applies the change —
# editing /etc/default/grub alone has no effect until update-grub is run.
echo "Updating GRUB configuration..."
update-grub

echo "Done. The new font will be active on the next boot."
