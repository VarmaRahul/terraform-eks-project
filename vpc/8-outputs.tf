output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"

  value = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]
}

output "public_subnet_ids" {
  description = "Public subnet IDs"

  value = [
    aws_subnet.public_zone1.id,
    aws_subnet.public_zone2.id
  ]
}