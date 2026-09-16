# Project 3 — IaC Local Environment Sandbox (BUILD FIRST, Live on Floci)

## Objective
Eliminate billing risk by deploying cloud resources to Floci (`http://localhost:4566`) with Terraform + Docker Compose, versioned in Git. Mirrors `capstone1.json` (S3 + DynamoDB).

## Why first
Unlocks foundation for P2/P4. No blockers except `terraform: command not found` — install binary.

## Architecture
```
terraform/*.tf --(aws provider endpoints override)--> Floci :4566
  providers.tf, variables.tf, s3.tf, dynamodb.tf, sqs.tf, outputs.tf
docker-compose.yml -> Floci container (already running) + shopfast-web (existing)
```

## Files to create
* `terraform/providers.tf` — `hashicorp/aws ~> 5.0`, `region=us-east-1`, dummy creds, `s3_use_path_style=true`, `endpoints { s3, dynamodb, lambda, sqs, iam, sts, events, logs, cloudwatch, sns } = http://localhost:4566`, `skip_*` validations true.
* `terraform/variables.tf` — `project=shopfast`, `environment=local`, `bucket_suffix`.
* `terraform/s3.tf` — `shopfast-receipts-jampol1234` (keep) + `shopfast-images-in/out` (for P2).
* `terraform/dynamodb.tf` — `ShopFastOrders` (`orderId` HASH, PAY_PER_REQUEST) + `ShopFastThumbs` (`imageId` HASH).
* `terraform/sqs.tf` — `shopfast-image-dlq`.
* `terraform/outputs.tf` — bucket names, table names, DLQ URL.

## Steps
1. Install Terraform: download linux_amd64 zip to `/tmp`, unzip to `~/.local/bin`, `terraform version`.
2. `terraform init`, `terraform fmt -recursive`, `terraform validate`.
3. `terraform plan -out=tfplan`, `terraform apply tfplan`.
4. Verify: `aws s3api list-buckets`, `aws dynamodb list-tables`, `aws sqs list-queues`.
5. Teardown test: `terraform destroy -auto-approve` (empty buckets first — same `BucketNotEmpty` gotcha as S1/S7).

## Verify commands
```bash
eval $(floci env)
terraform init && terraform validate && terraform plan
terraform apply -auto-approve
aws s3api list-buckets --no-cli-pager
aws dynamodb list-tables --no-cli-pager
```

## Security
No hardcoded creds. Least-privilege IAM roles come in P2. Run `checkov -d terraform/` (added in P4) — expect no HIGH.

## Resume bullet
> Standardized zero-cost cloud sandbox with Terraform + Docker/Floci, managing S3/DynamoDB/SQS via init/plan/apply with Git versioning.
