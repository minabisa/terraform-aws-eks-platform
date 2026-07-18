# Production AWS EKS Platform

A production-style DevOps portfolio project that provisions and operates an
Amazon EKS platform using Terraform, Jenkins, Helm, Argo CD, Vault, AWS Load
Balancer Controller, ExternalDNS, Prometheus, and Grafana.

## Current progress

- [x] Phase 1 — AWS networking foundation
- [ ] Phase 2 — Remote Terraform state
- [ ] Phase 3 — IAM and security
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

