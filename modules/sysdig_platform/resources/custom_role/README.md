# custom_role (Sysdig Platform)

Creates custom RBAC roles in Sysdig Platform.

## Inputs
- `roles` (list): objects like:
  ```hcl
  {
    name        = "readonly_threats"
    description = "Read-only access for Threats"
    permissions = ["policy-events.read", "metrics-data.read"]
  }
  ```

## Outputs
- `role_ids` (map): role name -> created ID. 

## Notes
- Permissions must match Sysdig RBAC permission strings. See Sysdig’s RBAC docs / role permissions reference.


RBAC concepts + permissions reference for Sysdig are here if you need to double-check strings. :contentReference[oaicite:2]{index=2}

---

## Wire it into `envs/dev`

In `envs/dev/main.tf`, add a minimal usage example and map the **platform** alias:

```hcl
module "platform_custom_roles" {
  source = "../../modules/sysdig_platform/resources/custom_role"

  providers = {
    sysdig.platform = sysdig.platform
  }

  roles = [
    {
      name        = "readonly_analyst"
      description = "Read-only access for analysts"
      permissions = ["read:users", "read:teams"]
    }
  ]
}

output "platform_custom_role_ids" {
  value = module.platform_custom_roles.role_ids
}
```

(If you prefer, move those example roles into dev.tfvars and expose a variable in envs/dev/variables.tf.)

---

## Quick test (dev env)

Ensure your AU1 URLs and the two API tokens are set (you already added the GitHub Action secrets).

Locally, from repo root:

```bash
make init ENV=dev
make plan ENV=dev
```

If the plan shows creation of one sysdig_custom_role, you’re golden. The resource name and its linkage to teams is acknowledged in the provider docs (secure team doc references sysdig_custom_role as the role source), so the module is aligned with the provider.
