# Project 1 Guide — Secure Two-Tier Web Architecture (IaC-Only)

Source: `plans/project1-two-tier-vpc.md`
Scope: **Terraform module + diagram + Checkov, labeled `real-AWS-ready, not Floci-deployed`.**

> Floci verdict (from `plans/README.md`): `describe-vpcs` = only `vpc-default`,
> `describe-db-instances` = `[]`. No real EC2/RDS data plane. A live Multi-AZ
> failover demo on Floci would be fake and a resume liability.

Architecture (real-AWS design):

```text
VPC 10.0.0.0/16, 2 AZs (us-east-1a/b)
 public  10.0.1.0/24 (a), 10.0.2.0/24 (b) -> IGW, app SG (80/443 in)
 private 10.0.11.0/24 (a), 10.0.12.0/24 (b) -> NAT GW, db SG (5432 in from app SG only)
 RDS postgres Multi-AZ, db.t3.micro, private subnets, no public access, encrypted
 EC2 app role (least privilege, SSM + CloudWatch only, no hardcoded creds)
```

Files this project will create (after P3):

- `terraform/modules/vpc/{main,variables,outputs}.tf`
- `terraform/modules/compute-db/{main,variables,outputs}.tf`
- `terraform/envs/local/main.tf` — plan-only, do NOT apply to Floci
- `docs/p1-architecture.md` — Mermaid diagram + failover + cost note

---

## 0. Environment commands (every terminal)

### 0.1 `floci start --persist .floci-data`

What it does:
Starts local AWS emulator on `http://localhost:4566` and persists state to
`.floci-data/` so S3/DDB/SQS survive Codespace restarts.

Why use it:
Eliminates billing risk while learning. Mirrors real AWS APIs for P2/P3
without creating real VPC/RDS charges.

Real-world scenario:
You are onboarding and want to test S3 upload code. Instead of using
`company-prod` bucket and risking a $200 mistake, you run Floci locally,
same as teams run LocalStack / moto / Docker Compose for dev.

When to use:
- Once per Codespace restart, before any `aws` / `terraform apply` for P2/P3.
- NOT needed for P1 validation — P1 is plan-only and must NOT target Floci.

Conflicts / problems:
1. `port 4566 already in use` -> `floci stop` or `docker ps | grep 4566`, then restart.
2. Forgot `--persist` -> all P3 buckets/tables vanish on restart. Fix: always use flag, keep `.floci-data/` git-ignored.
3. Trying to validate P1 Multi-AZ RDS against Floci -> fake success. Keep P1 in clean shell without Floci env.

### 0.2 `eval $(floci env)`

What it does:
Exports `AWS_ENDPOINT_URL=http://localhost:4566`, `AWS_ACCESS_KEY_ID=test`,
`AWS_SECRET_ACCESS_KEY=test`, `AWS_REGION=us-east-1` into current shell.

Why use it:
Isolates config per terminal, same pattern as `export AWS_PROFILE=prod` or
`eval $(aws sts assume-role ...)` in real jobs.

Real-world scenario:
Terminal A = `prod` (read-only audit), Terminal B = `dev` (sandbox). You
switch contexts without editing `~/.aws/credentials`. Prevents
"I thought I was in dev" outages.

When to use:
- Every new terminal before `aws sts get-caller-identity` for P2/P3 work.
- Do NOT run before P1 `terraform plan` if P3 `providers.tf` endpoint override leaks in. Use clean shell with only `AWS_REGION=us-east-1`.

Conflicts / problems:
1. Env leakage: `terraform plan` for P1 suddenly tries `localhost:4566`. Debug with `env | grep -i -E 'AWS|FLOCI'`, then `unset AWS_ENDPOINT_URL`.
2. Forgot to eval -> `Unable to locate credentials`. Re-run eval.
3. Paste corruption `[200~` noted in P2 gotchas — paste one line at a time.

### 0.3 `aws sts get-caller-identity`

What it does:
Returns `Account`, `UserId`, `Arn`. On Floci: `000000000000`.

Why use it:
Cheapest smoke test. Proves credentials + endpoint + region work before
expensive `terraform apply`.

Real-world scenario:
First step in any runbook / CI debug / incident: "who am I talking to?"
Prevents applying prod Terraform with dev credentials, or billing real AWS
when you meant local.

