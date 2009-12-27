
# MacPorts Installer addition on 2009-11-15_at_14:32:46: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

export CLICOLOR=1

# Color definition
color_none="\033[0m"
color_black="\033[0;30m"
color_red="\033[0;31m"
color_green="\033[0;32m"
color_yellow="\033[0;33m"
color_blue="\033[0;34m"
color_magenta="\033[0;35m"
color_cyan="\033[0;36m"
color_white="\033[0;37m"
color_bold_black="\033[1;30m"
color_bold_red="\033[1;31m"
color_bold_green="\033[1;32m"
color_bold_yellow="\033[1;33m"
color_bold_blue="\033[1;34m"
color_bold_magenta="\033[1;35m"
color_bold_cyan="\033[1;36m"
color_bold_white="\033[1;37m"

# Colorized prompt definition
venator_prompt()
{
	EXITSTATUS=$?
	if [ ${EUID} -eq 0 ]
	then
		PS1="\[${color_bold_red}\]"		# Se root, stampa root@localhost in rosso
	else
		PS1="\[${color_bold_yellow}\]"		# Altrimenti, stampa user@localhost in giallo
	fi
	PS1="${PS1}\u@\h\[${color_bold_blue}\] \w\n "
	[ $EXITSTATUS -ne 0 ] && PS1="${PS1}\[${color_bold_red}\]$EXITSTATUS "	# se exit code dell'ultimo processo != 0, stampalo in rosso
	PS1="${PS1}\$\[${color_none}\] "
}
PROMPT_COMMAND=venator_prompt

alias ll='ls -lh'
alias la='ls -Ah'
alias lla='ls -lh'
alias grep='grep --color'
alias egrep='egrep --color'
alias ..='cd ..'

export SVN_EDITOR=`which vim`

# enable bash completion for this user
complete -cf sudo
if [ -f /opt/local/etc/bash_completion ]; then
	. /opt/local/etc/bash_completion
fi

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# NS-2 tweaked by Venator
export PATH=$PATH:/usr/libexec:/ns-allinone-2.34/bin:/ns-allinone-2.34/tcl8.4.18/unix:/ns-allinone-2.34/tk8.4.18/unix
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/ns-allinone-2.34/otcl-1.13:/ns-allinone-2.34/lib
export TCL_LIBRARY=:/ns-allinone-2.34/tcl8.4.18/library
export DISPLAY=:0.0
