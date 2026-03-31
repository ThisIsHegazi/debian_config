#!/bin/bash

set -euo pipefail

# Require root because group membership changes are a privileged operation.
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

if [ -z "${1:-}" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

if ! id "$1" >/dev/null 2>&1; then
    echo "Error: user '$1' does not exist."
    exit 2
fi

if ! getent group wheel >/dev/null 2>&1; then
    echo "Error: the 'wheel' group does not exist on this system."
    exit 3
fi

if id -nG "$1" | tr ' ' '\n' | grep -qx wheel; then
    echo "User $1 is already a member of the wheel group."
else
    usermod -aG wheel "$1"
    echo "User $1 was successfully added to the wheel group."
fi

if grep -REqs '^[[:space:]]*%wheel[[:space:]]+ALL=\(ALL(:ALL)?\)[[:space:]]+ALL' /etc/sudoers /etc/sudoers.d 2>/dev/null; then
    echo "The wheel group appears to have sudo access configured."
else
    echo "Warning: wheel does not appear to be enabled in sudoers."
    echo "If needed, run 'sudo visudo' and uncomment the '%wheel ALL=(ALL:ALL) ALL' line."
fi

echo "Log out and back in for the new group membership to apply."
