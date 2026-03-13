#cloud-config
hostname: ${HOSTNAME}
create_hostname_file: true

write_files:
- path: /etc/systemd/system/prysm-val.service
  content: |
    [Unit]

    Description=Prysm Validator Client
    After=prysm-beacon.target
    Wants=prysm-beacon.target

    [Service]
    Type=simple
    Restart=always
    RestartSec=5s
    User=prysm-val
    WorkingDirectory=/home/prysm-val
    ExecStart=/home/prysm-val/bin/prysm.sh validator \
      --hoodi \
      --datadir /home/prysm-val/validator_data/data \
      --wallet-dir /home/prysm-val/validator_data/wallet \
      --wallet-password-file /home/prysm-val/validator_data/wallet-password.txt \
      --beacon-rpc-provider ${PRYSM_BEACON_RPC_HOST}:4000 \
      --accept-terms-of-use

    [Install]
    WantedBy=multi-user.target
  permissions: '0644'

- path: /run/prysm-import-keys/validator_keys.tar
  encoding: b64
  content: ${VALIDATOR_KEY}

- path: /usr/local/bin/get-validador-metrics.sh
  content: |
    #!/bin/env bash
    #
    set -o pipefail
    curl -s http://localhost:8081/metrics | grep -P '^validator_statuses|^validator_last_attested_slot|^validator_next_attestation_slot|^validator_successful_attestations' | tr '\n' ';\n'
  permissions: '0550'