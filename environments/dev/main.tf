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

module "eks_security" {
  source = "../../modules/eks-security"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name

  vpc_id               = module.vpc.vpc_id
  vpc_cidr_block       = module.vpc.vpc_cidr_block
  private_subnet_cidrs = module.vpc.private_subnet_cidrs

  enable_kms_key_rotation      = true
  kms_key_deletion_window_days = 30

  # The VPC CNI will receive its own role during cluster/add-on creation.
  attach_vpc_cni_policy_to_node_role = false

  additional_tags = {
    Owner      = "Mina-Bisa"
    CostCenter = "DevOps-Lab"
  }
}