When to use:
- After eval, before apply (P3/P2). Skip for P1 plan-only (no AWS call needed).

Conflicts / problems:
1. Returns real 12-digit account when you expected `000000000000` -> STOP, you are hitting real AWS, will be billed.
2. `Could not connect to endpoint` -> Floci not started. Run 0.1 again.

---

## 1. `terraform -chdir=terraform/modules/vpc init -backend=false && terraform validate`

Break into two commands (chained with `&&` so validate only runs if init succeeds).

### 1a. `terraform -chdir=terraform/modules/vpc init -backend=false`

What each flag does:
- `-chdir=...`: run as if cd'd there. Avoids `cd` confusion in scripts/CI logs.
- `init`: downloads `hashicorp/aws ~> 5.0` provider, installs child modules.
- `-backend=false`: skip S3/DynamoDB remote-state configuration. Provider install only.

Why use it:
Required before `validate`. In CI with no creds/backend (P4 `terraform-validate` job),
this is the only safe init.

Real-world scenario:
Junior clones repo, opens PR touching VPC CIDR. CI runs `init -backend=false && validate`
in <30s without touching shared `terraform.tfstate` in S3 + lock table. No state
corruption, no NAT Gateway charge.

When to use:
- First clone + after any `versions.tf` / provider version change.
- Every CI run from scratch.

Conflicts / problems:
1. `terraform: command not found` (P3 blocker) -> install linux_amd64 zip to `~/.local/bin`, verify `terraform version`.
2. Plain `init` without `-backend=false` in dir inheriting P3 backend -> tries Floci S3 backend, hangs. Always use flag for P1 modules.
3. Lock mismatch `~>5.0` vs cached `4.x` -> `rm -rf .terraform/ .terraform.lock.hcl`, re-init.
4. No network in CI sandbox -> vendor providers or cache with `setup-terraform` action.

### 1b. `terraform validate`

What it does:
Static syntax + type check. Catches missing `variable`, wrong
`aws_db_instance` argument name, unclosed brace. No AWS API call.

Why use it:
Shift-left: 2-second feedback before costly `plan`. First gate in P4 CI.

Real-world scenario:
You rename `variable app_ami` to `variable ami_id` but forget one reference.
`validate` fails PR in seconds vs `apply` failing after 5 min and half-created
VPC + Elastic IP ($0.005/hr leak if not cleaned).

When to use:
- After every `.tf` edit, before `plan`, in pre-commit hook + CI.

Conflicts / problems:
1. Green validate, red plan — validate does NOT check AMI existence, AZ validity, or quota. Never treat as deploy-safe.
2. Validating `modules/vpc` alone misses cross-module wiring errors. Also validate `envs/local` which wires vpc + compute-db together.

---

## 2. `terraform -chdir=terraform/envs/local plan`

What it does:
Dry-run. Compares desired `.tf` vs state, prints `+ aws_vpc.main 10.0.0.0/16`,
`+ 2x public/private subnets`, `+ IGW`, `+ NAT GW (1x)`, `+ route tables`,
`+ app SG (80/443)`, `+ db SG (5432 from app SG)`, `+ db_subnet_group`,
`+ aws_db_instance multi_az=true`. Creates nothing.

Why use it:
Change-review artifact. Senior approves PR from this output. Interview walkthrough:
"Why 1 NAT not 2? Why db.t3.micro? Why app SG open but db SG closed?"

Real-world scenario:
Prod change: "Add second AZ + enable Multi-AZ RDS." `plan` shows
`~ multi_az false -> true (forces replacement? no, applies with reboot)`,
`+ aws_nat_gateway (cost +$32/mo)`. Team discusses downtime window, approves,
then `apply` in maintenance window. Without plan, surprise reboot during peak.

When to use:
- Every PR, before any `apply` to staging/prod. Save with `plan -out=tfplan`, apply exact file.
- For P1: plan-only, NEVER `apply` to Floci.

