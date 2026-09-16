# Project 1 — Secure & Cost-Effective Two-Tier Web Architecture (IaC-ONLY, not live on Floci)

## Objective (PDF)
HA secure foundation: app layer (EC2 public) + DB layer (RDS Postgres Multi-AZ private), per PDF milestones.

## Floci verdict: DO NOT deploy live
Probed: `describe-vpcs` = `vpc-default` only; `describe-db-instances` = `[]`; no real EC2/RDS data plane. A "live" Multi-AZ failover demo on Floci would be fake and a resume liability. Scope = **Terraform module + architecture diagram + Checkov pass, labeled real-AWS-ready**.

## Architecture (real-AWS design)
```
VPC 10.0.0.0/16, 2 AZs
 public  10.0.1.0/24 (a), 10.0.2.0/24 (b) -> IGW, app SG (80/443 in)
 private 10.0.11.0/24 (a), 10.0.12.0/24 (b) -> NAT GW, db SG (5432 in from app SG only)
 RDS postgres Multi-AZ, db.t3.micro, private subnets, no public access, encrypted
 EC2 app role (least privilege, SSM + CloudWatch only, no hardcoded creds)
```

## Files to create (after P3)
* `terraform/modules/vpc/{main,variables,outputs}.tf` — VPC, 2x public/private, IGW, 1x NAT (cost note: 1 vs 2), route tables + associations.
* `terraform/modules/compute-db/{main,variables,outputs}.tf` — `aws_security_group app/db`, `aws_instance app` (placeholder AMI var), `aws_db_subnet_group + aws_db_instance` (`multi_az=true`, `publicly_accessible=false`, `storage_encrypted=true`), `aws_iam_role app-ec2` (+ instance profile).
* `terraform/envs/local/main.tf` — wire modules with `10.0.0.0/16` (plan-only; do NOT apply to Floci expecting real DB).
* `docs/p1-architecture.md` — diagram (Mermaid) + failover narrative + cost note (NAT $ + Multi-AZ 2x).

## Verify (plan-only)
```bash
terraform -chdir=terraform/modules/vpc init -backend=false && terraform validate
terraform -chdir=terraform/envs/local plan  # expect VPC/SG/RDS plan, not applied
checkov -d terraform/modules/vpc --framework terraform
checkov -d terraform/modules/compute-db --framework terraform
```

## Security requirements (Checkov must pass)
* DB SG ingress only from app SG on 5432; no `0.0.0.0/0` to DB.
* RDS encrypted, no public access, deletion protection noted.
* EC2 role least privilege; no `iam:*`, no static keys.

## Resume bullet (honest wording)
> Designed production-grade two-tier VPC (public/private, IGW/NAT, SG-bound RDS Multi-AZ) as reusable Terraform modules with SAST-clean plan, real-AWS-ready.
