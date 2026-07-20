aws_region   = "us-east-1"
project_name = "eks-platform"
environment  = "dev"
cluster_name = "eks-platform-dev"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

single_nat_gateway = true
enable_flow_logs   = true
kubernetes_version = "1.35"

eks_public_access_cidrs = [
  "73.160.203.0/24"
]

eks_node_instance_types = [
  "t3.micro"
]

eks_node_capacity_type = "ON_DEMAND"

eks_node_desired_size = 1
eks_node_min_size     = 1
eks_node_max_size     = 2
eks_node_disk_size    = 30

eks_admin_principal_arn = null
