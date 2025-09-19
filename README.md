# Sysdig Terraform Provider Baseline

A clean, opinionated baseline for managing **Sysdig Platform / Secure / Monitor** with Terraform.  
This repo gives you:

- A **modular** layout that mirrors the Sysdig Provider docs (resources & data sources)
- **Environment isolation** (`envs/dev`, `envs/staging`, `envs/prod`)
- **Provider aliasing** for multiple Sysdig APIs (secure/monitor/platform)
- **Remote state** stored safely in **Terraform Cloud** (recommended) — with notes for **AWS S3 + DynamoDB**
- **GitHub Actions** for _plan on PR_ and _manual apply_ with locked state

Use this as a template to bootstrap your own Sysdig IaC.

---

## What this baseline can create (example)

Out of the box (see `envs/dev/dev.tfvars`), the sample config creates:

- **Platform → Custom Role**: `readonly_analyst`
- **Secure → Team**: `platform`
- **Monitor → Alert (event v2)**: “K8s: Failed to pull image”

You can expand safely by adding more modules and feeding inputs via `*.tfvars` per environment.

---

## Repository layout

```
.
├── modules/
│   ├── sysdig_platform/
│   │   └── resources/
│   │       └── sysdig_custom_role/
│   ├── sysdig_secure/
│   │   └── resources/
│   │       └── sysdig_secure_team/
│   └── sysdig_monitor/
│       └── resources/
│           └── sysdig_monitor_alert_v2_event/
├── envs/
│   ├── dev/
│   │   ├── backend.tf          # points to Terraform Cloud workspace
│   │   ├── main.tf             # wires modules + provider aliases
│   │   ├── providers.tf        # secure/monitor/platform aliases
│   │   ├── variables.tf        # input schema for this env
│   │   ├── dev.tfvars          # real inputs for dev
│   │   └── .terraform.lock.hcl # commit this (provider lockfile)
│   ├── staging/
│   └── prod/
├── .github/workflows/
│   ├── terraform-plan.yml      # plan on PRs (per env)
│   └── terraform-apply.yml     # manual apply (per env)
├── .gitignore
└── README.md                   # (this file)
```

> Subfolders (modules/envs) can have their own focused README files with usage and parameter docs. The root README links to them when you add them.

---

## Prerequisites

- **Terraform CLI** ≥ 1.6 (we pin 1.13.x in CI)
- **Sysdig** SaaS account with:
  - An **admin-capable** user (to create roles/teams/alerts)
  - **API tokens** (team-scoped!) for Secure and Monitor
- **GitHub** repository (to run the provided Actions)
- **Terraform Cloud** (free is OK) _or_ AWS (if you choose S3 state)

### Sysdig tokens (very important)

Sysdig tokens are **team-scoped**. Switch to a team where your user is **administrator**, then copy the API token. You’ll need:

- `SYSDIG_SECURE_API_TOKEN`
- `SYSDIG_MONITOR_API_TOKEN`

Add both into your shell when running locally, and into **GitHub Secrets** for CI (see below).

---

## How Terraform “state” works (in 60 seconds)

Your `.tf` files describe what you want; the **state** is Terraform’s memory of what already exists (resource IDs, outputs, dependencies).  
State enables:
- Correct **updates** (don’t create duplicates)
- Accurate **plans**
- Safe, **locked** changes (no two applies at once)

You can store state:
- **Locally** (simple, but not shareable and not locked)
- **Remotely** — recommended:
  - **Terraform Cloud (TFC)** — easiest, with built-in locking & history
  - **AWS S3 + DynamoDB** — common alternative for AWS-centric teams

This repo ships with **Terraform Cloud** configured by default; S3 instructions are below.

---

## Quick start (local)

1) **Clone** this repo (or use it as a template).

2) **Pick an environment** (start with `envs/dev/`).

3) **Set Sysdig tokens** in your shell:
```bash
export SYSDIG_SECURE_API_TOKEN="..."
export SYSDIG_MONITOR_API_TOKEN="..."
```

4) **Review inputs** in `envs/dev/dev.tfvars` (URLs, alert, team, role, etc.).  
   AU1 region example:
```hcl
sysdig_secure_url  = "https://app.au1.sysdig.com"
sysdig_monitor_url = "https://app.au1.sysdig.com"
```

5) **Init** and **plan**:
```bash
cd envs/dev
terraform init
terraform plan -var-file=dev.tfvars
# terraform apply -var-file=dev.tfvars   # when ready
```

