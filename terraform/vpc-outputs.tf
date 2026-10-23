output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.enterprise_eks_vpc.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "List of IDs of isolated subnets"
  value       = aws_subnet.isolated[*].id
}

output "nat_gateway_ip" {
  description = "The Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}