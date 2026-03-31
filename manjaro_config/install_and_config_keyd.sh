#!/bin/bash

set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

KEYD_CONF_DIR="/etc/keyd"
KEYD_CONF_FILE="$KEYD_CONF_DIR/default.conf"

echo "Installing keyd..."
pacman -S --noconfirm --needed keyd

mkdir -p "$KEYD_CONF_DIR"

NEW_CONF="$(mktemp)"
trap 'rm -f "$NEW_CONF"' EXIT

cat >"$NEW_CONF" <<'EOF'
[ids]

*

[main]

# Remap Caps Lock to Backspace
capslock = backspace

# Remap Compose (Menu) to Caps Lock
compose = capslock
EOF

if [ -f "$KEYD_CONF_FILE" ] && cmp -s "$NEW_CONF" "$KEYD_CONF_FILE"; then
    echo "Keyd config already up to date at $KEYD_CONF_FILE"
else
    if [ -f "$KEYD_CONF_FILE" ]; then
        cp "$KEYD_CONF_FILE" "$KEYD_CONF_FILE.bak"
        echo "Backup created at $KEYD_CONF_FILE.bak"
    fi

    cp "$NEW_CONF" "$KEYD_CONF_FILE"
    echo "Wrote $KEYD_CONF_FILE"
fi

systemctl enable keyd
systemctl restart keyd
echo "Keyd enabled and restarted."
