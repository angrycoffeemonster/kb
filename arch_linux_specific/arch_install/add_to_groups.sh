#!/bin/bash

if [ -z $1 ]
then
	USERNAME=`whoami`
else
	USERNAME=$1
fi

for g in abs audio camera disk fuse kmem log lp network optical power scanner slocate storage tty video vmware wheel stb-admin 
do
	sudo gpasswd -a $USERNAME $g
done

