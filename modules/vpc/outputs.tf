output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block assigned to the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets ordered by their logical keys."
  value = [
    for key in sort(keys(aws_subnet.public)) :
    aws_subnet.public[key].id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets ordered by their logical keys."
  value = [
    for key in sort(keys(aws_subnet.private)) :
    aws_subnet.private[key].id
  ]
}

output "public_subnet_cidrs" {
  description = "CIDR blocks assigned to public subnets."
  value = [
    for key in sort(keys(aws_subnet.public)) :
    aws_subnet.public[key].cidr_block
  ]
}

output "private_subnet_cidrs" {
  description = "CIDR blocks assigned to private subnets."
  value = [
    for key in sort(keys(aws_subnet.private)) :
    aws_subnet.private[key].cidr_block
  ]
}

output "availability_zones" {
  description = "Availability Zones used by the VPC."
  value       = var.availability_zones
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value = [
    for key in sort(keys(aws_nat_gateway.this)) :
    aws_nat_gateway.this[key].id
  ]
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of private route tables."
  value = [
    for key in sort(keys(aws_route_table.private)) :
    aws_route_table.private[key].id
  ]
}

output "flow_log_id" {
  description = "ID of the VPC Flow Log when enabled."
  value       = try(aws_flow_log.this[0].id, null)
}

output "flow_log_group_name" {
  description = "CloudWatch Log Group used by VPC Flow Logs."
  value       = try(aws_cloudwatch_log_group.vpc_flow_logs[0].name, null)
}