Conflicts / problems:
1. Accidental `apply` to Floci -> fake VPC/RDS entries, resume liability. Mitigation: header comment `# REAL-AWS-ONLY, DO NOT APPLY TO FLOCI`, no apply command in docs, separate `envs/local` state from P3 root.
2. Placeholder AMI `ami-12345` -> real AWS `InvalidAMIID.NotFound`. Fix: `variable app_ami { default = "ami-0c55b159cbfafe1f0" } # AL2023 us-east-1`, document per-region update.
3. 1x NAT = single point of failure + AZ data-transfer charge. Prod SLA needs 1 NAT/AZ ($64/mo). Document tradeoff in `docs/p1-architecture.md`.
4. State collision with P3 flat `terraform/*.tf` -> plan shows destroy of S3 buckets. Fix: keep P1 in `envs/local/` with own state, P3/P2 in root.
5. `plan` tries Floci endpoint due to leaked `AWS_ENDPOINT_URL` -> unset it for P1, use `AWS_REGION=us-east-1` only.

Cost note (us-east-1 approx, for `docs/p1-architecture.md`):
- 1x NAT GW ~$32/mo + data processing. 2x NAT ~$64/mo.
- RDS `db.t3.micro` Single-AZ ~$15/mo, Multi-AZ ~$30/mo (2x). Worth it for automatic failover (60-120s) vs manual restore (hours).
- IGW, subnets, route tables, SGs free. EC2 `t3.micro` free-tier eligible first year.

---

## 3. `checkov -d terraform/modules/vpc --framework terraform`
## 4. `checkov -d terraform/modules/compute-db --framework terraform`

What it does:
Static Application Security Testing (SAST) for IaC. Scans `.tf` for misconfigurations,
maps to `CKV_AWS_*` rules. `-d` = directory, `--framework terraform` = only Terraform.

Must-pass rules for P1 (`project1-two-tier-vpc.md:32-35`):
- DB SG ingress ONLY from app SG on 5432. No `cidr_blocks = ["0.0.0.0/0"]` to DB.
- RDS `storage_encrypted = true`, `publicly_accessible = false`, `deletion_protection = true`, `multi_az = true`.
- EC2 IAM role least privilege: `s3:Get*` only where needed, `ssm:*` + `logs:*` allowed, NO `iam:*`, NO `aws_iam_access_key` / hardcoded secrets.

Why use it:
CI gate in P4: `HIGH fails build`. In real company, blocks prod deploy, alerts Slack,
fails SOC2 audit if bypassed. Run locally to avoid red CI.

Real-world scenario:
Dev opens PR with `ingress { from_port=5432 to_port=5432 cidr_blocks=["0.0.0.0/0"] }`
for "quick testing." Checkov flags `CKV_AWS_260 HIGH`, CI blocks merge. Reviewer
asks to use `source_security_group_id`. Prevents public database breach (real
breach cost avg $4M+ per IBM report).

When to use:
- After `validate`, before `push`. In CI on every push/PR.

Conflicts / problems:
1. Noise from P3 dummy creds (`access_key=test`) -> scope to `modules/vpc` + `modules/compute-db` only, not repo root.
2. Version drift: new Checkov release adds rules, green build turns red. Pin version in `requirements.txt` + CI (`checkov==3.2.x`).
3. Skip abuse: `# checkov:skip=CKV_AWS_...` to silence. Allowed only with justification comment, NEVER for SG open / unencrypted RDS.
4. Heavy install (~300MB) slow in Codespace. Alternative: run in CI only, or `pipx install checkov`.
5. False sense of security: Checkov does NOT check runtime (e.g., weak DB password in Secrets Manager rotation, unpatched AMI). Pair with `tflint`, `cfn-lint`, Dependabot.

---

## Quick cheat sheet

```bash
# per terminal (P2/P3 only, NOT P1 plan)
floci start --persist .floci-data
eval $(floci env)
aws sts get-caller-identity

# P1 validate (clean shell, no Floci env)
terraform -chdir=terraform/modules/vpc init -backend=false && terraform validate
terraform -chdir=terraform/modules/compute-db init -backend=false && terraform validate
terraform -chdir=terraform/envs/local init -backend=false && terraform validate

# P1 plan (review only, do NOT apply)
terraform -chdir=terraform/envs/local plan

# P1 security (must pass, no HIGH)
checkov -d terraform/modules/vpc --framework terraform
checkov -d terraform/modules/compute-db --framework terraform
```

## Resume bullet (honest wording, from plan)

> Designed production-grade two-tier VPC (public/private, IGW/NAT, SG-bound RDS Multi-AZ) as reusable Terraform modules with SAST-clean plan, real-AWS-ready.
