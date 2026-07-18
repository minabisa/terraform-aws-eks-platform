output "vpc_id" {
  description = "Development VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Development public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Development private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "Development NAT Gateway IDs."
  value       = module.vpc.nat_gateway_ids
}

output "availability_zones" {
  description = "Availability Zones used by the development VPC."
  value       = module.vpc.availability_zones
}

output "flow_log_group_name" {
  description = "CloudWatch Log Group for VPC Flow Logs."
  value       = module.vpc.flow_log_group_name
}
