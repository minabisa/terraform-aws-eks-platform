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
output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version used by the cluster."
  value       = module.eks.cluster_version
}

output "eks_primary_security_group_id" {
  description = "Primary security group automatically created by Amazon EKS."
  value       = module.eks.cluster_primary_security_group_id
}

output "eks_oidc_provider_arn" {
  description = "IAM OIDC provider ARN for the EKS cluster."
  value       = module.eks.oidc_provider_arn
}

output "eks_vpc_cni_role_arn" {
  description = "IAM role used by the VPC CNI service account."
  value       = module.eks.vpc_cni_role_arn
}

output "eks_node_group_name" {
  description = "Name of the EKS managed node group."
  value       = module.eks.node_group_name
}

output "eks_node_group_status" {
  description = "Status of the EKS managed node group."
  value       = module.eks.node_group_status
}
