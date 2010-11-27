#!/bin/bash

usage() {
cat >&2 <<EOF
usage: $0 -c <config_file>

Week report script

OPTIONS:
   -h      Show this message
   -c      Configuration file
EOF
} 

CONFIGFILE=
while getopts "hc:" OPTION
do
	case $OPTION in
		h)
			usage
			exit
			;;
		c)
			CONFIGFILE=$OPTARG
			;;
		?)
			usage
			exit 2
			;;
	esac
done

if [ -n "$CONFIGFILE" ]; then
	if [ ! -f "$CONFIGFILE" ]; then
		echo "$0: config file doesn't exist or isn't a file"
		exit 1
	fi
else
	echo "$0: config file not specified"
	usage
	exit 1
fi

source "$CONFIGFILE"

week=$(date +%Y.%U)				# 2008.40 (anno.numerosettimana)

logfile="${LOCAL_BACKUP_DEST}/week_log_${week}"
{
	echo ""
	echo ":: Directory di destinazione backup:"
	echo -n "   "; du -sh ${LOCAL_BACKUP_DEST}
	echo ""
	echo ":: Uso del disco:"
	df -h ${LOCAL_BACKUP_DEST}
	echo ""
	echo "--"
	echo "$0"
} >> $logfile

cat $logfile | putmail.py -t
if [ $? -eq 0 ]; then
	rm $logfile
else
	mv $logfile ${LOCAL_BACKUP_DEST}/
fi