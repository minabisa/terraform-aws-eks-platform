variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
}

variable "environment" {
  description = "Deployment environment such as dev, stage, or prod."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be dev, stage, or prod."
  }
}

variable "cluster_name" {
  description = "Name of the future Amazon EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS resources will run."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the EKS VPC."
  type        = string
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets used by worker nodes."
  type        = list(string)
}

variable "kms_key_deletion_window_days" {
  description = "Waiting period before deleting the EKS KMS key."
  type        = number
  default     = 30

  validation {
    condition = (
      var.kms_key_deletion_window_days >= 7 &&
      var.kms_key_deletion_window_days <= 30
    )

    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "enable_kms_key_rotation" {
  description = "Enable automatic rotation for the EKS KMS key."
  type        = bool
  default     = true
}

variable "attach_vpc_cni_policy_to_node_role" {
  description = "Temporarily attach the VPC CNI policy to the node role."
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}
