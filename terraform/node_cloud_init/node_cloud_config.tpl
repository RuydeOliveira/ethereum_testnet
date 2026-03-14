#cloud-config
hostname: ${HOSTNAME}
create_hostname_file: true

groups:
  - eth-jwt

write_files:
- path: /etc/systemd/system/geth.service
  content: |
    [Unit]

    Description=Geth Full Node
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=simple
    Restart=always
    RestartSec=5s
    User=geth
    WorkingDirectory=/home/geth
    ExecStart=/usr/bin/geth \
      --http \
      --http.api eth,net,engine,admin \
      --hoodi \
      --datadir /home/geth/hoodi_data \
      --authrpc.jwtsecret /var/lib/secrets/jwt.hex

    [Install]
    WantedBy=multi-user.target
  permissions: '0644'
- path: /etc/systemd/system/prysm-beacon.service
  content: |
    [Unit]

    Description=Prysm Beacon Chain
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=simple
    Restart=always
    RestartSec=5s
    User=prysm-beacon
    WorkingDirectory=/home/prysm-beacon
    ExecStart=/home/prysm-beacon/bin/prysm.sh beacon-chain \
      --hoodi \
      --datadir /home/prysm-beacon/beacon_data \
      --execution-endpoint http://127.0.0.1:8551 \
      --jwt-secret /var/lib/secrets/jwt.hex \
      --checkpoint-sync-url https://hoodi.beaconstate.info \
      --p2p-host-ip ${PUBLIC_IP_ADDRESS} \
      --rpc-host $PRYSM_BEACON_RPC_HOST \
      --accept-terms-of-use

    [Install]
    WantedBy=multi-user.target
  permissions: '0644'
- path: /etc/systemd/system/dnsupdate.service
  content: |
    [Unit]
    Description=Update ethereum node resource record
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=oneshot
    ExecStart=/usr/local/bin/updatednsrecord.sh
    RemainAfterExit=yes 

    [Install]
    WantedBy=multi-user.target
  permissions: '0644'

- path: /usr/local/bin/updatednsrecord.sh
  content: |
    #!/bin/bash
    PRIVATE_IP=$(hostname -I)

    # Your domain and hosted zone ID
    HOSTED_ZONE_ID=${HOSTED_ZONE_ID}
    RECORD_NAME="${HOSTNAME}.${HOSTED_ZONE_NAME}"

    # Create a JSON file to change the A record
    cat <<EOF > /tmp/route53_changes.json
    {
      "Comment":"Update A record for $RECORD_NAME to $PRIVATE_IP",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "Name":"$RECORD_NAME",
            "Type":"A",
            "TTL":10,
            "ResourceRecords":[
              {
                "Value":"$PRIVATE_IP"
              }
            ]
          }
        }
      ]
    }
    EOF

    # Use AWS CLI to update the Route 53 record set
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch file:///tmp/route53_changes.json
  permissions: '0550'

- path: /etc/rc.local
  content: |
    #!/bin/env bash
    systemctl set-environment PRYSM_BEACON_RPC_HOST=$(hostname -I)
  permissions: '0770'
