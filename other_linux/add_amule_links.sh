#!/bin/bash

for l in $(cat $1)
do
	amulecmd -c "add $l"
done
