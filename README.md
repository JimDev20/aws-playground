# AWS Learning — Session Log

Hands-on AWS practice running entirely against Floci (localhost:4566,
region us-east-1, account 000000000000) — no real AWS account needed.

## Environment setup (each new terminal)

```bash
floci start --persist .floci-data
eval $(floci env)
aws sts get-caller-identity
# Expected: "Account": "000000000000"
Sessions completed
Session 1 — S3 (done)
Cloud file cabinet: bucket = folder, object = file, key = path.
- mb make bucket → cp upload (incl. --recursive for folders) → ls
list → cp back = download → rm delete one file → rm --recursive
empty → rb delete bucket (only when empty).
- Gotchas: --recursive is a flag after cp (never s3 --recursive);
bucket-name typo = NoSuchBucket; destination prefix decides where files land.
Session 2 — DynamoDB (done)
Labeled spreadsheet: table = spreadsheet, item = row, key = row ID.
- create-table → put-item → get-item (needs full key) → scan (reads all)
→ delete-table.
- Types: S = string, N = number.
Session 3 — SQS + SNS (done)
SQS = mailbox (one-to-one, pull). SNS = megaphone (one-to-many, push).
- create-queue → send-message → receive-message → delete-message
→ create-topic → publish → delete-queue.
- Gotcha: delete by ReceiptHandle, never the body.
Sessions pending
- Session 4 — SSM + Secrets Manager
- Session 5 — IAM + STS
- Session 6 — EventBridge + CloudWatch
- Session 7 — CloudFormation
Quick reference
Service	Resource	Notes
S3	bucket	cloud cabinet, --recursive flag, rb needs empty
DynamoDB	table	key = row ID, PAY_PER_REQUEST
SQS	queue	pull-based, delete by ReceiptHandle
SNS	topic	push-based, publish → all subscribers

Copy the whole block into your `README.md`. Want it shorter (no Quick reference) or with your session notes added in?