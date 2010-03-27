#!/bin/sh

cd /Users/venator/Software/kb/backup/backup_mirror_mac
ICON_PROGRESS="progress.png"
ICON_DONE="done.png"
ICON_ERROR="error.png"

pingok=`ping -c 1 gateway 2>/dev/null`
if [ $? -eq 0 ]			# controlla che siamo al negozio
then
	growlnotify --image $ICON_PROGRESS -m "Backup mirroring in progress..."
	rsync -avL --delete gateway:/home/venator/backup_sispac/curweek/ /Users/venator/Tools/BackupSISPAC/
	retcode=$?
	if [ $retcode -eq 0 ]; then
		growlnotify --image $ICON_DONE -m "Backup mirroring completato."
	else
		growlnotify --image $ICON_ERROR -m "Errore durante backup mirroring ($retcode)!"
	fi
else
	growlnotify --image $ICON_ERROR -m "Backup mirroring non eseguito: non al negozio."
fi
