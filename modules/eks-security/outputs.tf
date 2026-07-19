output "cluster_role_arn" {
  description = "ARN of the IAM role used by the Amazon EKS control plane."
  value       = aws_iam_role.eks_cluster.arn
}

output "cluster_role_name" {
  description = "Name of the IAM role used by the Amazon EKS control plane."
  value       = aws_iam_role.eks_cluster.name
}

output "node_role_arn" {
  description = "ARN of the IAM role used by EKS worker nodes."
  value       = aws_iam_role.eks_node.arn
}

output "node_role_name" {
  description = "Name of the IAM role used by EKS worker nodes."
  value       = aws_iam_role.eks_node.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for Kubernetes Secrets encryption."
  value       = aws_kms_key.eks.arn
}

output "kms_key_id" {
  description = "ID of the EKS KMS key."
  value       = aws_kms_key.eks.key_id
}

output "kms_alias_name" {
  description = "Alias assigned to the EKS KMS key."
  value       = aws_kms_alias.eks.name
}

output "cluster_security_group_id" {
  description = "ID of the additional EKS control-plane security group."
  value       = aws_security_group.eks_cluster.id
}

output "node_security_group_id" {
  description = "ID of the worker-node security group."
  value       = aws_security_group.eks_nodes.id
}
