#!/bin/bash

if [ $# -eq 0 ]; then
	zenity --warning --title="Warning" --text="Please select at least one file!"
	exit 1
fi

FILES=`echo $NAUTILUS_SCRIPT_SELECTED_URIS | sed "s| |,|g"`
thunderbird -compose "attachment='$FILES'"
