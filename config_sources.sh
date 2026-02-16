#!/bin/bash
# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

SOURCES_FILE="/etc/apt/sources.list"

# Create a backup of the original sources.list file
cp "$SOURCES_FILE" "$SOURCES_FILE.bak"
echo "Backup created at $SOURCES_FILE.bak"

# Use sed to add 'contrib non-free non-free-firmware' to the 'main' lines
# The regex looks for lines starting with 'deb', captures everything after, and appends the new components
sed -i 's/\(.*main\)$/\1 contrib non-free non-free-firmware/' "$SOURCES_FILE"
sed -i 's/\(.*main \)$/\1contrib non-free non-free-firmware/' "$SOURCES_FILE" # Handle cases where 'main' is followed by a space
echo "Components 'contrib', 'non-free', and 'non-free-firmware' have been added."

echo "Updating package list..."
apt update

echo "Modernizing sources..."
apt modernize-sources -y


echo "Installing flatpak"
# install flatpak
apt install flatpak
# install software-plugin
apt install gnome-software-plugin-flatpak
# add flatpak repo
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo


echo "Installing Important Packages..."
apt install zsh git curl wget gcc g++ build-essential python-is-python3 linux-headers-$(uname -r) -y
echo "Done."
