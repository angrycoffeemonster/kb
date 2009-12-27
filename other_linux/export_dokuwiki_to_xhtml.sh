#!/bin/bash

#Dokuwiki Export 0.1 - by Venator85 (venator85[at]gmail[dot]com)
#Warning: Dokuwiki's URL rewrite must be turned OFF for this to work, otherwise change line 27 accordingly

#USAGE:
# Save this script in an empty dir and run it from the console:
# sh whatever.sh

FTP_DOKU_PATH="ftp://ftp.wesavetheworld.com/dokuwiki" # No trailing slashes!
FTPUSER="albert_einstein"
FTPPASS="emc2"

HTTP_DOKU_PATH="http://www.wesavetheworld.com/dokuwiki" # No trailing slashes!

wget --ftp-user=$FTPUSER --ftp-password=$FTPPASS --recursive --no-host-directories --cut-dirs=2 "$FTP_DOKU_PATH/data/pages/"

SLASH='/'
COLON=':'
mkdir "./exported"
for i in `find pages/ -type f`
do
	PAGE=${i#"pages/"}
	PAGE=${PAGE%".txt"}
	PAGE=${PAGE//$SLASH/$COLON}

	wget -O - "$HTTP_DOKU_PATH/doku.php?do=export_xhtmlbody&id=$PAGE" > "./exported/$PAGE.htm"
done

