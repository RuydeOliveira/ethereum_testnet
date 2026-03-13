resource "aws_security_group" "ethereum_node" {
  name        = "ethereum_node"
  description = "ethereum_node traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "ethereum_node"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ethereum_node_tcp_30303" {
  security_group_id = aws_security_group.ethereum_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30303
  ip_protocol       = "tcp"
  to_port           = 30303
}

resource "aws_vpc_security_group_ingress_rule" "ethereum_node_udp_30303" {
  security_group_id = aws_security_group.ethereum_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 30303
  ip_protocol       = "udp"
  to_port           = 30303
}

resource "aws_vpc_security_group_ingress_rule" "ethereum_node_udp_12k" {
  security_group_id = aws_security_group.ethereum_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 12000
  ip_protocol       = "udp"
  to_port           = 12000
}

resource "aws_vpc_security_group_ingress_rule" "ethereum_node_udp_13k" {
  security_group_id = aws_security_group.ethereum_node.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 13000
  ip_protocol       = "udp"
  to_port           = 13000
}

resource "aws_vpc_security_group_ingress_rule" "ethereum_node_tcp_4k" {
  security_group_id            = aws_security_group.ethereum_node.id
  referenced_security_group_id = aws_security_group.ethereum_validator.id
  from_port                    = 4000
  ip_protocol                  = "tcp"
  to_port                      = 4000
}

resource "aws_vpc_security_group_egress_rule" "ethereum_node_egress_allow_all" {
  security_group_id = aws_security_group.ethereum_node.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
