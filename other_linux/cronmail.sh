#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
./cronmail.py --from "venatorstorage@gmail.com" --to "Alessio Bianchi <venator85@gmail.com>" | msmtp -t 
