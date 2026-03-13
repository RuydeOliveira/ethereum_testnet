resource "aws_instance" "ethereum_node" {
  ami                         = "ami-0b6c6ebed2801a5cb"
  availability_zone           = "us-east-1a"
  instance_type               = "t3.xlarge"
  subnet_id                   = module.vpc.public_subnets[0]
  user_data_base64            = data.cloudinit_config.ethereum_node.rendered
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.ethereum_node.id]
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name = "ethereum-node"
  }
}
