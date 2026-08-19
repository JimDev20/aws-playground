# AWS Learning — Session Log

Hands-on AWS practice running entirely against Floci (localhost:4566,
region us-east-1, account 000000000000) — no real AWS account needed.

## Environment setup (each new terminal)

```bash
floci start --persist .floci-data
eval $(floci env)
aws sts get-caller-identity
# Expected: "Account": "000000000000"
```

## Sessions completed

### Session 1 — S3 (done)
Cloud file cabinet: bucket = folder, object = file, key = path.
- mb make bucket → cp upload (incl. --recursive for folders) → ls list → cp back = download → rm delete one file → rm --recursive empty → rb delete bucket (only when empty).
- Gotchas: --recursive is a flag after cp (never s3 --recursive); bucket-name typo = NoSuchBucket; destination prefix decides where files land.

### Session 2 — DynamoDB (done)
Labeled spreadsheet: table = spreadsheet, item = row, key = row ID.
- create-table → put-item → get-item (needs full key) → scan (reads all) → delete-table.
- Types: S = string, N = number.

### Session 3 — SQS + SNS (done)
SQS = mailbox (one-to-one, pull). SNS = megaphone (one-to-many, push).
- create-queue → send-message → receive-message → delete-message → create-topic → publish → delete-queue.
- Gotcha: delete by ReceiptHandle, never the body.

### Session 4 — SSM + Secrets Manager (done)
SSM = notes folder; Secrets Manager = locked safe.
- ssm put-parameter → get-parameter (SecureString needs --with-decryption) → secretsmanager create-secret → get-secret-value → update-secret.
- Gotchas: --overwrite needed to update a param; create-secret again = ResourceExistsException (use update-secret).

### Session 5 — IAM + STS (done)
User = badge; group = team with badges; policy = permission rules; role = hat worn temporarily. IAM = who can do what; STS = issues the hat.
- create-user → create-group → attach-group-policy → add-user-to-group → create-role (trust-policy.json) → assume-role → get-caller-identity proves identity swap.
- Gotchas: NoCredentials = eval $(floci env) missing in that shell; assume-role returns credentials, not a session (must export to act as role); same get-caller-identity shows root vs assumed-role.

### Session 6 — EventBridge + CloudWatch (done)
CloudWatch = dashboards/logs; EventBridge = event switchboard (rule = route, target = where it goes).
- put-metric-data (write) → get-metric-statistics (read; --period bucket + --statistics Sum) → create-log-group → create-log-stream → put-log-events (epoch-ms timestamp) → get-log-events.
- events put-rule (filter on source) → events put-targets (Id + Arn) → list-targets-by-rule (prove) → put-events (fire test event).
- SNS→SQS proof: sns subscribe (endpoint = queue ARN, not URL) → put-events → sqs receive-message shows SNS envelope wrapping the EventBridge event.
- Gotchas: put-rule not create-rule; get-metric-statistics needs Z-suffixed ISO times; put-log-events needs epoch milliseconds + nextSequenceToken on repeat writes; Session 3's delete-queue cleanup meant re-creating orders during recovery.

### Session 7 — CloudFormation (done)
One file = many resources. create-stack = cook whole menu; update-stack = cook only the new dish; delete-stack = close kitchen.
- stack.json: MyBucket (S3), MyTable (DynamoDB, key id, PAY_PER_REQUEST), MyQueue (SQS), MyTopic (SNS).
- validate-template → create-stack → describe-stacks (until CREATE_COMPLETE) → describe-stack-resources (prove) → edit file → update-stack (only the new dish; bucket/table/queue untouched = the IaC payoff) → delete-stack → list-stacks (DELETE_COMPLETE).
- Gotchas: file:// prefix mandatory; the template must exist on disk (file lived in jsonSample/ — cp it or use file://jsonSample/stack.json); cat is a read — save the file with cat > stack.json << 'EOF' ... EOF; update-stack ≠ create-stack; delete-stack fails on non-empty buckets (same rule as Session 1).

Session 8 — Filesystem + Users + Packages (done)
### Session 8 — Filesystem + Users + Packages (done)
Filesystem = building layout; /etc = settings drawer, /var = mailbox that fills up,
/usr = library shelf. Permissions = house key system (owner/group/others).
apt = package manager (refresh → install → remove).
- ls / → ls /etc → ls /var → ls /usr (orient on server)
- ls -l (see permissions: -rwxrwxrwx)
- chmod +x script.sh (make executable — 10x/day in DevOps)
- chmod 700 .env (protect secrets — owner-only)
- sudo apt update → sudo apt install jq → jq --version → sudo apt remove jq
- jq parsing: jq '.' (pretty-print), jq '.[].name' (extract fields),
  jq 'select(.cat=="Cakes")' (filter), jq 'group_by(.cat) | map({count: length})' (aggregate)
- Applied to: deploy.sh (copy Ecommerce/ to /var/www/Ecommerce/), products.json (32 bakery products)
- Gotchas: apt update needs sudo; nano creates files, chmod +x makes them scripts; ./script.sh runs from current directory
Session 9 — Bash Scripting (done)

### Session 9 — Bash Scripting (done)
Variables = labeled jars; conditionals = "is the bakery open?"; loops = going through a box of photos;
functions = named recipes; exit codes = delivery receipt (0=success, 1=failure).
- NAME="Uncle George" (assign) → echo $NAME (print) → echo "The $NAME costs $PRICE" (interpolation)
- if [ -f "file" ] (file exists?) → if [ -d "dir" ] (directory exists?)
- for img in path/*; do echo $img; done (loop through files)
- count=$((count+1)) (math in loops)
- log() { echo "[$(date)] $1"; } (functions with timestamps)
- command -v jq (check if tool installed) → &> /dev/null (silence output)
- exit 0 (success) → exit 1 (failure) → if [ $? -eq 0 ] (check result)
- Built 3 scripts: deploy-enhanced.sh (deploy with logging), resize-images.sh (batch image resize),
  check-products.sh (validate product data)
- Gotchas: no spaces around = in variables; $ is required to read variables; fi closes if; 
  chmod +x needed after nano; ./ prefix to run local scripts
What to Update in "Remaining sessions plan"
Change S8 and S9 from pending to done:
S8  — Filesystem + users + packages: ls hierarchy (/etc /var /usr),
      chmod/chown, umask, apt/yum (install/update/remove). No floci. (done)
S9  — Bash scripting: variables, if/for/while, functions, exit codes;
      scripts wrapping aws CLI. (done)