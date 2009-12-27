alias ls='ls --group-directories-first --color=auto'
alias ll='ls -lh'
alias la='ls -Ah'
alias lla='ls -lAh'
alias grep='grep --color'

alias rmtilde='sudo find $PWD -name "*~" -exec rm -v {} \;'
alias wlan='sudo netcfg-auto-wireless wlan0'
alias wired='sudo netcfg2 wired'
alias subnetscan='(seq -f '192.168.0.%g' 1 254 | xargs -n 1 -P 254 ping -c1 -w1) 2>/dev/null | grep icmp'
alias rdesktop='rdesktop -u Administrator -k it -g 800x600 -a 16 -x l'
alias backupiw='tar --exclude=WebContent/WEB-INF/lib --exclude=WebContent/cfg --exclude=WebContent/log --exclude=.* -cjf iw-`date +%d_%m_%y-%H_%M_%S`.tar.bz2.txt'
alias fixperm='find $PWD -type f -print0 | xargs -0 chmod 0644 && find $PWD -type d -print0 | xargs -0 chmod 0755'

export SVN_EDITOR=`which vi`

if [[ ${EUID} == 0 ]] ; then
	PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W\n \$\[\033[00m\] '
else
	PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\n \$\[\033[00m\] '
fi


alias pacs="pacsearch"
pacsearch () {
	echo -e "$(pacman -Ss $@ | sed \
	-e 's#^.*/.* [0-9].*#\\033[1;34m&\\033[0;32m#g' )"
}

alias pacq="pacquery"
pacquery () {
	echo -e "$(pacman -Qs $@ | sed \
	-e 's#^.*/.* [0-9].*#\\033[1;34m&\\033[0;32m#g' )"
}

alias upd='sudo yaourt -Syu --aur'
alias upda='/home/venator/arch_stuff/aurup'

# enable bash completion for this user
complete -cf sudo
if [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
