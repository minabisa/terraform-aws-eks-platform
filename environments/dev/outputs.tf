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

output "eks_cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane."
  value       = module.eks_security.cluster_role_arn
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS managed node groups."
  value       = module.eks_security.node_role_arn
}

output "eks_kms_key_arn" {
  description = "KMS key ARN used for Kubernetes Secrets encryption."
  value       = module.eks_security.kms_key_arn
}

output "eks_cluster_security_group_id" {
  description = "Additional EKS control-plane security group ID."
  value       = module.eks_security.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "EKS worker-node security group ID."
  value       = module.eks_security.node_security_group_id
}
