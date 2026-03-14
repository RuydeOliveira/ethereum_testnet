#!/usr/bin/env bash
adduser --home /home/geth --disabled-password --gecos 'Geth Client' geth
adduser --home /home/prysm-beacon --disabled-password  -gecos 'Prysm Beacon Client' prysm-beacon
usermod -a -G eth-jwt geth
usermod -a -G eth-jwt prysm-beacon

# Add APT repo
add-apt-repository -y ppa:ethereum/ethereum
apt -y update
apt-get install ethereum -y
apt-get install unzip -y
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip -q awscliv2.zip
./aws/install
rm -rf ./awscliv2.zip
rm -rf ./aws

# Create secret for geth/prysm-beacom authentication
mkdir -p /var/lib/secrets
openssl rand -hex 32 > /var/lib/secrets/jwt.hex
chgrp -R eth-jwt /var/lib/secrets
chmod 750 /var/lib/secrets/
chmod 640 /var/lib/secrets/jwt.hex

# Create datadir for geth
mkdir /home/geth/hoodi_data
chown geth:geth /home/geth/hoodi_data
chmod 770 /home/geth/hoodi_data

# Create datadir for prysm beacon
mkdir /home/prysm-beacon/beacon_data
chown prysm-beacon:prysm-beacon /home/prysm-beacon/beacon_data
chmod 770 /home/prysm-beacon/beacon_data

# Install prysm beacon
mkdir /home/prysm-beacon/bin
curl -s https://raw.githubusercontent.com/OffchainLabs/prysm/master/prysm.sh --output /home/prysm-beacon/bin/prysm.sh
chown -R prysm-beacon:prysm-beacon /home/prysm-beacon/bin
chmod 750 /home/prysm-beacon/bin
chmod 550 /home/prysm-beacon/bin/prysm.sh

# Systemctl
systemctl enable --now rc-local.service
systemctl enable --now dnsupdate
systemctl daemon-reload
