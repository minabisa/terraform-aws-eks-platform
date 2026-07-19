output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket."
  value       = aws_s3_bucket.terraform_state.arn
}

output "aws_account_id" {
  description = "AWS account containing the state bucket."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region containing the state bucket."
  value       = var.aws_region
}

output "dev_backend_configuration" {
  description = "Suggested backend configuration values for the dev environment."

  value = {
    bucket       = aws_s3_bucket.terraform_state.id
    key          = "dev/terraform.tfstate"
    region       = var.aws_region
    encrypt      = true
    use_lockfile = true
  }
}
