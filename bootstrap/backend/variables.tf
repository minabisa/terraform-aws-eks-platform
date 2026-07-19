variable "aws_region" {
  description = "AWS Region where the Terraform state bucket will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used to construct the S3 bucket name."
  type        = string
  default     = "eks-platform"

  validation {
    condition     = length(trimspace(var.project_name)) >= 3
    error_message = "project_name must contain at least three characters."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to delete a non-empty state bucket. Keep false for safety."
  type        = bool
  default     = false
}
