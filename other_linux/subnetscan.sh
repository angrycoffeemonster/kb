#!/bin/bash

if [ $# -eq 0 ]; then
	echo ":: Warning: network interface not provided. Assuming eth0"
	NIC="eth0"
else
	NIC=$1
fi

perl -MNetAddr::IP -e 1 &>/dev/null
if [ $? -ne 0 ]; then
	echo ":: Perl module 'NetAddr::IP' not installed. Installing now..."
	sudo pacman -S perl-netaddr-ip
fi

(./ip_address_space.pl $NIC | xargs -n 1 -P 254 ping -c1 -w1) 2>/dev/null | grep icmp