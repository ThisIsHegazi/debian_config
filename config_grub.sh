#!/bin/bash

if [$(id -u) -ne 0];then
    echo "This script requires sudo"
    exit 1
fi

grub-mkfont -s 55 -o /boot/grub/fonts/myFont.pf2 /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf
# edit grub file and add GRUB_FONT=/boot/grub/fonts/myFont.pf2
GRUB_FILE="/etc/default/grub"
cat >> "$GRUB_FILE" << EOF
GRUB_FONT=/boot/grub/fonts/myFont.pf2
EOF
# update grub
update-grub