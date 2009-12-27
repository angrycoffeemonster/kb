#!/bin/bash

# Example crontab entry:
# 00 10 * * 6 /bin/su -l venator -c "/usr/bin/screen -d -m /home/venator/arch_stuff/backup_mirror"

ICON_PROGRESS="/usr/share/icons/gnome/22x22/status/software-update-available.png"
ICON_DONE="/usr/share/icons/gnome/22x22/status/info.png"

pingok=`ping -c 1 gateway 2>/dev/null`
if [ $? -eq 0 ]			# controlla che siamo al negozio
then
	notify-send -u low -t 10000 -i $ICON_PROGRESS "backup-mirror" "Backup mirroring in progress..."
	rsync -avL --delete gateway:/home/venator/backup_sispac/curweek /home/venator/BackupSISPAC
	notify-send -u normal -t 5000 -i $ICON_DONE "backup-mirror" "Backup mirroring completed."
fi

