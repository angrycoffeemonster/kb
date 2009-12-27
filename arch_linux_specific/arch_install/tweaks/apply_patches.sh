#!/bin/bash

# Avoid bitmap fonts in firefox
OLDDIR=$PWD
cd /etc/fonts/conf.d/
ln -s ../conf.avail/29-replace-bitmap-fonts.conf
ln -s ../conf.avail/70-no-bitmaps.conf
cd $OLDDIR
patch -p0 < 29-replace-bitmap-fonts.conf.patch

# Prevent gnome-power-manager to dim display brightness
gconftool-2 -t bool -s /apps/gnome-power-manager/backlight/enable false

# Configure the keyring to be automatically unlocked upon login
#echo "auth    optional        pam_gnome_keyring.so" >> /etc/pam.d/gdm
#echo "session optional        pam_gnome_keyring.so  auto_start" >> /etc/pam.d/gdm
#echo "auth    optional        pam_gnome_keyring.so" >> /etc/pam.d/gnome-screensaver
#echo "password        optional        pam_gnome_keyring.so" >> /etc/pam.d/passwd

# Modify en_US locale to use A4 paper (for compatibility with Samsung ML-3051ND)
patch -p0 < en_US-A4paper.patch
locale-gen

# EPSON Stylus DX-4250 scanner installation
patch -p0 < sane-epson-dx-4250.patch

# Set makepkg compilation option -j3 for dual core cpus
patch -p0 < makepkg.conf.patch

# Apply venator patch to netcfg2 and install bash completion support
patch -p0 < netcfg-2.1.0_RC1-venator.patch
cp netcfg_bash-completion /etc/bash_completion.d/netcfg2

# To store current sound mixers level
# alsactl store

# Map page up and pagedown to search the history
patch -p0 < pagup_pagdown_search_history.patch
