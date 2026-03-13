# Define a cloud-init config data source
data "cloudinit_config" "ethereum_validator" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = templatefile("${path.module}/validator_cloud_init/validator_cloud_config.tpl", {
      VALIDATOR_KEY         = filebase64("${path.module}/validator_keys/validator_keys.tar")
      PRYSM_BEACON_RPC_HOST = "${local.ethereum_node_name}.${aws_route53_zone.internal_zone.name}"
      HOSTNAME              = local.ethereum_validator_name
    })
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "01_setup-ethereum-validator.sh"
    content      = file("${path.module}/validator_cloud_init/setup-ethereum-validator.sh")
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "02_setup-prysm-validator-data-volume.sh"
    content      = templatefile("${path.module}/validator_cloud_init/setup-prysm_validator_data_volume.tpl.sh", {
      PRYSM_DATA_VOLUME_ID = aws_ebs_volume.prysm_validator_data_volume.id
    })
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "03_import-validator-keys.sh"
    content      = file("${path.module}/validator_cloud_init/import-validator-keys.sh")
  }
}
