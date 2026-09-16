# Junior Cloud Engineer Portfolio — Build Plans (Floci-only)

Source: `Junior_Cloud_Engineer_Project_Portfolio.pdf` (4 projects).
Environment: GitHub Codespace, Floci v1.6.0 @ `http://localhost:4566`, `us-east-1`, account `000000000000`. Zero-cost local emulation.

## Floci verdict (probed 2026-09-13)

| Project | PDF asks | Floci reality | Plan scope |
|---|---|---|---|
| P1 Two-Tier VPC/EC2/RDS | VPC, public/private, IGW/NAT, RDS Multi-AZ, SG, IAM | `describe-vpcs` = only `vpc-default`; `describe-db-instances` = `[]` (mock API, no real compute/DB failover) | **IaC-only**: Terraform module + diagram + Checkov, labeled `real-AWS-ready, not Floci-deployed` |
| P2 Image Pipeline | S3→Lambda(Pillow)→DDB + SQS DLQ | S3/DDB/Lambda/SQS all work | **Live on Floci** |
| P3 IaC Sandbox | Terraform + Docker Compose → `localhost:4566` | Fully supported | **Live on Floci, build first** |
| P4 CI/CD + Security | GitHub Actions + S3 + CloudFront + TFLint/Checkov | Hosted runners can't reach `localhost:4566`; `list-distributions` = empty stub | **Validate-only in CI + local deploy script** |

## Build order

`P3 → P2 → P4 → P1 (docs/IaC only)`

Reason: P3 unlocks Terraform foundation, P2 reuses S11/S13 Lambda+S3+DDB work for fastest win, P4 gates quality, P1 is heaviest and can't be proven live locally.

## Repo conventions

* Terraform in `terraform/` (flat first, extract `modules/vpc/` for P1 later).
* ShopFast naming: `shopfast-images-in/out`, `ShopFastThumbs`, `shopfast-image-dlq`.
* Every terminal: `floci start --persist .floci-data` + `eval $(floci env)` + `aws sts get-caller-identity`.
* `.floci-data/` stays git-ignored. Never commit secrets.

## Files in this folder

* `project3-iac-sandbox.md` — start here
* `project2-image-pipeline.md`
* `project4-cicd-security.md`
* `project1-two-tier-vpc.md` — IaC-only
