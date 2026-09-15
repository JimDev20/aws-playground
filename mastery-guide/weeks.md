# 12-Week Plan — What to Master and When (~1hr/day)

Overlap SAA theory 30min/day from Week 1. Floci builds 30min/day.

## Weeks 1-2: Linux + CLI muscle (foundation you already have, lock it)
Master: `ls/chmod/nano/./`| `sudo apt/jq` | bash `=/$, if/for, set -e, exit codes`
| `ping/dig/curl` | `env | grep AWS` | `docker ps/logs/inspect Mounts`.
Done: rebuild `process-order.sh`, `deploy-enhanced.sh`, `Dockerfile` blind.
SAA side: Cantrill IAM + S3 (W1-2 already ✅, re-watch at 1.5x if shaky).

## Weeks 3-4: Terraform S15 + P3 Sandbox (simple project, build first)
Master: `terraform init/validate/plan/apply/destroy`, `providers.tf` endpoint
override to `http://localhost:4566`, state file git-ignored.
Build: `terraform/` flat — S3 `shopfast-images-in/out`, DDB `ShopFastOrders` +
`ShopFastThumbs`, SQS `shopfast-image-dlq`. See `plans/project3-iac-sandbox.md`.
Done: `plan` clean, `apply` verified via `aws s3api list-buckets` /
`dynamodb list-tables` / `sqs list-queues`, `destroy` + re-apply works.
SAA side: Cantrill EC2/EBS/ELB/ASG — KodeKloud EC2 labs (Floci gap).

## Weeks 5-6: P2 Image Pipeline (hardest live win)
Master: S3 event → Lambda Pillow 128x128 → S3 out + DDB put → SQS DLQ on failure.
Reuses S11 Lambda + S13 fan-out + S2 types (`N` quoted, `status` alias).
Build: `src/image-pipeline/handler.py`, `terraform/lambda.tf/iam.tf/s3-notifications.tf`,
`scripts/test-image-pipeline.sh`. See `plans/project2-image-pipeline.md`.
Done: good JPG → thumb + DDB row; corrupt file → DLQ visible. Least-privilege IAM, no `*`.
SAA side: Cantrill VPC subnets/route/IGW/NAT/SG/NACLs — KodeKloud VPC labs.

## Weeks 7-8: P4 CI/CD + Security (gates quality)
Master: `terraform fmt -check`, `init -backend=false && validate`, `tflint`,
`checkov` (HIGH fails), `cfn-lint capstone1.json`, `docker build`.
Build: `.github/workflows/ci.yml` (validate-only; hosted runners can't reach
localhost:4566), `terraform/s3-site.tf/cloudfront.tf` plan-only,
`scripts/deploy-static.sh` local. See `plans/project4-cicd-security.md`.
Done: open PR, CI green, Checkov no HIGH (no `0.0.0.0/0` to DB, encrypted, private S3).
SAA side: Cantrill Architecture deep dives + whiteboard practice.

## Weeks 9-10: P1 Two-Tier VPC IaC-only + S17/S18
Master: VPC `10.0.0.0/16` 2AZ public/private, IGW, 1xNAT cost tradeoff,
app SG 80/443, db SG 5432 from app SG only, RDS Multi-AZ encrypted private.
Build: `terraform/modules/vpc/` + `modules/compute-db/` + `envs/local/main.tf`
**plan-only, never apply to Floci** (Floci `describe-vpcs=vpc-default` only).
`docs/p1-architecture.md` diagram + failover + cost note. S17 K8s light
(single pod/service or theory if RAM-tight), S18 Prometheus+Grafana compose.
Done: `plan` + `checkov` clean, honest resume bullet `real-AWS-ready`.
SAA side: TutorialsDojo exams until 70%+ twice, then 75%+ twice → book exam.

## Weeks 11-12: Exam + polish
Master: debug without guide — any gotcha in `README.md:85-100` on demand.
Done: SAA-C03 passed, 4 portfolio READMEs + resume bullets honest
(live on Floci vs plan-only labeled), `git log` shows P3→P2→P4→P1.
Result: ~65% junior. Remaining 35% = on-the-job cost/security/incidents + system design + Python.

## If you have less time
* 30min/day → double it (24 weeks). Never skip blind rebuild.
* Copy-paste sprint → 2-4 weeks to "finish" but stays ~25%. Not recommended.
