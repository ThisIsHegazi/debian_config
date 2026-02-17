#!/bin/bash

# Require root — adding a user to the sudo group is a privileged operation.
# Using sudo inside the script would create a circular dependency (you would
# need sudo access to grant sudo access), so we enforce root directly instead.
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi

# Ensure a username was passed as the first argument before doing anything.
# Without this check, usermod would receive an empty string and produce a
# cryptic error message.
if [ -z "$1" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# Add the specified user to the sudo group.
usermod -aG sudo "$1"

if [ $? -eq 0 ]; then
    echo "User $1 was successfully added to the sudo group."
    echo "Please reboot for the changes to take full effect."
    exit 0
else
    echo "Something went wrong. Please check the username and try again."
    exit 1
fi
