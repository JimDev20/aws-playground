# AWS Learning via Floci (Codespaces)

Hands-on AWS practice running entirely against Floci — no real AWS account
needed, no money spent.

## Environment

| Item | Value |
|------|-------|
| Platform | GitHub Codespace (2-core / 4 GB RAM, Ubuntu, bash) |
| Floci | v1.6.0 (72 services) |
| Endpoint | `http://localhost:4566` |
| Region | `us-east-1` |
| Account | `000000000000` |
| AWS CLI | v2 installed |
| floci-cli | v0.2.0 |

### Session Start (every new terminal)

```bash
floci start --persist .floci-data
eval $(floci env)
aws sts get-caller-identity
# Expected: "Account": "000000000000"
.floci-data is git-ignored. A fresh codespace starts empty — reopen the
OLD codespace to see previous state.
Progress — 11 Sessions Complete

Session Details
S1 — S3 (Cloud File Cabinet)
Bucket = folder, object = file, key = path.
aws s3 mb s3://my-bucket
aws s3 cp file.txt s3://my-bucket/
aws s3 ls s3://my-bucket/
aws s3 cp s3://my-bucket/file.txt ./downloaded.txt
aws s3 rm s3://my-bucket/file.txt
aws s3 rb s3://my-bucket
Gotchas:
- --recursive is a flag after cp (never s3 --recursive)
- Bucket name typo = NoSuchBucket
- Destination prefix decides where files land
- rb fails on non-empty buckets
S2 — DynamoDB (Labeled Spreadsheet)
Table = spreadsheet, item = row, key = row ID.
aws dynamodb create-table \
  --table-name MyTable \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

aws dynamodb put-item --table-name MyTable --item '{"id":{"S":"1"},"name":{"S":"Item One"}}'
aws dynamodb get-item --table-name MyTable --key '{"id":{"S":"1"}}'
aws dynamodb scan --table-name MyTable
aws dynamodb delete-table --table-name MyTable
Types: S = string, N = number.
S3 — SQS + SNS
SQS = mailbox (one-to-one, pull). SNS = megaphone (one-to-many, push).
# SQS
aws sqs create-queue --queue-name my-queue
aws sqs send-message --queue-url URL --message-body "Hello"
aws sqs receive-message --queue-url URL
aws sqs delete-message --queue-url URL --receipt-handle HANDLE
aws sqs delete-queue --queue-url URL

# SNS
aws sns create-topic --name my-topic
aws sns publish --topic-arn ARN --message "Hello subscribers"
Gotcha: Delete by ReceiptHandle, never the body.
S4 — SSM + Secrets Manager
SSM = notes folder; Secrets Manager = locked safe.
# SSM
aws ssm put-parameter --name my-param --value "secret123" --type SecureString
aws ssm get-parameter --name my-param --with-decryption

# Secrets Manager
aws secretsmanager create-secret --name my-secret --secret-string "password123"
aws secretsmanager get-secret-value --secret-id my-secret
Gotchas:
- --overwrite needed to update existing SSM params
- create-secret again = ResourceExistsException (use update-secret)
S5 — IAM + STS
User = badge; group = team with badges; policy = permission rules; role = hat worn temporarily.
aws iam create-user --user-name alice
aws iam create-group --group-name devs
aws iam attach-group-policy --group-name devs --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam add-user-to-group --user-name alice --group-name devs
aws iam create-role --role-name my-role --assume-role-policy-document file://trust-policy.json
aws sts assume-role --role-arn ARN --role-session-name session1
Gotchas:
- NoCredentials = eval $(floci env) missing in that shell
- assume-role returns credentials, not a session (must export to act as role)
- Same get-caller-identity shows root vs assumed-role
S6 — EventBridge + CloudWatch
CloudWatch = dashboards/logs; EventBridge = event switchboard.
# CloudWatch
aws cloudwatch put-metric-data --namespace MyApp --metric-name Requests --value 1
aws cloudwatch get-metric-statistics --namespace MyApp --metric-name Requests --start-time ISO --end-time ISO --period 300 --statistics Sum

# Logs
aws logs create-log-group --log-group-name /my/app
aws logs create-log-stream --log-group-name /my/app --log-stream-name stream1
aws logs put-log-events --log-group-name /my/app --log-stream-name stream1 --log-events timestamp=...,message=...

# EventBridge
aws events put-rule --name my-rule --event-pattern '{"source":["custom.app"]}'
aws events put-targets --rule my-rule --targets Id=1,Arn=SQS_ARN
aws events put-events --entries '[{"Source":"custom.app","DetailType":"Test","Detail":"{}"}]'
Gotchas:
- put-rule not create-rule
- get-metric-statistics needs Z-suffixed ISO times
- put-log-events needs epoch milliseconds + nextSequenceToken on repeat writes
S7 — CloudFormation
One file = many resources. create-stack = cook whole menu; update-stack = cook only the new dish.
aws cloudformation validate-template --template-body file://stack.json
aws cloudformation create-stack --stack-name my-stack --template-body file://stack.json
aws cloudformation describe-stacks --stack-name my-stack
aws cloudformation describe-stack-resources --stack-name my-stack
aws cloudformation update-stack --stack-name my-stack --template-body file://updated-stack.json
aws cloudformation delete-stack --stack-name my-stack
Gotchas:
- file:// prefix mandatory
- update-stack ≠ create-stack
- delete-stack fails on non-empty buckets
S8 — Filesystem + Packages
Filesystem = building layout; permissions = house key system; apt = package manager.
ls / → ls /etc → ls /var → ls /usr
ls -l
chmod +x script.sh
chmod 700 .env
sudo apt update && sudo apt install jq
jq '.' products.json
jq 'select(.cat=="Cakes")' products.json
Gotchas:
- apt update needs sudo
- nano creates files, chmod +x makes them scripts
- ./ prefix to run local scripts
S9 — Bash Scripting
Variables = labeled jars; conditionals = "is the bakery open?"; loops = going through a box of photos; functions = named recipes; exit codes = delivery receipt.
NAME="Uncle George"
echo "The $NAME costs $PRICE"

if [ -f "file" ]; then echo "exists"; fi
for img in path/*; do echo $img; done
log() { echo "[$(date)] $1"; }
command -v jq &> /dev/null
exit 0
Gotchas:
- No spaces around = in variables
- $ required to read variables
- fi closes if
- chmod +x needed after nano
S10 — Networking Fundamentals
OSI Model: L3 (IP routing), L4 (TCP/UDP transport), L7 (HTTP/DNS apps).
# Install tools
sudo apt-get update && sudo apt-get install -y iputils-ping dnsutils

# Layer 3 — connectivity
ping -c 4 localhost

# Layer 7 — DNS
dig localhost
nslookup localhost

# Layer 7 — HTTP
curl -v http://localhost:4566
curl -v http://localhost:4566/test-bucket
CIDR quick reference:
CIDR	IPs
/32	1
/24	256
/16	65,536
Gotchas:
- ping: command not found → sudo apt-get install -y iputils-ping
- dig: command not found → sudo apt-get install -y dnsutils
S11 — Lambda + API Gateway (Python + Node.js)
Lambda = vending machine (put code in, send request, get result). API Gateway = receptionist (forwards requests to Lambda).
Python
mkdir -p lambda-python
nano lambda-python/lambda_function.py
# (write handler, save: Ctrl+O, Enter, Ctrl+X)
cd lambda-python && zip function.zip lambda_function.py && cd ..

aws lambda create-function \
  --function-name my-python-function \
  --runtime python3.9 \
  --handler lambda_function.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://lambda-python/function.zip \
  --memory-size 256 \
  --timeout 10

echo '{"key":"value","name":"JimDev20"}' > payload.json
aws lambda invoke --function-name my-python-function --payload fileb://payload.json output.json
cat output.json
Node.js
mkdir -p lambda-nodejs
nano lambda-nodejs/index.js
# (write handler, save: Ctrl+O, Enter, Ctrl+X)
cd lambda-nodejs && zip function.zip index.js && cd ..

aws lambda create-function \
  --function-name my-nodejs-function \
  --runtime nodejs18.x \
  --handler index.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://lambda-nodejs/function.zip \
  --memory-size 256 \
  --timeout 10

echo '{"key":"value","name":"JimDev20"}' > payload-nodejs.json
aws lambda invoke --function-name my-nodejs-function --payload fileb://payload-nodejs.json output-nodejs.json
cat output-nodejs.json
API Gateway (Conceptual — Floci Limitation)
aws apigateway create-rest-api --name my-api --description "My API"
aws apigateway get-resources --rest-api-id YOUR_ID
aws apigateway create-resource --rest-api-id YOUR_ID --parent-id ROOT_ID --path-part hello
aws apigateway put-method --rest-api-id YOUR_ID --resource-id RES_ID --http-method GET --authorization-type NONE
aws apigateway put-integration --rest-api-id YOUR_ID --resource-id RES_ID --http-method GET \
  --type AWS_PROXY --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function/my-python-function/invocations
aws apigateway create-deployment --rest-api-id YOUR_ID --stage-name prod
aws apigateway create-stage --rest-api-id YOUR_ID --stage-name prod --deployment-id DEPLOY_ID
curl -v "http://localhost:4566/restapis/YOUR_ID/prod/_user_request_/hello?name=JimDev20"
Floci limitation: API Gateway → Lambda integration returns "Function not found: function". Direct Lambda invoke works perfectly.
Python vs Node.js
Aspect	Python
Handler	def handler(event, context):
Runtime	python3.9
String interp	f'Hello, {name}!'
JSON parse	json.loads(event['body'])
JSON stringify	json.dumps({...})
Gotchas:
- Unable to unmarshal input = invalid JSON in payload
- Use fileb:// prefix for ZIP files and payload
- create-stage needed explicitly (Floci fix)
Remaining Sessions (S12–S18)
#	Topic	Notes
S12	CAPSTONE Part 1	S3 + DynamoDB via CloudFormation recap
S13	CAPSTONE Part 2	End-to-end order flow: S3 + DynamoDB + SQS/SNS + CloudWatch
S14	Docker + Compose	Build Python app, port mapping, volumes, docker-compose.yml
S15	Terraform → Floci	HCL for S3 + DynamoDB, init/plan/apply/destroy
S16	GitHub Actions CI/CD	Push-triggered workflow against Floci
S17	Kubernetes LIGHT	Single pod + service (theory if RAM-limited)
S18	Prometheus + Grafana	Docker compose, fake exporter, CloudWatch review
Roadmap (Study Plan)
Phase 1 — Linux Basics & Scripting ✅
- File system hierarchy
- User management (chmod/chown)
- Package managers (apt/yum)
- Bash scripting (variables, loops, functions)
- Networking fundamentals (OSI, ping, dig, curl, CIDR)
Phase 2 — Cloud Engineering (In Progress)
- IAM, EC2, Auto Scaling, ELB
- S3, EBS, EFS
- VPC (subnets, NAT Gateway, Security Groups)
- Lambda, API Gateway
Phase 3 — DevOps Tooling (Future)
- Docker (Dockerfiles, Compose)
- Terraform (providers, state, modules)
- Kubernetes (pods, deployments, services)
- CI/CD (GitHub Actions/Jenkins)
Phase 4 — Monitoring & Logging (Future)
- CloudWatch
- Prometheus & Grafana
SAA Study Track (Theory Complement)
Target: AWS SAA-C03 (Cantrill course + KodeKloud labs).
Weeks	Topic
W1–2	Cantrill "IAM" + "S3"
W3–4	EC2, Auto Scaling, ELB
W5–6	VPC complete — subnets, IGW, NAT, SG, NACLs
W7	Architecture Deep Dives (whiteboard)
W8+	SAA practice exams (Jon Bonso)
Cert order: SAA-C03 first → then AWS Developer or CKA.
Gotchas — Master List
Issue	Solution
floci start fails	Check Docker is running
eval $(floci env) missing	No AWS credentials in shell
--recursive placement	Flag after cp, not after s3
Bucket name typo	NoSuchBucket — check spelling
--overwrite for SSM	Needed to update existing params
put-rule not create-rule	EventBridge naming
file:// prefix	Mandatory for CloudFormation templates
delete-stack fails	Non-empty bucket — delete objects first
chmod +x	Required after nano to make scripts executable
No spaces around =	Bash variable assignment
$ required to read variables	echo $NAME not echo NAME
fi closes if	done closes for/while
ping: command not found	sudo apt-get install -y iputils-ping
dig: command not found	sudo apt-get install -y dnsutils
Unable to unmarshal input	Invalid JSON — check payload file
Function not found: function	Floci bug — use direct Lambda invoke
Stage not found	Run create-stage explicitly
--zip-file error	Use fileb:// prefix
ResourceAlreadyExistsException	Use different name or update-secret
--no-paginate / --no-cli-pager	Prevents less pager opening
User Preferences
- Beginner — one command at a time
- Multi-line commands with \
- Explain every flag
- Analogies (bucket = folder, SQS = mailbox, SNS = megaphone)
- Wait for "done" before next step
- State expected output before running
Repository Structure
.
├── .gitignore          # .floci-data (do NOT commit state)
├── .floci-data/        # Floci state (git-ignored)
├── README.md           # This file
├── lambda-python/      # S11 Python Lambda
│   ├── lambda_function.py
│   ├── function.zip
│   ├── payload.json
│   └── output.json
├── lambda-nodejs/      # S11 Node.js Lambda
│   ├── index.js
│   ├── function.zip
│   ├── payload-nodejs.json
│   └── output-nodejs.json
└── [future sessions]
One-Command Commits
git add <files> && git commit -m "S10: Networking fundamentals" && git push
Cost & Cleanup
- Stop codespace when done
- Delete unused codespaces (15 GB storage quota)
- No credit card needed — Floci is free