output "ethereum_node" {
  value = aws_instance.ethereum_node.private_dns
}
output "ethereum_node_public" {
  value = aws_instance.ethereum_node.public_dns
}
output "ethereum_validator" {
  value = aws_instance.ethereum_validator.private_dns
}