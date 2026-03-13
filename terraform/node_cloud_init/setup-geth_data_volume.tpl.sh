#!/usr/bin/env bash
echo "Checking geth data volume"

GETH_DATA_VOLUME_ID=${GETH_DATA_VOLUME_ID}
GETH_DATA_VOLUME_ID=$(echo $GETH_DATA_VOLUME_ID | tr -d '-')
echo "EBS GETH_DATA_VOLUME_ID=$GETH_DATA_VOLUME_ID"

BLOCK_DEVICE=$(lsblk -d -o NAME,SERIAL | grep "$GETH_DATA_VOLUME_ID" | awk '{print "/dev/"$1}')
echo "BLOCK_DEVICE=$BLOCK_DEVICE"

BLOCK_DEVICE_STATUS=$(file -s $BLOCK_DEVICE | cut -d':' -f2 | tr -d ' ')
echo "BLOCK_DEVICE_STATUS=$BLOCK_DEVICE_STATUS"

if [ $BLOCK_DEVICE_STATUS == "data" ]
then
  echo Volume $GETH_DATA_VOLUME_ID is a raw device in $BLOCK_DEVICE
  echo Formating device $BLOCK_DEVICE
  mkfs -t xfs $BLOCK_DEVICE

  echo Updating /etc/fstab
  UUID=$(blkid $BLOCK_DEVICE | awk '{print $2}' | tr -d "\"")
  cp /etc/fstab /etc/fstab-edit-geth
  echo "$UUID   /home/geth/hoodi_data   xfs     defaults,nofail 0 2" >> /etc/fstab-edit-geth
  mv /etc/fstab-edit-geth /etc/fstab
  systemctl daemon-reload

  echo Mounting device $BLOCK_DEVICE on /home/geth/hoodi_data
  mount /home/geth/hoodi_data
  chown geth:geth /home/geth/hoodi_data
  chmod 770 /home/geth/hoodi_data
else
  echo Volume $GETH_DATA_VOLUME_ID is a formatted filesystem

  echo Updating /etc/fstab
  UUID=$(blkid $BLOCK_DEVICE | awk '{print $2}' | tr -d "\"")
  cp /etc/fstab /etc/fstab-edit-geth
  echo "$UUID   /home/geth/hoodi_data   xfs     defaults,nofail 0 2" >> /etc/fstab-edit-geth
  mv /etc/fstab-edit-geth /etc/fstab
  systemctl daemon-reload

  echo Mounting device $BLOCK_DEVICE on /home/geth/hoodi_data
  mount /home/geth/hoodi_data
  chown geth:geth /home/geth/hoodi_data
  chmod 770 /home/geth/hoodi_data
fi
