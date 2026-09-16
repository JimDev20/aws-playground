# Project 2 — Fully Automated Serverless Event-Driven Image Pipeline (Live on Floci)

## Objective
Async microservice: upload → thumbnail → metadata, decoupled pay-per-use. Reuses S11 Lambda + S13 `process-order.sh` flow + S2 DynamoDB patterns.

## Architecture
```
S3 shopfast-images-in (ObjectCreated:*.jpg/png)
  -> Lambda pillow-thumb (Python + Pillow, 128x128, /tmp, on-failure -> SQS DLQ)
    -> S3 shopfast-images-out/thumbs/
    -> DynamoDB ShopFastThumbs { imageId(HASH), original, thumb, sizes, timestamp }
Poison file -> SQS shopfast-image-dlq (redrive, no dropped requests)
```

## Files to create
* `src/image-pipeline/handler.py` — parse S3 event, `s3.get_object`, Pillow `thumbnail`, `s3.put_object` to `-out`, `dynamodb.put_item`. Raise on error for DLQ.
* `src/image-pipeline/requirements.txt` — `Pillow`, `boto3`.
* `terraform/lambda.tf` — `aws_lambda_function pillow-thumb` (python3.11, handler `handler.lambda_handler`, zip via `archive_file`), `aws_lambda_function_event_invoke_config` with `maximum_retry_attempts=2` + `destination_config on_failure -> DLQ`.
* `terraform/iam.tf` — role `pillow-thumb-role`: `s3:GetObject` (in), `s3:PutObject` (out), `dynamodb:PutItem` (thumbs), `sqs:SendMessage` (DLQ), `logs:*`. No `*`.
* `terraform/s3-notifications.tf` — `aws_s3_bucket_notification` source → Lambda + `aws_lambda_permission allow-s3`.
* `scripts/test-image-pipeline.sh` — generates test JPG (Pillow), `aws s3 cp` to `-in`, polls `-out` + `dynamodb get-item`, tests poison file → DLQ visible.

## Steps
1. Requires P3 Terraform base applied (buckets, table, DLQ exist).
2. Implement handler locally, unit-test Pillow resize without AWS.
3. `terraform apply` Lambda + trigger + IAM.
4. E2E: upload good image → thumb + DDB row; upload corrupt file → DLQ message.
5. Document cold-start + retry behavior.

## Verify commands
```bash
eval $(floci env)
./scripts/test-image-pipeline.sh sample.jpg
aws s3 ls s3://shopfast-images-out/thumbs/ --no-cli-pager
aws dynamodb scan --table-name ShopFastThumbs --no-cli-pager
aws sqs receive-message --queue-url $(terraform -chdir=terraform output -raw dlq_url) --no-cli-pager
```

## Gotchas (from repo history)
* DynamoDB `N` values are quoted strings; reserved word `status` needs alias.
* SQS `receive` hides, `delete` needs `ReceiptHandle`.
* Floci API-GW bug (S11) — invoke Lambda directly or via S3 trigger, don't rely on API GW.
* Pasted multi-commands corrupt with `[200~` — paste one at a time.

## Resume bullet
> Built event-driven S3→Lambda(Pillow)→DynamoDB thumbnail pipeline with SQS DLQ, verified end-to-end on local AWS emulator.
