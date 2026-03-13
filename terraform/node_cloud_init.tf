# Define a cloud-init config data source
data "cloudinit_config" "ethereum_node" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content = templatefile("${path.module}/node_cloud_init/node_cloud_config.tpl", {
      PUBLIC_IP_ADDRESS = aws_eip.ethereum_node.public_ip
      HOSTED_ZONE_ID    = aws_route53_zone.internal_zone.zone_id
      HOSTED_ZONE_NAME  = aws_route53_zone.internal_zone.name
      HOSTNAME          = local.ethereum_node_name
    })
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "01_setup-ethereum-node.sh"
    content      = file("${path.module}/node_cloud_init/setup-ethereum-node.sh")
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "02_setup-geth-data-volume.sh"
    content = templatefile("${path.module}/node_cloud_init/setup-geth_data_volume.tpl.sh", {
      GETH_DATA_VOLUME_ID = aws_ebs_volume.geth_data_volume.id
    })
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "03_setup-prysm-beacon-data-volume.sh"
    content = templatefile("${path.module}/node_cloud_init/setup-prysm_beacon_data_volume.tpl.sh", {
      PRYSM_DATA_VOLUME_ID = aws_ebs_volume.prysm_beacon_data_volume.id
    })
  }
}
