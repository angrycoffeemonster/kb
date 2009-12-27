#!/bin/bash

gcc ed2k.c -Wall -o ./ed2k
sudo rm /usr/bin/ed2k
sudo ln -s $PWD/ed2k /usr/bin/ed2k-link-handler
