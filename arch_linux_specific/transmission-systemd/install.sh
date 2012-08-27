#!/bin/bash

sudo systemctl disable transmission.service
sudo systemctl enable $(PWD)/transmission.service
sudo rm -rf /run/transmission
sudo cp transmission.conf /usr/lib/tmpfiles.d/
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/transmission.conf
sudo systemctl start transmission
