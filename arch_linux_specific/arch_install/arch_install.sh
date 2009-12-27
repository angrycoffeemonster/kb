#!/bin/bash

# Xorg and base system
PKGS="$PKGS xorg bash-completion openssh acpid sudo"

# Build essentials
PKGS="$PKGS base-devel subversion abs"

# Hardware-related packages
PKGS="$PKGS nvidia iwlwifi-4965-ucode synaptics ntfs-3g cups cups-pdf gutenprint ghostscript sane hddtemp cpufrequtils"

# Bluetooth
#PKGS="$PKGS bluez-gnome bluez-utils gnome-bluetooth"

# Gnome desktop base
PKGS="$PKGS gnome firefox gedit gnome-power-manager gnome-system-monitor gnome-terminal gnome-utils gnome-volume-manager ttf-dejavu sshfs"

# Gnome desktop goodies
PKGS="$PKGS eog evince file-roller gconf-editor gdm zip unzip unrar"

# Multimedia
PKGS="$PKGS totem rhythmbox flashplugin gstreamer0.10-plugins alsa-utils"

# Themes and eye candy
PKGS="$PKGS gdm-themes tango-icon-theme-extras xcursor-vanilla-dmz gnome-screensaver xscreensaver"

# Java
PKGS="$PKGS jdk"

# Network and servers
PKGS="$PKGS apache php libxml2 ntp"
PKGS="$PKGS pidgin netcfg"

# TeXLive
#PKGS="$PKGS texlive-core"
#
# Add /opt/texlive/bin to $PATH, then install:
#     texlive-bibtexextra texlive-fontsextra texlive-latexextra
#
# In your documents, use the following options to get non-raster fonts and working accents:
#    \usepackage[T1]{fontenc}
#    \usepackage[utf8]{inputenc}
# REMEMBER TO SAVE THEM AS UTF8 !!!
#

# LCD font hinting
# from venator:		cairo-lcd fontconfig-lcd
# from community:	libxft-lcd

#pacman -Rcsn reiserfsprogs xfsprogs xfsdump jfsutils lilo
pacman -Syu
pacman -S $PKGS

