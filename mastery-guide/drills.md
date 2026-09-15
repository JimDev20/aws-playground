# Drills — 5-Minute Self-Tests (fail = redo week)

Run with Floci started + `eval $(floci env)`. No guide open.

## Linux / Bash
1. Create + chmod +x + run a script that takes `$1`, fails with exit 2 if missing.
2. Explain `set -e`, `> /dev/null`, heredoc `<< 'EOF'`, `$#`.
3. Find what owns port 4566 and why you must not kill it (`docker ps`).

## S3 / DynamoDB
1. `mb → cp → ls → rm → rb` without help. Trigger `BucketNotEmpty`, fix by emptying first.
2. Create table, `put-item` with `S` + `N` (N quoted), `get-item` by key, `scan`. Use alias for reserved word `status`.
3. Explain `Ref` vs `Fn::GetAtt` from `capstone1.json`.

## SQS / SNS / CloudWatch / Events
1. SQS: create → send → receive (copy ReceiptHandle) → delete-message → delete-queue. Explain hide vs delete.
2. SNS→SQS: publish, prove Body is envelope (`.Message` inside), fan-out to 2 queues.
3. CloudWatch: `put-metric-data` x2, `get-metric-statistics --statistics Sum --period 60`. Logs: group → stream → put → filter.
4. Events: `put-rule` (not create-rule) + `put-targets` + `describe-rule`.

## IAM / CFN
1. Create user + group + policy file + attach + role + `assume-role`. Read `Expiration`. Confirm identity via `get-caller-identity`.
2. `create-stack → describe-stacks (until CREATE_COMPLETE) → describe-stack-resources → update-stack → delete-stack`. Break JSON (missing comma) → `validate-template` fails → fix.

## Docker
1. Write 6-line Dockerfile deps-first (layer cache), `app.run(host="0.0.0.0")` why, `run -d --name -p 8080:5000 -v shopfast-data:/data`.
2. Prove volume magic: `rm -f` container, rerun same volume, data survives. `down` keeps vs `down -v` deletes.
3. Fix: `Dockerfile:N parse error` (Ctrl+K line), `port allocated`, stale image (forgot `--build`).

## Terraform (P3)
1. Explain every line of `providers.tf` endpoints + `skip_*` without reading.
2. `init → fmt → validate → plan -out=tfplan → apply` then verify with `aws` CLIs. Destroy + re-apply clean.

## CI / Security (P4)
1. `terraform fmt -check`, `tflint`, `checkov -d terraform/`, `cfn-lint`, `docker build` — all green.
2. Point to one HIGH Checkov would block (public DB `0.0.0.0/0`, unencrypted RDS, public S3) and the fix.

## Score
* 8/8 areas blind = mastered, advance.
* 5-7 = working junior, keep SAA side going.
* <5 = still copy-paste, redo `weeks.md` for that area before new project.
