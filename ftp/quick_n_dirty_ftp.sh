#!/bin/bash

# sudo apt update && sudo apt install pure-ftpd -y
sudo groupadd ftpgroup
sudo useradd -g ftpgroup -d /dev/null -s /etc ftpuser
sudo pure-pw useradd babycow -u ftpuser -d /ftphome
sudo pure-pw mkdb
sudo cd /etc/pure-ftpd/auth/
sudo ln -s ../conf/PureDB 60pdb
sudo mkdir -p /ftphome
sudo chown -R ftpuser:ftpgroup /ftphome/
sudo systemctl restart pure-ftpd

