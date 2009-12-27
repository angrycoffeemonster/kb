#!/bin/bash

# Usage:
#   backup_slave DIR_TO_BACKUP DEST_FILENAME

DIR_TO_BACKUP=$1		# e.g.: /cygdrive/h/Sispac
DEST_FILENAME=$2		# e.g.: /cygdrive/h/BackupSISPAC/backup.tgz

cd ${DIR_TO_BACKUP}/..	# e.g. go to /cygdrive/h
LASTLEVELDIR=`basename ${DIR_TO_BACKUP}`	# e.g. evals in Sispac

tar -czf ${DEST_FILENAME} ${LASTLEVELDIR}

