module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name

  vpc_cidr = var.vpc_cidr

  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  single_nat_gateway = var.single_nat_gateway
  enable_flow_logs   = var.enable_flow_logs

  flow_log_retention_days = 14

  additional_tags = {
    Owner      = "Mina-Bisa"
    CostCenter = "DevOps-Lab"
  }
}
