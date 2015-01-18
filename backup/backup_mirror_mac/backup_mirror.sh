#!/bin/sh

cd /Users/venator/Software/kb/backup/backup_mirror_mac
ICON_PROGRESS="progress.png"
ICON_DONE="done.png"
ICON_ERROR="error.png"

pingok=`ping -c 1 gateway 2>/dev/null`
if [ $? -eq 0 ]			# controlla che siamo al negozio
then
	growlnotify --image $ICON_PROGRESS -m "Backup mirroring in progress..."
	ERR=$(rsync -aPh --delete venator@ubfsrl.ath.cx:backup_sispac/curweek/ /Volumes/Mac/Home/Tools/BackupSISPAC/ 2>&1 >/dev/null)
	retcode=$?
	if [ $retcode -eq 0 ]; then
		growlnotify --image $ICON_DONE -m "Backup mirroring completato."
	else
		MSG=$(echo -e "Errore durante backup mirroring\n$ERR")
		growlnotify --image $ICON_ERROR -m "$MSG"
	fi
else
	growlnotify --image $ICON_ERROR -m "Backup mirroring non eseguito: non al negozio."
fi
