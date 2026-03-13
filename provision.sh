#!/bin/env bash
#set -x

echo "Provisioning infrastructure..."

cd ./terraform
terraform init
terraform apply -auto-approve
cd ../