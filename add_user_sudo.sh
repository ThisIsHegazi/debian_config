#!/usr/bin/bash
su
# add your user to sudo group
sudo usermod -a -G sudo $1

if [ $? -eq 0 ]; then
    echo "User $1 Was added successfully to sudo groups"
    echo "Please logout and in again to get all sudo powers"
    exit 0
else
    echo "Something Wrong Happened please try again"
    exit 1
fi

