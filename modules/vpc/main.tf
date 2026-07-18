locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "terraform-aws-eks-platform"
    },
    var.additional_tags
  )

  public_subnets = {
    for index, cidr in var.public_subnet_cidrs :
    tostring(index) => {
      cidr              = cidr
      availability_zone = var.availability_zones[index]
    }
  }

  private_subnets = {
    for index, cidr in var.private_subnet_cidrs :
    tostring(index) => {
      cidr              = cidr
      availability_zone = var.availability_zones[index]
    }
  }

  nat_gateway_keys = var.single_nat_gateway ? toset(["0"]) : toset(keys(local.public_subnets))
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                                        = "${local.name_prefix}-public-${each.value.availability_zone}"
      Tier                                        = "public"
      "kubernetes.io/role/elb"                    = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    local.common_tags,
    {
      Name                                        = "${local.name_prefix}-private-${each.value.availability_zone}"
      Tier                                        = "private"
      "kubernetes.io/role/internal-elb"           = "1"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    }
  )
}

resource "aws_eip" "nat" {
  for_each = local.nat_gateway_keys

  domain = "vpc"

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${each.key}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  for_each = local.nat_gateway_keys

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-${each.key}"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
      Tier = "public"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-rt-${each.value.availability_zone}"
      Tier = "private"
    }
  )
}

resource "aws_route" "private_nat" {
  for_each = local.private_subnets

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.this["0"].id : aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${local.name_prefix}/flow-logs"
  retention_in_days = var.flow_log_retention_days

  tags = local.common_tags
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "vpc-flow-logs.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role[0].json

  tags = local.common_tags
}

data "aws_iam_policy_document" "flow_logs_permissions" {
  count = var.enable_flow_logs ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${local.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs[0].id

  policy = data.aws_iam_policy_document.flow_logs_permissions[0].json
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  iam_role_arn    = aws_iam_role.vpc_flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc-flow-log"
    }
  )
}

check "subnet_list_lengths_match" {
  assert {
    condition = (
      length(var.availability_zones) == length(var.public_subnet_cidrs) &&
      length(var.availability_zones) == length(var.private_subnet_cidrs)
    )

    error_message = "availability_zones, public_subnet_cidrs, and private_subnet_cidrs must contain the same number of elements."
  }
}
