#!/bin/bash

function removecomments {
	cat $1 | sed -e '1p; /^[[:blank:]]*#/d; s/[[:blank:]][[:blank:]]*#.*//' -e '/^$/d' > $2
}

if [ $# -eq 3 ]; then
	DIFF_OPTS=$1
	F1=$2
	F2=$3
elif [ $# -eq 2 ]; then
    DIFF_OPTS=""
	F1=$1
	F2=$2
else
	echo "Usage: $0 [diff_options] file1 file2"
	exit 1
fi

if [ ! -f "$F1" ]; then
	echo ":: $F1 is not a regular file"
fi
if [ ! -f "$F2" ]; then
	echo ":: $F2 is not a regular file"
fi

BASE_F1=$(basename $F1)
BASE_F2=$(basename $F2)
NOC_F1=$(mktemp /tmp/${BASE_F1}.XXXXXXXX)
NOC_F2=$(mktemp /tmp/${BASE_F2}.XXXXXXXX)

removecomments $F1 $NOC_F1
removecomments $F2 $NOC_F2

colordiff -au $DIFF_OPTS $NOC_F1 $NOC_F2
