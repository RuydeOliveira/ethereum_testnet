#!/usr/bin/env bash
set -euxo pipefail

# Create datadir for prysm validator
if [ ! -d /home/prysm-val/validator_data/wallet ]; then
    mkdir /home/prysm-val/validator_data/wallet
    tar -xf /run/prysm-import-keys/validator_keys.tar -C /run/prysm-import-keys
    mv /run/prysm-import-keys/wallet-password.txt /home/prysm-val/validator_data/wallet-password.txt
    mv /run/prysm-import-keys/account-password.txt /home/prysm-val/validator_data/account-password.txt

    /home/prysm-val/bin/prysm.sh validator accounts import \
    --keys-dir=/run/prysm-import-keys/validator_keys \
    --wallet-dir /home/prysm-val/validator_data/wallet \
    --wallet-password-file /home/prysm-val/validator_data/wallet-password.txt \
    --account-password-file /home/prysm-val/validator_data/account-password.txt \
    --accept-terms-of-use \
    --hoodi

    chown -R prysm-val:prysm-val /home/prysm-val/validator_data/*
    chmod 540 /home/prysm-val/validator_data/*

    rm -rf /run/prysm-import-keys
fi
