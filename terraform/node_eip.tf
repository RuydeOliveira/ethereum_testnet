resource "aws_eip" "ethereum_node" {
  #instance = aws_instance.ethereum_node.id
}

resource "aws_eip_association" "ethereum_node" {
  instance_id   = aws_instance.ethereum_node.id
  allocation_id = aws_eip.ethereum_node.id
}