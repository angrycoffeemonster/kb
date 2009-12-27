#!/bin/bash

PID=`pidof firefox`
if [ ! -z "$PID" ]; then
	echo "!! Please close all Firefox instances first!"
else
	du -sh ~/.mozilla/firefox/
	find ~/.mozilla/firefox/ -name "*.sqlite" -exec sqlite3 '{}' "VACUUM;" \;
	du -sh ~/.mozilla/firefox/
fi
