#!/bin/bash

# unset color
COL_NONE="\033[0m"

# regular colors
COL_BLACK="\033[0;30m"
COL_RED="\033[0;31m"
COL_GREEN="\033[0;32m"
COL_YELLOW="\033[0;33m"
COL_BLUE="\033[0;34m"
COL_MAGENTA="\033[0;35m"
COL_CYAN="\033[0;36m"
COL_WHITE="\033[0;37m"

# bolded colors
COL_BOLD_BLACK="\033[1;30m"
COL_BOLD_RED="\033[1;31m"
COL_BOLD_GREEN="\033[1;32m"
COL_BOLD_YELLOW="\033[1;33m"
COL_BOLD_BLUE="\033[1;34m"
COL_BOLD_MAGENTA="\033[1;35m"
COL_BOLD_CYAN="\033[1;36m"
COL_BOLD_WHITE="\033[1;37m"

#################################################################

REPO_NAME='venator'

#========= BEGIN CODE FROM YAOURT ====================================================
# get info for aur package from json RPC interface and store it in jsonfinfo variable for later use
initjsoninfo(){
unset jsoninfo
jsoninfo=`wget -q -O - "http://aur.archlinux.org/rpc.php?type=info&arg=$1"`
if  echo $jsoninfo | grep -q '"No result found"' || [ -z "$jsoninfo" ]; then
	return 1
else
	return 0
fi
}

#Get value from json (in memory):  ID, Name, Version, Description, URL, URLPath, License, NumVotes, OutOfDate
parsejsoninfo(){
	echo $jsoninfo | sed -e 's/^.*[{,]"'$1'":"//' -e 's/"[,}].*$//'
}

isnumeric(){
	if let $1 2>/dev/null; then return 0; else return 1; fi
}

is_x_gt_y(){
	local version=( $(echo $1 | tr "[:punct:]" "\ " | sed 's/[a-zA-Z]/ &/g') )
	local lversion=( $(echo $2 | tr "[:punct:]" "\ " | sed 's/[a-zA-Z]/ &/g') )
	if [ ${#version[@]} -gt ${#lversion[@]} ]; then 
		versionlength=${#version[@]}
	else
		versionlength=${#lversion[@]}
	fi
	
	for i_index in `seq 0 $((${versionlength}-1))`; do 
		if `isnumeric ${version[$i_index]}` && `isnumeric ${lversion[$i_index]}`;  then
			if [ ${version[$i_index]} -eq ${lversion[$i_index]} ]; then continue; fi
			if [ ${version[$i_index]} -gt ${lversion[$i_index]} ]; then return 0; else return 1; fi
			break
		elif [ `isnumeric ${version[$i_index]}` -ne  `isnumeric ${lversion[$i_index]}` ]; then
			if [ "${version[$i_index]}" = "${lversion[$i_index]}" ]; then continue;fi
			if [ "${version[$i_index]}" \> "${lversion[$i_index]}" ]; then return 0; else return 1; fi
			break
		fi
	done
	return 1
}
#========= END CODE FROM YAOURT ====================================================

for pkg in `find /var/lib/pacman/sync/$REPO_NAME/ -name desc`; do
	PKGNAME=`grep -A 1 '%NAME%' $pkg |grep -v '%NAME%'`
	local_version=`grep -A 1 '%VERSION%' $pkg |grep -v '%VERSION%'`
	initjsoninfo $PKGNAME || { echo -e "${COL_BOLD_MAGENTA}:: $PKGNAME not found on AUR${COL_NONE}"; continue; }
	aur_version=`parsejsoninfo Version`
	if `is_x_gt_y $aur_version $local_version`; then
		echo -e "${COL_BOLD_GREEN}:: $PKGNAME: ${local_version} => ${aur_version}${COL_NONE}"
	elif [ $local_version != $aur_version ]; then
		echo -e "${COL_BOLD_RED}:: $PKGNAME: local=$local_version ${COL_BOLD_NONE}aur=$aur_version${COL_NONE}"
	else
		[ "$1" = '-v' ] && echo -e ":: $PKGNAME: up to date"
	fi
done

