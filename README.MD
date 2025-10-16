# OpenTofu + UpCloud starter (encrypted remote state, policy checks, Terraform verification)

This repo is a minimal, runnable starter for deploying an UpCloud VM with OpenTofu using:
- Encrypted remote state on UpCloud Object Storage (S3 compatible)
- Policy checks with Rego
- A migration step to local state so Terraform can verify “no changes”

> Use this as the base for CI, guardrails, and the follow-up article.

---

## Prerequisites

- OpenTofu v1.7 or newer  
- Terraform (latest) for the verification step  
- Conftest (for Rego policy checks)  
- An UpCloud account with:
  - Object Storage bucket + access key and secret
  - Subaccount with API access (username and password)

Helpful links:
- OpenTofu install: https://opentofu.org/docs/
- Terraform install: https://developer.hashicorp.com/terraform/install
- Conftest: https://www.conftest.dev/

---

## Quick start

### 1) Clone and prepare env

```bash
git clone <this-repo> opentofu-upcloud-starter
cd opentofu-upcloud-starter

cp .env.example .env
# edit .env and fill values, then:
source .env
```

### 2) Review backend and encryption

`backend.tf` points at UpCloud Object Storage and enables client-side encryption:

Update the bucket name and endpoint to match your Object Storage.

### 3) Init, plan, apply

```bash
tofu init -reconfigure
tofu plan -out=tofu.plan
tofu apply -auto-approve tofu.plan
```

Grab the IPv4 address from outputs.

```bash
tofu output server_ipv4
```

---

## Policy checks with Rego

This repo includes three simple rules in `policy/`:

- `max-vm-size.rego`  
- `required-labels.rego`  
- `zone-restriction.rego`

Run checks against the plan JSON:

```bash
tofu show -json tofu.plan > tofu.plan.json
conftest test --policy policy tofu.plan.json
```

You should see `FAIL` if a rule is violated.

> Tip: use `-var` overrides for quick tests, for example:
> `tofu plan -out=tofu.plan -var 'vm_type=8xCPU-16GB'`

---

## Destroy

```bash
# put the backend "s3" block back, then:
tofu init -migrate-state -reconfigure
tofu destroy
```
---

## File map

- `main.tf`  
  UpCloud server with labels, cloud-init, and a public NIC.

- `variables.tf`  
  Input variables, including validation for required labels.

- `outputs.tf`  
  Prints the server IPv4.

- `backend.tf`  
  Remote S3 backend pointing to UpCloud Object Storage and OpenTofu client-side encryption.

- `policy/*.rego`  
  Rego rules that validate plan size, labels, and zones.

- `.env.example`  
  Template for env variables. Copy to `.env` and `source .env`.

---

## Notes for CI and the advanced guide

- Keep the remote backend and encryption as defaults in CI.
- Run `tofu plan` and export JSON for policy checks:
  ```bash
  tofu plan -out=tofu.plan
  tofu show -json tofu.plan > tofu.plan.json
  conftest test --policy policy tofu.plan.json
  ```