> You should see 3 to add (role, team, alert). If you see a 401 on the role, read **“Platform provider alias tip”** below.

---

## Remote state options

### Option A — HashiCorp Terraform Cloud (recommended)

We use **TFC** with **Local (CLI-driven) Execution**:
- Runs happen on your laptop / GitHub Actions
- State & locks live in TFC
- Keeps your relative module paths working

#### 1) Create project & workspaces (once)
In TFC:
- Project: **Sysdig Provider**
- Workspaces (one per env):  
  `sysdig-provider-dev`, `sysdig-provider-staging`, `sysdig-provider-prod`
- Set each workspace to **Local (CLI-driven)** execution

#### 2) Wire each env to its TFC workspace
Example `envs/dev/backend.tf`:
```hcl
terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "YOUR_ORG"
    workspaces {
      name    = "sysdig-provider-dev"
      project = "Sysdig Provider"
    }
  }
}
```

#### 3) Authenticate
- Locally: `terraform login`
- In CI: use **GitHub Secret** `TF_API_TOKEN` and our workflow sets CLI creds automatically

> If you prefer **Remote** execution, publish modules via Git (e.g., `source = "github.com/<org>/<repo>//modules/..."`) so the remote runner can fetch them (relative `../../` paths won’t work remotely).

### Option B — AWS S3 + DynamoDB (alternative)

Create:
```bash
AWS_REGION=ap-southeast-2
BUCKET=my-sysdig-tfstate
TABLE=my-sysdig-tflock

aws s3api create-bucket   --bucket "$BUCKET"   --region "$AWS_REGION"   --create-bucket-configuration LocationConstraint="$AWS_REGION"

aws dynamodb create-table   --table-name "$TABLE"   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --billing-mode PAY_PER_REQUEST   --region "$AWS_REGION"
```

Per env `backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-sysdig-tfstate"
    key            = "sysdig/dev/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "my-sysdig-tflock"
    encrypt        = true
  }
}
```

Grant the CI IAM user/role S3 (bucket/key) + DynamoDB (table) permissions.

---

## Provider aliases & regions

We split providers to mirror Sysdig product areas:

```hcl
# envs/<env>/providers.tf

# Secure API
provider "sysdig" {
  alias             = "secure"
  sysdig_secure_url = var.sysdig_secure_url
  # Token from env: SYSDIG_SECURE_API_TOKEN
}

# Monitor API
provider "sysdig" {
  alias              = "monitor"
  sysdig_monitor_url = var.sysdig_monitor_url
  # Token from env: SYSDIG_MONITOR_API_TOKEN
}

# Platform (roles/users/org-level)
# Tip: If role creation 401s, switch this alias to use Secure URL instead.
provider "sysdig" {
  alias              = "platform"
  sysdig_monitor_url = var.sysdig_monitor_url
  # or: sysdig_secure_url = var.sysdig_secure_url
  # Token from env (Monitor or Secure) depending on which side your tenant authorizes for roles
}
```

**Important:** Sysdig tokens are **team-scoped**. Acquire tokens from a team where your user is **administrator**, or the API will reject role/team operations.

---

## Environments & variables

Each env has:
- `variables.tf` — input schema
- `*.tfvars` — your real inputs

Example snippet (`envs/dev/dev.tfvars`):

```hcl
# URLs (AU1 example)
sysdig_secure_url  = "https://app.au1.sysdig.com"
sysdig_monitor_url = "https://app.au1.sysdig.com"

platform_roles = [
  {
    name                = "readonly_analyst"
    description         = "Read-only access for analysts"
    monitor_permissions = ["kubernetes-api-commands.read"]
    secure_permissions  = ["scanning.read"]
  }
]

secure_teams = [
  {
    name        = "platform"
    description = "Platform engineering team"
  }
]

monitor_event_alerts = [
  {
    name          = "K8s: Failed to pull image"
    description   = "Raise when image pull failures occur"
    severity      = "Medium"          # High | Medium | Low | Info
    filter        = "kubernetes.event.reason = 'Failed to pull image'"
    operator      = ">"
    threshold     = 0
    range_seconds = 600
    scope = [
      {
        label    = "kube_cluster_name"
        operator = "in"
        values   = ["YOUR-CLUSTER"]
      }
    ]
  }
]
```

---

## Running locally

```bash
# dev
cd envs/dev

# 1) formatting (CI enforces this)
terraform fmt -recursive

# 2) init (talks to TFC or S3 backend)
terraform init

# 3) plan
terraform plan -var-file=dev.tfvars

# 4) apply (when ready)
terraform apply -var-file=dev.tfvars
```

