#!/bin/bash

set -euo pipefail

SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF_FILE="$SDDM_CONF_DIR/hidpi.conf"

# Require root because the script writes to /etc.
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

# Fail early if SDDM does not appear to be installed on this system.
if ! command -v sddm >/dev/null 2>&1 && [ ! -d /usr/share/sddm ]; then
    echo "Error: SDDM does not appear to be installed on this system."
    echo "Install SDDM first, then run this script again."
    exit 2
fi

# Guard against writing into an unexpected filesystem object.
if [ -e "$SDDM_CONF_DIR" ] && [ ! -d "$SDDM_CONF_DIR" ]; then
    echo "Error: $SDDM_CONF_DIR exists but is not a directory."
    exit 3
fi

mkdir -p "$SDDM_CONF_DIR"

NEW_CONF="$(mktemp)"
trap 'rm -f "$NEW_CONF"' EXIT

cat >"$NEW_CONF" <<'EOF'
[Wayland]
EnableHiDPI=true

[X11]
EnableHiDPI=true

[General]
GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192
EOF

# Skip rewriting the file when the desired config is already present.
if [ -f "$SDDM_CONF_FILE" ] && cmp -s "$NEW_CONF" "$SDDM_CONF_FILE"; then
    echo "SDDM HiDPI config already up to date at $SDDM_CONF_FILE"
    exit 0
fi

# Keep a backup before replacing an existing config file.
if [ -f "$SDDM_CONF_FILE" ]; then
    cp "$SDDM_CONF_FILE" "$SDDM_CONF_FILE.bak"
    echo "Backup created at $SDDM_CONF_FILE.bak"
fi

cat "$NEW_CONF" >"$SDDM_CONF_FILE"
echo "Wrote $SDDM_CONF_FILE"
echo "Restart SDDM or reboot to apply the new scaling."
