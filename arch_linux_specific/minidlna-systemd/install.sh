#!/bin/bash -x
SERVICE="minidlna"

sudo systemctl stop $SERVICE.service
sudo systemctl disable $SERVICE.service
sudo systemctl enable $(pwd)/$SERVICE.service
sudo rm -rf /run/$SERVICE
sudo cp $SERVICE.conf /usr/lib/tmpfiles.d/
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/$SERVICE.conf
sudo systemctl start $SERVICE
