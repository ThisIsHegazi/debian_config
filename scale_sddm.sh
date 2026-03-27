#!/bin/bash

# check if root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Use sudo or switch to the root user."
    exit 1
fi
# create /etc/sddm.conf.d dir
mkdir -p /etc/sddm.conf.d
# create hidpi.conf file
cat << EOF > /etc/sddm.conf.d/hidpi.conf
[Wayland]
EnableHiDPI=true

[X11]
EnableHiDPI=true

[General]
GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192
EOF

