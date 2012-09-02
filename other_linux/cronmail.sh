#!/bin/bash

# symlink /usr/sbin/sendmail to this file

myself=${BASH_SOURCE[0]}
if [ -h "$myself" ]; then
	myself=$(readlink "$myself")
fi
cd "$( dirname "$myself" )"
./cronmail.py --from "venatorstorage@gmail.com" --to "Alessio Bianchi <venator85@gmail.com>" | msmtp -t 
