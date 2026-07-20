variable "aws_region" {
  description = "AWS Region in which resources will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in naming and tagging."
  type        = string
  default     = "eks-platform"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Future Amazon EKS cluster name."
  type        = string
  default     = "eks-platform-dev"
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR."
  type        = string
}

variable "availability_zones" {
  description = "Availability Zones for network resources."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks."
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Use one NAT Gateway for the environment."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs."
  type        = bool
  default     = true
}
variable "kubernetes_version" {
  description = "Kubernetes version used by the EKS cluster."
  type        = string
  default     = "1.35"
}

variable "eks_public_access_cidrs" {
  description = "CIDR ranges allowed to access the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_node_instance_types" {
  description = "EC2 instance types used by the EKS node group."
  type        = list(string)
  default     = ["t3.micro"]
}

variable "eks_node_capacity_type" {
  description = "EKS node-group capacity type."
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "eks_node_disk_size" {
  description = "Worker-node root volume size in GiB."
  type        = number
  default     = 30
}

variable "eks_admin_principal_arn" {
  description = "Optional stable IAM user or role ARN granted EKS administrator access."
  type        = string
  default     = null
  nullable    = true
}
