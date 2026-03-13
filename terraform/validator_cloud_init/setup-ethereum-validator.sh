#!/usr/bin/env bash
adduser --home /home/prysm-val --disabled-password  -gecos 'Prysm Validator Client' prysm-val

# Create datadir for prysm validator
mkdir /home/prysm-val/validator_data
chown prysm-val:prysm-val /home/prysm-val/validator_data
chmod 770 /home/prysm-val/validator_data

# Install prysm validator
mkdir /home/prysm-val/bin
curl https://raw.githubusercontent.com/OffchainLabs/prysm/master/prysm.sh --output /home/prysm-val/bin/prysm.sh
chown -R prysm-val:prysm-val /home/prysm-val/bin
chmod 750 /home/prysm-val/bin
chmod 540 /home/prysm-val/bin/prysm.sh

# Systemctl
systemctl daemon-reload
