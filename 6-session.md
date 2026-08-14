Uncle George Bakery — AWS Session Log (complete)
Env: Codespace aws-playground · floci http://localhost:4566 · region us-east-1 · account 000000000000
Bootstrap per shell: floci start --persist .floci-data → eval $(floci env) → aws sts get-caller-identity (→ Account 000000000000)
Session 1 — S3 (static site)
- Created bucket uncle-george-site; uploaded index.html, css/, js/, about/, cart/, contact/, product-details/, products/, data/products.json via cp --recursive (flag, not subcommand).
- Listed with ls / ls --recursive; downloaded data/products.json (reverse cp).
- rm a file, then rb failed with BucketNotEmpty → rm --recursive → rb succeeded.
- Gotchas: destination prefix decides file placement; empty the bucket before delete; NoSuchBucket = typo.
Session 2 — DynamoDB (products)
- Table products, key id (S), --billing-mode PAY_PER_REQUEST.
- put-item {"id":"french-baguette","name":"French Baguette","price":"45"}; get-item with full key; scan all; delete-table.
- Types: S=string, N=number. Key types: HASH = partition key.
Session 3 — SQS + SNS (orders + alerts)
- Queue orders created (noted QueueUrl); send-message order JSON; receive-message; delete-message by ReceiptHandle (not body).
- Topic order-alerts created (noted TopicArn); publish "New order placed!".
- delete-queue at session end → this is what bit us later.
Session 4 — SSM + Secrets Manager (config)
- SSM params: /site/tax-rate (String) and /site/email (SecureString, read with --with-decryption).
- Gotcha: updating existing param needs --overwrite.
- Secret prod/database-url = fake postgresql://admin:secret@localhost/db; get-secret-value decrypts.
Session 5 — IAM + STS (shop-bot)
- User shop-bot; group read-only-team; attached AmazonS3ReadOnlyAccess; added user to group.
- Role dev-role from trust-policy.json; sts assume-role returns Credentials; root get-caller-identity still 000000000000.
Session 6 — EventBridge + CloudWatch (metrics/logs/events)
1. Metrics write: put-metric-data UncleGeorge Visits=1, then Orders=1.
2. Metrics read: get-metric-statistics (window 2026-08-14T12:50:57Z→13:20:57Z, --period 60, Sum) → "Sum": 1.0.
3. Logs: group /uncle-george/orders + stream order-1.
4. Log event: put-log-events timestamp 1786713772918 (epoch ms), message "order placed" → got nextSequenceToken.
5. Read logs: get-log-events → event with ingestionTime (write-then-read proof).
6. Rule: events put-rule --name order-placed-rule --event-pattern '{"source":["uncle-george"]}' → RuleArn (verb is put, not create).
7. Target: sns list-topics → ARN arn:aws:sns:us-east-1:000000000000:order-alerts → events put-targets (Id=1, FailedEntryCount: 0).
8. Verify: list-targets-by-rule → 1 target, correct ARN.
9. Fire: put-events {"Source":"uncle-george","DetailType":"OrderPlaced","Detail":"{\"order\":\"french-baguette\"}"} → EventId 78cb0952-abc5-464d-867e-a194fd7d4bae.
Session 6 — RECOVERY (SQS→SNS proof)
Problem: get-queue-attributes → NonExistentQueue — the Session 3 delete-queue cleanup had removed orders; only notifications remained.
1. sqs list-queues → only notifications (confirmed loss).
2. sqs create-queue --queue-name orders → QueueUrl http://localhost:4566/000000000000/orders.
3. get-queue-attributes ... --attribute-names QueueArn → arn:aws:sqs:us-east-1:000000000000:orders.
4. sns subscribe --topic-arn ...:order-alerts --protocol sqs --notification-endpoint arn:aws:sqs:...:orders → SubscriptionArn (endpoint = ARN, not URL).
5. Re-fired put-events (same event) → new EventId accepted.
6. sqs receive-message → full chain proven in one envelope:
- inner Message: the EventBridge event (source:uncle-george, detail-type:OrderPlaced, detail:{order: french-baguette}, matching EventId)
- outer: SNS TopicArn ...:order-alerts, Subject: EventBridge
- delivered into orders queue.
Recovery lesson: rebuild the missing piece (create-queue) → re-link (subscribe) → re-fire → re-verify (receive-message).
Full capstone integration now live in floci: static site (S3) · product data (DynamoDB) · order mai