> Commit the generated **`.terraform.lock.hcl`** in each env. Do **not** commit `terraform.tfstate` or `.terraform/`.

---

## CI/CD with GitHub Actions

This repo includes two workflows:

- **Plan on PR**: `.github/workflows/terraform-plan.yml`  
  Runs `init/validate/plan` for the envs affected by the PR.
- **Manual apply**: `.github/workflows/terraform-apply.yml`  
  Launch from the **Actions** tab, choose `dev|staging|prod`.

### Required GitHub Secrets

- `TF_API_TOKEN` — a Terraform Cloud token (on the Free plan, an **Owners** team token works)
- `SYSDIG_SECURE_API_TOKEN`
- `SYSDIG_MONITOR_API_TOKEN`

> The workflows inject the TFC token into the Terraform CLI (`setup-terraform`), and the Sysdig tokens via environment variables.

### Typical flow

1) Open a PR (edits under `envs/**` or `modules/**`).  
2) The **plan** workflow runs and must pass.
3) Merge the PR.
4) **Actions → terraform-apply → Run workflow** → choose env (start with `dev`).

> You can also run the apply **from the PR branch** before merge by selecting that branch in the “Use workflow from” dropdown.

### Safe-ops tips

- Make the **plan** check **required** on `main`.
- Add a GitHub **Environment** named `prod` with required reviewers; point the apply job at it so prod applies need approval.

---

## Troubleshooting

- **`terraform fmt -check` fails (exit code 3)**  
  CI lists unformatted files (e.g., `providers.tf`). Run `terraform fmt -recursive` locally and push.

- **`Unreadable module directory` when using TFC**  
  If your workspace is set to **Remote** execution, it can’t see `../../modules/...`.  
  Switch to **Local (CLI-driven)** execution (recommended), or reference modules via Git URLs:
  ```
  source = "github.com/<org>/<repo>//modules/sysdig_platform/resources/sysdig_custom_role?ref=main"
  ```

- **401 Unauthorized creating roles**  
  - Confirm you can create a role in the **Sysdig UI** (Settings → Roles).  
  - Ensure your token is copied while switched to an **admin** team (tokens are team-scoped).  
  - Flip the **platform** provider alias to authenticate via **Monitor** _or_ **Secure** — tenants differ on which side authorizes the Roles API.

- **“Value for undeclared variable” warnings**  
  Remove unused keys from `*.tfvars` or declare them in `variables.tf` with `default = null`.

- **Provider alias errors**  
  In module calls, the providers map **key** is the module’s provider name (`sysdig`), the **value** is your aliased instance:
  ```hcl
  providers = { sysdig = sysdig.platform }
  ```

- **Alert schema gotchas**  
  The event v2 resource uses **`scope`** (singular) and **`notification_channels`** as **blocks**. Don’t use `scopes` or assign lists directly.

---

## Conventions & housekeeping

- **Commit**: `.terraform.lock.hcl` (per env), workflows, modules, and `*.tfvars.example` (but **not** secrets)
- **Ignore**: `.terraform/`, `*.tfstate*`, `.terraform.tfstate.lock.info`, `crash.log*`
- **Formatting**: `terraform fmt -recursive` (CI enforces it)
- **Provider pinning**: managed by lockfiles; CI uses Terraform 1.13.x

---

## Where to look next

- `modules/sysdig_platform/resources/sysdig_custom_role/` — add more role patterns
- `modules/sysdig_secure/resources/sysdig_secure_team/` — team options
- `modules/sysdig_monitor/resources/sysdig_monitor_alert_v2_event/` — more alerts

> Add README files inside each module directory describing inputs/outputs and examples. Link them from here (e.g., “See `modules/sysdig_monitor/.../README.md` for alert fields and examples”).

---

## FAQ

**Q: Can I keep local state?**  
For experiments, yes. For teams/CI, use **TFC** or **S3 + DynamoDB** to avoid conflicts and state loss.

**Q: Can I run apply from a PR branch?**  
Yes. Use the “Use workflow from” branch selector when running the `terraform-apply` workflow.

**Q: How do I add a new environment?**  
Copy an existing `envs/<env>` folder, adjust `backend.tf` (workspace or S3 key), create `<env>.tfvars`, and run `terraform init`.

---

If you build on this baseline, consider opening issues/PRs with improvements so others can benefit. Happy shipping! 🚀
