#!/bin/bash

while true
do
	PPP=`ifconfig|grep ppp0`
	if [ $? -ne 0 ]; then
		date
		poff -a
		pon
		echo
	fi
	sleep 30
done

