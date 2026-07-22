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

  vpc_id = module.vpc.vpc_id

  enable_kms_key_rotation      = true
  kms_key_deletion_window_days = 30

  # The VPC CNI will receive its own role during cluster/add-on creation.
  attach_vpc_cni_policy_to_node_role = false

  additional_tags = {
    Owner      = "Mina-Bisa"
    CostCenter = "DevOps-Lab"
  }
}
module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = var.cluster_name

  kubernetes_version = var.kubernetes_version

  cluster_role_arn = module.eks_security.cluster_role_arn
  node_role_arn    = module.eks_security.node_role_arn

  private_subnet_ids = module.vpc.private_subnet_ids

  cluster_security_group_id = module.eks_security.cluster_security_group_id
  node_security_group_id    = module.eks_security.node_security_group_id

  kms_key_arn = module.eks_security.kms_key_arn

  endpoint_private_access = true
  endpoint_public_access  = true

  # Learning configuration. Restrict this to your public IP later.
  public_access_cidrs = var.eks_public_access_cidrs

  node_group_name     = "general"
  node_instance_types = var.eks_node_instance_types
  node_capacity_type  = var.eks_node_capacity_type

  node_desired_size = var.eks_node_desired_size
  node_min_size     = var.eks_node_min_size
  node_max_size     = var.eks_node_max_size
  node_disk_size    = var.eks_node_disk_size

  admin_principal_arn = var.eks_admin_principal_arn

  additional_tags = {
    Owner      = "Mina-Bisa"
    CostCenter = "DevOps-Lab"
  }
}
