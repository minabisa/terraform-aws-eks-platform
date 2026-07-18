variable "project_name" {
  description = "Name of the project used in resource names and tags."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 2
    error_message = "project_name must contain at least three characters."
  }
}

variable "environment" {
  description = "Deployment environment such as dev, stage, or prod."
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "environment must be dev, stage, or prod."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR assigned to the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "availability_zones" {
  description = "Availability Zones in which subnets will be created."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones must be supplied."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks assigned to public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs must be supplied."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks assigned to private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs must be supplied."
  }
}

variable "single_nat_gateway" {
  description = "Create one shared NAT Gateway instead of one per Availability Zone."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch Logs."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days that VPC Flow Logs remain in CloudWatch."
  type        = number
  default     = 14

  validation {
    condition = contains(
      [
        1,
        3,
        5,
        7,
        14,
        30,
        60,
        90,
        120,
        150,
        180,
        365,
        400,
        545,
        731,
        1096,
        1827,
        2192,
        2557,
        2922,
        3288,
        3653
      ],
      var.flow_log_retention_days
    )

    error_message = "flow_log_retention_days must be a supported CloudWatch retention value."
  }
}

variable "cluster_name" {
  description = "Future EKS cluster name used for Kubernetes subnet tags."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags applied to all supported resources."
  type        = map(string)
  default     = {}
}
