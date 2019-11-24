output "vpc-id" {
  description = "The ID of the Bitso VPC"
  value       = aws_vpc.prod-vpc.id
}
