#!/usr/bin/env bash
echo "Checking prysm beacon data volume"

PRYSM_DATA_VOLUME_ID=${PRYSM_DATA_VOLUME_ID}
PRYSM_DATA_VOLUME_ID=$(echo $PRYSM_DATA_VOLUME_ID | tr -d '-')
echo "EBS PRYSM_DATA_VOLUME_ID=$PRYSM_DATA_VOLUME_ID"

BLOCK_DEVICE=$(lsblk -d -o NAME,SERIAL | grep "$PRYSM_DATA_VOLUME_ID" | awk '{print "/dev/"$1}')
echo "BLOCK_DEVICE=$BLOCK_DEVICE"

BLOCK_DEVICE_STATUS=$(file -s $BLOCK_DEVICE | cut -d':' -f2 | tr -d ' ')
echo "BLOCK_DEVICE_STATUS=$BLOCK_DEVICE_STATUS"

if [ $BLOCK_DEVICE_STATUS == "data" ]
then
  echo Volume $PRYSM_DATA_VOLUME_ID is a raw device in $BLOCK_DEVICE
  echo Formating device $BLOCK_DEVICE
  mkfs -t xfs $BLOCK_DEVICE

  echo Updating /etc/fstab
  UUID=$(blkid $BLOCK_DEVICE | awk '{print $2}' | tr -d "\"")
  cp /etc/fstab /etc/fstab-edit-prysm-beacon
  echo "$UUID   /home/prysm-beacon/beacon_data   xfs     defaults,nofail 0 2" >> /etc/fstab-edit-prysm-beacon
  mv /etc/fstab-edit-prysm-beacon /etc/fstab
  systemctl daemon-reload

  echo Mounting device $BLOCK_DEVICE on /home/prysm-beacon/beacon_data
  mount /home/prysm-beacon/beacon_data
  chown prysm-beacon:prysm-beacon /home/prysm-beacon/beacon_data
  chmod 770 /home/prysm-beacon/beacon_data
else
  echo Volume $PRYSM_DATA_VOLUME_ID is a formatted filesystem

  echo Updating /etc/fstab
  UUID=$(blkid $BLOCK_DEVICE | awk '{print $2}' | tr -d "\"")
  cp /etc/fstab /etc/fstab-edit-prysm-beacon
  echo "$UUID   /home/prysm-beacon/beacon_data   xfs     defaults,nofail 0 2" >> /etc/fstab-edit-prysm-beacon
  mv /etc/fstab-edit-prysm-beacon /etc/fstab
  systemctl daemon-reload

  echo Mounting device $BLOCK_DEVICE on /home/prysm-beacon/beacon_data
  mount /home/prysm-beacon/beacon_data
  chown prysm-beacon:prysm-beacon /home/prysm-beacon/beacon_data
  chmod 770 /home/prysm-beacon/beacon_data
fi
