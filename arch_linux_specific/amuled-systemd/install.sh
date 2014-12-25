#!/bin/bash -x
SERVICE="amuled-venator"

sudo systemctl stop ${SERVICE}.service
sudo systemctl disable ${SERVICE}.service
sudo systemctl enable ${PWD}/${SERVICE}.service
sudo rm -rf /run/${SERVICE}
sudo cp ${SERVICE}.conf /usr/lib/tmpfiles.d/
sudo systemd-tmpfiles --create /usr/lib/tmpfiles.d/${SERVICE}.conf
sudo systemctl start ${SERVICE}
