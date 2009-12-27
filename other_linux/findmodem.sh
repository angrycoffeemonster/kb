#!/bin/bash

for i in `seq 0 254`
do
	echo ":: Trying subnet $i"
	ifconfig eth0 192.168.$i.69
	./subnetscan eth0 | grep -v "192.168.$i.69"
done

