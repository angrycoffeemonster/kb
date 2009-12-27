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

for name in "$@"; do
	wget -nv "http://aur.archlinux.org/packages/$name/$name.tar.gz"
	if [ $? -ne 0 ]; then
		echo -e "${COL_BOLD_RED}!! Can't download '$name.tar.gz'${COL_NONE}"
		continue
	fi
	tar -xf $name.tar.gz
	rm $name.tar.gz
done

