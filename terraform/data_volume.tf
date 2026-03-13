#  Geth volume data
resource "aws_ebs_volume" "geth_data_volume" {
  availability_zone = "us-east-1a"
  encrypted         = true
  #final_snapshot   = true   -- set as true for production environment
  size              = 2000
  type              = "gp3"

  tags = {
    Name = "geth-data-volume"
  }
}

resource "aws_volume_attachment" "geth_data_volume" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.geth_data_volume.id
  instance_id = aws_instance.ethereum_node.id
}

#  Prysm beacon volume data
resource "aws_ebs_volume" "prysm_beacon_data_volume" {
  availability_zone = "us-east-1a"
  encrypted         = true
  #final_snapshot   = true   -- set as true for production environment
  size              = 1000
  type              = "gp3"

  tags = {
    Name = "prysm-beacon-data-volume"
  }
}

resource "aws_volume_attachment" "prysm_beacon_data_volume" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.prysm_beacon_data_volume.id
  instance_id = aws_instance.ethereum_node.id
}

#  Prysm validator volume data
resource "aws_ebs_volume" "prysm_validator_data_volume" {
  availability_zone = "us-east-1a"
  encrypted         = true
  #final_snapshot   = true   -- set as true for production environment
  size              = 500
  type              = "gp3"

  tags = {
    Name = "prysm-validator-data-volume"
  }
}

resource "aws_volume_attachment" "prysm_validator_data_volume" {
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.prysm_validator_data_volume.id
  instance_id = aws_instance.ethereum_validator.id
}