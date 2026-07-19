# Production AWS EKS Platform

A production-style DevOps portfolio project that provisions and operates an
Amazon EKS platform using Terraform, Jenkins, Helm, Argo CD, Vault, AWS Load
Balancer Controller, ExternalDNS, Prometheus, and Grafana.

## Current progress

- [x] Phase 1 — AWS networking foundation
- [x] Phase 2 — Remote Terraform state
- [x] Phase 3 — IAM and security
- [ ] Phase 4 — Amazon EKS
- [ ] Phase 5 — Jenkins CI/CD
- [ ] Phase 6 — Helm application deployment
- [ ] Phase 7 — Argo CD GitOps
- [ ] Phase 8 — Vault secret management
- [ ] Phase 9 — AWS Load Balancer Controller
- [ ] Phase 10 — ExternalDNS
- [ ] Phase 11 — Monitoring
- [ ] Phase 12 — Production hardening

## Phase 1 architecture

The development environment contains:

- One VPC
- Two public subnets across two Availability Zones
- Two private subnets across two Availability Zones
- Internet Gateway
- NAT Gateway
- Public and private route tables
- EKS-compatible subnet tags
- VPC Flow Logs

## Repository structure

```text
terraform-aws-eks-platform/
├── modules/
│   └── vpc/
├── environments/
│   ├── dev/
│   ├── stage/
│   └── prod/
├── scripts/
├── docs/
└── README.md
Safety

The development configuration creates a NAT Gateway, Elastic IP, CloudWatch
Logs, and other billable AWS resources.

Destroy lab resources when they are no longer required:

cd environments/dev
terraform destroy

## Phase 2 — Secure Remote Terraform State

Terraform state is stored securely in Amazon S3 instead of only on the local computer.

The backend configuration includes:

- Dedicated S3 state bucket
- S3 versioning
- Server-side encryption
- Public-access blocking
- HTTPS-only bucket policy
- Native Terraform state locking
- Separate state path for the development environment
- Protection against accidental bucket deletion

The development state is stored using the following structure:

```text
s3://terraform-state-bucket/dev/terraform.tfstate


## Phase 3 — IAM and EKS Security Foundation

The EKS security foundation includes:

- Dedicated EKS control-plane IAM role
- Dedicated EKS worker-node IAM role
- Amazon EKS managed policies
- Amazon ECR image-pull permissions
- Customer-managed KMS encryption key
- Automatic KMS key rotation
- Separate EKS cluster and node security groups
- Restricted communication between the control plane and worker nodes
- No publicly exposed SSH access
- VPC CNI permissions separated from the worker-node role