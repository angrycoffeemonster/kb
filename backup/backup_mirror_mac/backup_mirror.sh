#!/bin/sh

ICON_PROGRESS="/Users/venator/Tools/progress.png"
ICON_DONE="/Users/venator/Tools/done.png"

pingok=`ping -c 1 gateway 2>/dev/null`
if [ $? -eq 0 ]			# controlla che siamo al negozio
then
	growlnotify --image $ICON_PROGRESS -m "Backup mirroring in corso..."
	rsync -avL --delete gateway:/home/venator/backup_sispac/curweek /Users/venator/BackupSISPAC
	growlnotify --image $ICON_DONE -m "Backup mirroring completato."
else
	growlnotify --image $ICON_PROGRESS -m "Backup mirroring non eseguito: non al negozio."
fi

