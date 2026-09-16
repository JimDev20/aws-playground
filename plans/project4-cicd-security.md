# Project 4 — Automated CI/CD Deployment Pipeline & Security Scanning (Validate-only in CI)

## Objective
Bridge delivery + reliability: PRs gated by lint + SAST, frontend synced to S3 behind CloudFront, invalidations on deploy.

## Constraint (verified)
GitHub-hosted runners cannot reach `http://localhost:4566`. `aws cloudfront list-distributions` on Floci returns empty stub. So: **CI = validate-only; deploy = local script**.

## Architecture
```
push/PR to main
 -> GitHub Actions (ubuntu-latest, no AWS creds needed for validate)
    - terraform fmt -check, init -backend=false, validate
    - tflint, checkov (HIGH fails build), cfn-lint capstone1.json, flake8/pytest, docker build
Local only: ./scripts/deploy-static.sh -> aws s3 sync -> cloudfront create-invalidation (best-effort)
Terraform defines: S3 shopfast-site (private + OAC) + aws_cloudfront_distribution (plan + checkov only)
```

## Files to create
* `.github/workflows/ci.yml` — triggers `push/PR to main`; jobs: `terraform-validate` (setup-terraform, tflint, checkov), `python-lint-test`, `docker-build` (`docker build .`), `cfn-lint`.
* `terraform/s3-site.tf` — `shopfast-site` bucket, `block_public_acls=true`, no public policy.
* `terraform/cloudfront.tf` — OAC + distribution (TTL, HTTPS-only, custom 404). Documented as `real-AWS-ready`.
* `frontend/index.html` (+ `app.js`/`styles.css` minimal) — ShopFast static build artifact.
* `scripts/deploy-static.sh` — `aws s3 sync ./frontend s3://shopfast-site --delete`, then `aws cloudfront create-invalidation --distribution-id $DIST_ID --paths '/*'` with `|| echo WARN: Floci CF stub`.

## Steps
1. Requires P3 base (Terraform exists to lint/scan).
2. Add workflow + S3/CF Terraform + `frontend/`.
3. Push to branch → open PR → CI must pass (fix Checkov HIGH: no `0.0.0.0/0`, no public S3, encrypted).
4. Local: `eval $(floci env)` + `./scripts/deploy-static.sh` → `aws s3 ls s3://shopfast-site`.
5. Optional later: `act -j terraform-validate` for local runner parity; self-hosted runner only if requested.

## Verify commands
```bash
terraform fmt -check -recursive
tflint --init && tflint
checkov -d terraform/ --framework terraform
cfn-lint capstone1.json
docker build -t shopfast-web .
eval $(floci env) && ./scripts/deploy-static.sh
```

## Resume bullet
> Hardened CI/CD with GitHub Actions + TFLint/Checkov gating Terraform, S3+CloudFront static delivery with automated invalidations.
