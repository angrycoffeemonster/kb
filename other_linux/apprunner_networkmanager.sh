#!/bin/bash

TIMEOUT=500
counter=0

while [ $counter -lt "$TIMEOUT" ]
do

	STATE=`nm-tool | head -n 5 | grep State | cut -d ' ' -f 2`
	if [ "$STATE" = "connected" ]; then		# se c'è un profilo attivo
		pidgin &
		mail-notification &
		dropbox start -i &
		break
	fi
	sleep 1
	let counter=counter+1
done
