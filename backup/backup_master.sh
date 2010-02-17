#!/bin/bash

# Usage:
# backup_master [--no-shutdown]

# Ensure this script is not executed by root
if [ "$(id -u)" == 0 ]
then
	echo ":: Error: backup_master must not be run as root!"
	echo ":: If you are using cron, use the following command:"
	echo "   su -l YOUR_USER -c \"/path/to/backup_master\""
	exit 1
fi

##### NOTIFICATION OPTIONS #####
#
# putmail.py is used to send notification mails
# Configure ~/.putmail/putmailrc with SMTP server options
#
INSTALLATION_NAME='UtensBianchi'
FROM_ADDR="$INSTALLATION_NAME Automatic backup <venatorstorage@gmail.com>"
TO_ADDR='Alessio Bianchi <venator85@gmail.com>'
################################

##### BACKUP OPTIONS #####
BACKUP_TAG='SISPAC-9.70.10'

REMOTE_USERNAME='Administrator'
REMOTE_HOST='server'
TOBACKUP='/cygdrive/h/Sispac'
REMOTE_BACKUP_DEST='/cygdrive/h/BackupSISPAC'
BACKUP_SLAVE='/cygdrive/h/BackupSISPAC/backup_slave'

LOCAL_BACKUP_DEST='/home/venator/backup_sispac'
CURRENT_WEEK_LINK='curweek'
##########################

##### MISC OPTIONS #####
long_date=`date +"%a %d/%m/%Y %H.%M.%S"`	# Thu 28/08/2008 14.49.31
short_date=`date +%d/%m/%Y`			# 27/08/2008
filename_date=`date +%Y_%m_%d-%H.%M.%S`		# 2008_08_27-22.32.47
start_end_date_format='%d/%m/%Y %H.%M.%S'
filename="Backup.${BACKUP_TAG}.${filename_date}.tar.gz"
dest_week_dir="/$(date +%Y.%U)"			# 2008.40 (anno.numerosettimana)
########################

SSH="ssh -o PasswordAuthentication=no"
SCP="scp -o PasswordAuthentication=no"

backup_start=`date +"${start_end_date_format}"`
slave_output=`$SSH ${REMOTE_USERNAME}@${REMOTE_HOST} "sh -c \"${BACKUP_SLAVE} ${TOBACKUP} ${REMOTE_BACKUP_DEST}/${filename}\"" 2>&1`
backup_result=$?
backup_end=`date +"${start_end_date_format}"`
mkdir -p ${LOCAL_BACKUP_DEST}${dest_week_dir}/
rm -f ${LOCAL_BACKUP_DEST}/${CURRENT_WEEK_LINK}
ln -s ${LOCAL_BACKUP_DEST}${dest_week_dir} ${LOCAL_BACKUP_DEST}/${CURRENT_WEEK_LINK}
transfer_output=`$SCP ${REMOTE_USERNAME}@${REMOTE_HOST}:${REMOTE_BACKUP_DEST}/${filename} ${LOCAL_BACKUP_DEST}${dest_week_dir}/ 2>&1`
transfer_result=$?
transfer_end=`date +"${start_end_date_format}"`

if [ $transfer_result -eq 0 ]; then
	# transfer succesful
	removal_output=`$SSH ${REMOTE_USERNAME}@${REMOTE_HOST} rm -f ${REMOTE_BACKUP_DEST}/${filename} 2>&1`
	removal_result=$?
fi

if [ ${backup_result} -eq 0 -a ${transfer_result} -eq 0 ]; then
	if 	[ ${removal_result} -ne 0 ]; then
		overall_result="OK - Non rimosso"
	else
		overall_result="OK"
	fi
elif [ ${backup_result} -ne 0 -o ${transfer_result} -ne 0 ]; then
	overall_result="Errori"
fi

if [ "$1" != "--no-shutdown" ]; then
	# Shutdown slave pc
	$SSH ${REMOTE_USERNAME}@${REMOTE_HOST} "shutdown -s -f"
fi

mailfile="/tmp/backup_log_${filename_date}"
{
	echo "From: $FROM_ADDR"
	echo "To: $TO_ADDR"
	echo "Subject: [Backup] ${INSTALLATION_NAME}::${BACKUP_TAG} - $overall_result"
	echo ""
	echo "${INSTALLATION_NAME}::${BACKUP_TAG} - Automatic backup report"
	echo ":: Macchina slave:       ${REMOTE_USERNAME}@${REMOTE_HOST}"
	echo ":: Directory backuppata: $TOBACKUP"
	echo ""
	echo ":: Directory listing della settimana corrente (${dest_week_dir}):"
	echo -n "   "; ls -lth ${LOCAL_BACKUP_DEST}${dest_week_dir}
	echo ""
	echo ":: Directory di destinazione backup:"
	echo -n "   "; du -sh ${LOCAL_BACKUP_DEST}
	echo ""
	echo ":: Uso del disco:"
	df -h ${LOCAL_BACKUP_DEST}
	echo ""
	echo ":: Inzio backup:         $backup_start"
	echo ":: Fine backup:          $backup_end"
	echo ":: Fine trasferimento:   $transfer_end"
	echo ""
	echo ":: ESITO GLOBALE:        $overall_result"
	echo ":: Esito backup:         $backup_result"
	echo ":: Esito trasferimento:  $transfer_result"
	echo ":: Esito rimozione:      $removal_result"
	echo ""
	echo ":: Output backup:"
	echo "$slave_output"
	echo ""
	echo ":: Output trasferimento:"
	echo "$transfer_output"
	echo ""
	echo ":: Output rimozione copia dalla macchina slave:"
	echo "$removal_output"
	echo ""
	echo "--"
	echo "$0"
} > $mailfile

cat $mailfile | putmail.py -t
if [ $? -eq 0 ]; then
	rm $mailfile
else
	mv $mailfile ${LOCAL_BACKUP_DEST}/
fi

