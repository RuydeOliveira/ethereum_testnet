#!/bin/env bash
#set -x

echo "Validator service status..."

ethereum_node_id=$(aws ec2 describe-instances --filters Name=tag:Name,Values=ethereum-validator Name=instance-state-name,Values=running \
    --query 'Reservations[*].Instances[*].InstanceId' --output text)

commandid=$(aws ssm send-command \
    --instance-ids $ethereum_node_id  \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["/usr/local/bin/get-validador-metrics.sh"]' \
    --comment "statuses" | jq -r '.Command.CommandId')

result=$(aws ssm list-command-invocations \
    --command-id $commandid \
    --query "CommandInvocations[?Status != 'Success']" | jq -r '.[].Status')

if [ "$result" == "Failed" ]; then
    echo "Erro: no response from validator server"
    exit
fi

result=$(aws ssm list-command-invocations \
    --command-id $commandid \
    --details \
    --query "CommandInvocations[*].CommandPlugins[*].Output[]" \
    --output text)

echo $result


validator_id=$(echo "$result" | cut -d'"' -f2 | cut -c-10)

validator_statuses=$(echo "$result" | grep -oP 'validator_statuses[^ ]* \K.*?(?=;)')
validator_statuses=${validator_statuses:="0"}

last_attested_slot=$(echo "$result" | grep -oP 'validator_last_attested_slot[^ ]* \K.*?(?=;)')
last_attested_slot=${last_attested_slot:="UNKNOWN"}

next_attestation_slot=$(echo "$result" | grep -oP 'validator_next_attestation_slot[^ ]* \K.*?(?=;)')
next_attestation_slot=${next_attestation_slot:="UNKNOWN"}

successful_attestations=$(echo "$result" | grep -oP 'validator_successful_attestations[^ ]* \K.*?(?=;)')
successful_attestations=${successful_attestations:="UNKNOWN"}

declare -A statuses=( [0]="UNKNOWN" [1]="DEPOSITED" [2]="PENDING" [3]="ACTIVE" [4]="EXITING" [5]="SLASHING" [6]="EXITED" )

echo "Validator $validator_id... status is ${statuses[$validator_statuses]}"
echo "the last attested slot was $last_attested_slot"
echo "the next attestation slot is  $next_attestation_slot"
echo "total successful attestations is  $successful_attestations"
