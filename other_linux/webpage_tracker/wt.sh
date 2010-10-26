#!/bin/bash

# Webpage Tracker 0.2 by Venator85 ( venator85{AT}gmail{DOT}com )

# USAGE
#	Create a SITENAME.site file into the script's folder, and write in that file the URL to check (be sure it starts with http*)
#	Example: echo "http://www.hey.org/yada.html" > COOLSITE.site


##### NOTIFICATION OPTIONS #####
#
# putmail.py is used to send notification mails
# Configure ~/.putmail/putmailrc with SMTP server options
#
FROM_ADDR="Webpage Tracker <venatorstorage@gmail.com>"
TO_ADDR='Alessio Bianchi <venator85@gmail.com>'

DELAY=3600 #in seconds
################################

while true
do
	BODY=""
	SUBJECT=""
	
	date
	for i in $(ls *.site)
	do
		echo -n "Testing $i... "
		URL=`cat $i|grep http`
		LASTMOD_SAVED=`cat $i|grep Modified`
		LASTMOD_SAVED=`expr "$LASTMOD_SAVED" : '[ ]*\(.*[^ ]\)[ ]*$'`		#trim heading spaces
		LASTMOD_SITE=`wget -S -O /dev/null "$URL" 2>&1 | grep Modified`
		LASTMOD_SITE=`expr "$LASTMOD_SITE" : '[ ]*\(.*[^ ]\)[ ]*$'`			#trim heading spaces
		if [[ $LASTMOD_SAVED != $LASTMOD_SITE ]]
		then
			echo $URL > $i
			echo $LASTMOD_SITE >> $i
			SITENAME="${i%.site}"
			SUBJECT="$SUBJECT$SITENAME  "
			BODY="$BODY$SITENAME ($URL)\n$LASTMOD_SITE\n\n"
		fi
	done

	if [[ $BODY != "" ]]
	then
		echo -n "Modified! Sending mail... "
		{
			echo "From: $FROM_ADDR"
			echo "To: $TO_ADDR"
			echo "Subject: [WT] ${SUBJECT}"
			echo ""
			echo "Webpage Tracker"
			echo ":: Siti modificati:"
			echo -e "${BODY}"
			echo ""
			echo "--"
			echo "$0"
		} > /tmp/wt_mail 
		cat /tmp/wt_mail | putmail.py -t
		rm -f /tmp/wt_mail
		echo "Mail sent!"
	else
		echo "Not modified"
	fi
	echo
	sleep $DELAY
done

