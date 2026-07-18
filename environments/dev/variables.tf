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
