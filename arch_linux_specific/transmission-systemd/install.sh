#!/bin/bash

sudo systemctl stop transmission.service
sudo systemctl disable transmission.service
sudo systemctl enable $(pwd)/transmission.service
sudo rm -rf /run/transmission
sudo cp transmission.conf /usr/lib/tmpfiles.d/
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/transmission.conf
sudo systemctl start transmission
