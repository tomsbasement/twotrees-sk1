#!/bin/bash

# Update backports source
sudo sed -i 's|deb http://deb.debian.org/debian buster-backports|deb http://archive.debian.org/debian buster-backports|' /etc/apt/sources.list
sudo sed -i 's|deb-src http://deb.debian.org/debian buster-backports|deb-src http://archive.debian.org/debian buster-backports|' /etc/apt/sources.list

# Change to the Klipper directory and update the repository
cd ~/klipper
git stash
git pull

# Change to the Moonraker directory and update the repository
cd ~/moonraker
git stash
git pull
./scripts/install-moonraker.sh -r -f
cp ~/klipper_config/* ~/printer_data/config/
sudo service moonraker restart

# Change ownership of the klipper_config directory
sudo chown -R mks:mks ~/klipper_config

# Restart the Klipper and Moonraker services
sudo service klipper restart
sudo service moonraker restart

cd ~/
~/kiauh/kiauh.sh