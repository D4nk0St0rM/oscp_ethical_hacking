#!/bin/bash

# sudo apt update && sudo apt install pure-ftpd -y
sudo groupadd ftpgroup
sudo useradd -g ftpgroup -d /dev/null -s /etc babycow
sudo pure-pw useradd moocow -u babycow -d /ftphome
sudo pure-pw mkdb
cd /etc/pure-ftpd/auth/
sudo ln -s ../conf/PureDB 60pdb
sudo mkdir -p /ftphome
sudo chown -R babycow:ftpgroup /ftphome/
sudo systemctl restart pure-ftpd

