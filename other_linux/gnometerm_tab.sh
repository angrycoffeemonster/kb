#!/bin/sh

xdotool_found=`which xdotool 2>&1 1>/dev/null`
if [ "$?" -eq 0 ]; then
	pgrep -u "$USER" gnome-terminal | grep -qvx "$$"
	if [ "$?" -eq 0 ]; then
		WID=`xdotool search --class "gnome-terminal" | head -1`
		xdotool windowactivate $WID
		xdotool key ctrl+shift+t
	else
		/usr/bin/gnome-terminal &
	fi
else
	echo ":: xdotool is not installed!"
	echo ":: Install it with:"
	echo "::   sudo pacman -S xdotool"
fi
