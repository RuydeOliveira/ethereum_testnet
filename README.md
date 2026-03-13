Ethereum validator in Hoodi Testnet

This repository contains all the configuration required to start a validator on the AWS provider.
It’s using Geth for the execution layer, Prysm for consensus and validator services.

Infrastructure components and topology:
Two subnets, one public subnet for an Ethereum node running Geth and Prysm beacon
One private subnet for an Ethereum validator running Prysm validator
Three attached EBS volumes, one for each service, that persist the data in case of node restart, upgrade, or manual deletion.
The Instances console can be accessed via AWS SSM session on AWS EC2 console.
One internal hosted zone to resolve the ethereum node address, allowing Prysm validator to find the beacon address even in case of a restart.

The infrastructure is provisioned using the command ./provision.sh, but the services will not start automatically as specified in the task requirements.

Use the script ./start-validator to initialize all the services, Geth, beacon and validator. Once initialized, you can restart the hosting instances that the service will bring up automatically.

The script ./check-health.sh connects to the validator and queries its status.

From the instance console, all services can be initialized and terminated using a systemd-style command:
systemctl start/stop geth
systemctl start/stop prysm-beacon
systemctl start/stop prysm-val

The internal hosted zone is named staking.internal. The Beacon node updates the DNS record named ethereum-node every time it is initialized.

TODO:
Improvements that are required for a production environment:
Enable encryption for communication between the beacon and validator service.
Change the identification used to map data volumes from UUID to label.
Another suggestion is to add the DNS record update script to the crontab to mitigate the risk of the record not being updated as expected.
Instance size and disk performance need to be upgraded.
