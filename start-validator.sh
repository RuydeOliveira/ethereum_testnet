#!/bin/env bash
echo "Starting Services"

echo "Starting Geth executor service ..."

ethereum_node_id=$(aws ec2 describe-instances \
    --filters Name=tag:Name,Values=ethereum-node Name=instance-state-name,Values=running  \
    --query 'Reservations[*].Instances[*].InstanceId' --output text)

if [ -n "$ethereum_node_id" ]; then
    commandid=$(aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --instance-ids $ethereum_node_id \
        --parameters commands=["systemctl enable --now geth"] \
        --comment "get hostname" \
        --region us-east-1 | jq -r '.Command.CommandId')

    commandid=$(aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --instance-ids $ethereum_node_id \
        --parameters commands=["systemctl status geth -n 0"] \
        --comment "get hostname" \
        --region us-east-1 | jq -r '.Command.CommandId')

    aws ssm list-command-invocations \
        --command-id $commandid \
        --details \
        --query "CommandInvocations[*].CommandPlugins[*].Output[]" \
        --output text

    echo "Starting Prysm beacon service ..."

    commandid=$(aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --instance-ids $ethereum_node_id \
        --parameters commands=["systemctl enable --now prysm-beacon"] \
        --comment "get hostname" \
        --region us-east-1 | jq -r '.Command.CommandId')

    commandid=$(aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --instance-ids $ethereum_node_id \
        --parameters commands=["systemctl status prysm-beacon -n 0"] \
        --comment "get hostname" \
        --region us-east-1 | jq -r '.Command.CommandId')

    aws ssm list-command-invocations \
        --command-id $commandid \
        --details \
        --query "CommandInvocations[*].CommandPlugins[*].Output[]" \
        --output text
else
    echo "Erro: ethereum node is not in running state"
    exit 1
fi

echo "Starting Prysm Validator service ..."

ethereum_val_id=$(aws ec2 describe-instances --filters Name=tag:Name,Values=ethereum-validator Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].InstanceId' --output text)

if [[ -n "$ethereum_val_id" ]]; then
    commandid=$(aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --instance-ids $ethereum_val_id \
        --parameters commands=["systemctl enable --now prysm-val"] \
        --comment "get hostname" \
        --region us-east-1 | jq -r '.Command.CommandId')

    commandid=$(aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --instance-ids $ethereum_val_id \
        --parameters commands=["systemctl status prysm-val -n 0"] \
        --comment "get hostname" \
        --region us-east-1 | jq -r '.Command.CommandId')

    aws ssm list-command-invocations \
        --command-id $commandid \
        --details \
        --query "CommandInvocations[*].CommandPlugins[*].Output[]" \
        --output text
else
    echo "Erro: ethereum validator is not in running state"
    exit 1
fi