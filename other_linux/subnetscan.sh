#!/bin/bash

(./ip_address_space.pl $1 | xargs -n 1 -P 254 ping -c1 -w1) 2>/dev/null | grep icmp
