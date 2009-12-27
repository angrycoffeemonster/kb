#!/bin/bash

orphans=`pacman -Qqdt`
if [ "$orphans" != "" ]; then
	sudo pacman -Rcsn $orphans
fi
