# AWS Learning via Floci (Codespaces)

Hands-on AWS practice against Floci — no real AWS account, no cost.

## Environment

| Item | Value |
|------|-------|
| Platform | GitHub Codespace (2-core / 4 GB, Ubuntu) |
| Floci | v1.6.0 (72 services), runs as its own Docker container |
| Endpoint / Region / Account | `http://localhost:4566` / `us-east-1` / `000000000000` |
| Tools | AWS CLI v2 · floci-cli v0.2.0 · Docker native |

### Session Start (every terminal)

```bash
floci start --persist .floci-data   # "already running" = fine
eval $(floci env)
aws sts get-caller-identity         # expect Account 000000000000
```

`.floci-data` is git-ignored; reopen the OLD codespace to keep state.

## Progress — 14 Sessions Complete

| # | Session | Key takeaways |
|---|---------|---------------|
| S1 | S3 | mb/cp/ls/rm/rb; rb fails on non-empty bucket |
| S2 | DynamoDB | typed items (`S`, `N` = quoted string); HASH key = locker number |
| S3 | SQS + SNS | mailbox vs megaphone; delete needs ReceiptHandle |
| S4 | SSM + Secrets | `--overwrite` for existing params; ResourceExists → update-secret |
| S5 | IAM + STS | roles = hats you wear temporarily; assume-role exports credentials |
| S6 | EventBridge + CloudWatch | `put-rule` NOT create-rule; Z-suffixed ISO times |
| S7 | CloudFormation | `file://` mandatory; update-stack ≠ create-stack |
| S8 | Filesystem + apt | sudo for apt; chmod +x after nano |
| S9 | Bash scripting | no spaces around `=`; set -e; heredocs; exit codes |
| S10 | Networking | OSI L3/L4/L7; ping/dig/curl; CIDR basics |
| S11 | Lambda + API GW | zip + fileb:// invoke; floci API-GW bug → direct invoke |

### S12 — CAPSTONE pt1 (CFN) ✅
Wrote `capstone1.json`: S3 + DynamoDB as one stack; proved resources are REAL;
update-stack kept data alive; teardown = empty bucket first.

### S13 — CAPSTONE pt2: Order Pipeline ✅
Flow: order.json → S3 → DynamoDB (RECEIVED→PROCESSED) → SNS publish → SQS via
subscription ONLY (**fan-out proven**, Body is an envelope) → CloudWatch metric.
Live debug: "Topic does not exist" → list-topics → recreate (debug loop).
Automation: `process-order.sh` runs the whole flow in one command.
Guide: `session-13-recap.md`

### S14 — Docker + Compose ✅
6-line Dockerfile (deps before code = layer caching); flask app needs
`host="0.0.0.0"`; run with `-d --name -p 8080:5000 -v shopfast-data:/data`;
**volume magic**: killed container, data survived (containers=cattle,
volumes=farm). Compose replaces all flags; `down` keeps data vs `down -v`
deletes. Floci itself IS a container.
Guide: `session-14-recap.md`

## Remaining Sessions

| # | Topic |
|---|-------|
| S15 | Terraform → floci (HCL, init/plan/apply/destroy) |
| S16 | GitHub Actions CI/CD vs floci |
| S17 | Kubernetes LIGHT (theory if RAM-tight) |
| S18 | Prometheus + Grafana + CloudWatch recap |

Out of scope: deep EC2/VPC/ELB, full K8s clusters (KodeKloud/Cantrill labs).

## Roadmap

Phase 1 Linux+Networking ✅ · Phase 2 AWS SAA (in progress) · Phase 3 DevOps —
Docker ✅, Terraform/K8s/CI-CD next · Phase 4 Prometheus+Grafana (S18).

## Gotchas — Master List

| Issue | Fix |
|-------|-----|
| NoCredentials | rerun `eval $(floci env)` per terminal |
| Pager stuck at ":" | q exits; use --no-cli-pager |
| "does not exist" AFTER delete | that IS success |
| NotFound creating/attaching | parent missing → list-* first (dependency order) |
| DynamoDB reserved word `status` | alias via --expression-attribute-names |
| SQS receive hides, doesn't delete | delete needs ReceiptHandle |
| Pasted multi-command corruption [200~ | paste ONE command at a time |
| Flask unreachable from browser | host="0.0.0.0" missing |
| Code changes ignored | forgot --build / docker build |
| port allocated / name in use | docker rm -f owner first |
| Dockerfile parse error | stray text; error names exact line; nano Ctrl+K |
| Data vanished | you ran down -v; check Mounts if unsure |

## User Preferences

One command at a time ("done" between); `\` multi-line; every flag explained;
analogies always; expected output BEFORE running; full guides = problem story +
flags + expected outputs + gotchas/skills (see session-12/13/14-recap.md).
