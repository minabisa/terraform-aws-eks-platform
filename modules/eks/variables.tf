variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be dev, stage, or prod."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS control plane."
  type        = string
  default     = "1.35"
}

variable "cluster_role_arn" {
  description = "IAM role ARN used by the EKS control plane."
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN used by the EKS managed node group."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the EKS cluster and node group."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required."
  }
}

variable "cluster_security_group_id" {
  description = "Additional security group attached to EKS control-plane ENIs."
  type        = string
}

variable "node_security_group_id" {
  description = "Security group attached to EKS worker nodes."
  type        = string
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key ARN used for Kubernetes Secrets."
  type        = string
}

variable "endpoint_private_access" {
  description = "Enable private access to the Kubernetes API endpoint."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to the Kubernetes API endpoint."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR ranges allowed to access the public Kubernetes API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "EKS control-plane log types sent to CloudWatch."
  type        = list(string)

  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}

variable "node_group_name" {
  description = "Name of the primary EKS managed node group."
  type        = string
  default     = "general"
}

variable "node_instance_types" {
  description = "EC2 instance types used by the node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Node group capacity type: ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  description = "Desired worker-node count."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum worker-node count."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum worker-node count."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Worker-node root EBS volume size in GiB."
  type        = number
  default     = 30
}

variable "node_max_unavailable" {
  description = "Maximum unavailable nodes during a managed update."
  type        = number
  default     = 1
}

variable "admin_principal_arn" {
  description = "Optional stable IAM user or role ARN granted cluster administrator access."
  type        = string
  default     = null
  nullable    = true
}

variable "additional_tags" {
  description = "Additional tags applied to supported AWS resources."
  type        = map(string)
  default     = {}
}
