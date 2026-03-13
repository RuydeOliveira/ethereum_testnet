resource "aws_security_group" "ethereum_validator" {
  name        = "ethereum_validator"
  description = "ethereum_validator traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "ethereum_validator"
  }
}

/* resource "aws_vpc_security_group_ingress_rule" "ethereum_validator" {
  security_group_id = aws_security_group.ethereum_validator.id
  cidr_ipv4         = module.vpc.private_subnets_cidr_blocks[0]
  from_port         = 30303
  ip_protocol       = "-1"
  to_port           = 30303
} */

resource "aws_vpc_security_group_egress_rule" "ethereum_validator_egress_allow_all" {
  security_group_id = aws_security_group.ethereum_validator.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
