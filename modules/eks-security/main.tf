data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Cluster     = var.cluster_name
    },
    var.additional_tags
  )
}

# ---------------------------------------------------------------------------
# EKS cluster IAM role
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    sid     = "AllowEKSClusterAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${local.name_prefix}-eks-cluster-role"
  description        = "IAM role assumed by the Amazon EKS control plane."
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------------------------------------------------------------------------
# EKS managed node group IAM role
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    sid     = "AllowEC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${local.name_prefix}-eks-node-role"
  description        = "IAM role assumed by EC2 instances in EKS managed node groups."
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-node-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role = aws_iam_role.eks_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ecr_pull_only" {
  role = aws_iam_role.eks_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  count = var.attach_vpc_cni_policy_to_node_role ? 1 : 0

  role = aws_iam_role.eks_node.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ---------------------------------------------------------------------------
# KMS key for Kubernetes Secrets envelope encryption
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "eks_kms" {
  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowEKSClusterUse"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_role.eks_cluster.arn
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "eks" {
  description = "KMS key for Amazon EKS Kubernetes Secrets encryption."

  deletion_window_in_days = var.kms_key_deletion_window_days
  enable_key_rotation     = var.enable_kms_key_rotation
  policy                  = data.aws_iam_policy_document.eks_kms.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-secrets"
    }
  )
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.name_prefix}-eks-secrets"
  target_key_id = aws_kms_key.eks.key_id
}

# ---------------------------------------------------------------------------
# Additional security group for the EKS control plane
# ---------------------------------------------------------------------------

resource "aws_security_group" "eks_cluster" {
  name        = "${local.name_prefix}-eks-cluster-sg"
  description = "Additional security group for the EKS control plane."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-eks-cluster-sg"
    }
  )
}

# ---------------------------------------------------------------------------
# Worker-node security group
# ---------------------------------------------------------------------------

resource "aws_security_group" "eks_nodes" {
  name        = "${local.name_prefix}-eks-nodes-sg"
  description = "Security group for Amazon EKS worker nodes."
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name                                        = "${local.name_prefix}-eks-nodes-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

# Nodes communicate with other nodes.
resource "aws_vpc_security_group_ingress_rule" "nodes_from_nodes" {
  security_group_id = aws_security_group.eks_nodes.id

  description                  = "Allow communication between worker nodes."
  referenced_security_group_id = aws_security_group.eks_nodes.id
  ip_protocol                  = "-1"
}

# Control plane reaches kubelet on worker nodes.
resource "aws_vpc_security_group_ingress_rule" "nodes_kubelet_from_cluster" {
  security_group_id = aws_security_group.eks_nodes.id

  description                  = "Allow the EKS control plane to reach kubelet."
  referenced_security_group_id = aws_security_group.eks_cluster.id

  from_port   = 10250
  to_port     = 10250
  ip_protocol = "tcp"
}

# Control plane can reach admission webhooks and extension APIs on nodes.
resource "aws_vpc_security_group_ingress_rule" "nodes_https_from_cluster" {
  security_group_id = aws_security_group.eks_nodes.id

  description                  = "Allow control-plane HTTPS traffic to worker nodes."
  referenced_security_group_id = aws_security_group.eks_cluster.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# Worker nodes reach the Kubernetes API server.
resource "aws_vpc_security_group_ingress_rule" "cluster_https_from_nodes" {
  security_group_id = aws_security_group.eks_cluster.id

  description                  = "Allow worker nodes to reach the Kubernetes API."
  referenced_security_group_id = aws_security_group.eks_nodes.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

# The control plane needs outbound access to nodes and AWS-managed services.
resource "aws_vpc_security_group_egress_rule" "cluster_all_outbound" {
  security_group_id = aws_security_group.eks_cluster.id

  description = "Allow required outbound traffic from the EKS control plane."
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Worker nodes require outbound access for ECR, AWS APIs, updates, and workloads.
resource "aws_vpc_security_group_egress_rule" "nodes_all_outbound" {
  security_group_id = aws_security_group.eks_nodes.id

  description = "Allow worker-node outbound traffic."
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
