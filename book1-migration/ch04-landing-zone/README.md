# Chapter 4 — Land the Target First

A **DBA landing zone** for an Oracle database migration to OCI, plus a checker for any tenancy.

## What gets built (36 resources)

| Layer | Resources |
|-------|-----------|
| Compartments | `<prefix>-lz` with `network`, `database`, `app`, `security` inside |
| Identity | Groups `db-admins`, `network-admins`, `migration-ops`; one least-privilege policy |
| Network | Private VCN, 3 private subnets (db/app/mgmt), NAT gateway, Service Gateway, DRG, 2 NSGs, Bastion; default security list reduced to egress only |
| Security | Vault (DEFAULT) with a software AES-256 key for TDE; notification topic |
| Storage | Private buckets `<prefix>-migration` and `<prefix>-backups` |
| Cost | Monthly budget on the compartment, optional 80% email alert |

## Build it with Resource Manager (nothing to install)

1. Console: **☰ → Developer Services → Resource Manager → Stacks → Create stack**.
2. *My configuration* → *.Zip file* → upload a zip of the `terraform/` folder
   (or download `meridian-lz-terraform.zip` from this repository's Releases page).
3. Set the variables. Change at least:
   - `bastion_client_cidrs` — your office/VPN egress IP as `x.x.x.x/32` (default `0.0.0.0/0` is lab-only)
   - `onprem_cidr` — your data centre range
   - `budget_amount`, `budget_alert_email`
4. **Plan** — expect `Plan: 36 to add, 0 to change, 0 to destroy.`
5. **Apply** using that plan job.

Or with the Terraform CLI: set `tenancy_ocid` and `region` (plus your usual provider auth), then
`terraform init && terraform plan && terraform apply`.

## Check it

`checker/lz_check.py` reads a tenancy and never changes it. In **Cloud Shell** (Python and the OCI SDK are already there):

```bash
python3 lz_check.py --compartment meridian-lz   # the new landing zone
python3 lz_check.py                             # the whole tenancy
python3 lz_check.py --json > report.json
```

It flags public subnets, SSH/SQL*Net/TCPS/RDP open to `0.0.0.0/0` in security lists or NSGs,
VCNs with no NSGs or no Service Gateway, public buckets, Autonomous databases with no ACL or
private endpoint, a Bastion open to the world, no Vault, no budget, and workloads in the root
compartment. Exit code 1 if anything is FAIL.

Offline tests for the rules: `python3 -m pytest -q checker/`.

## Cost

Compartments, IAM, VCN, gateways, NSGs, Bastion service, budgets and a DEFAULT Vault with
software keys are free. You pay for what you later put inside.

## Cleaning up a sandbox

Run **Destroy** on the stack. The Vault is only *scheduled* for deletion (7–30 days), and the
compartment cannot be deleted until it is gone. For throwaway labs set `create_vault = false`.

## Official references

- OCI Core Landing Zone: https://github.com/oci-landing-zones/terraform-oci-core-landingzone
- Resource Manager: https://docs.oracle.com/iaas/Content/ResourceManager/home.htm
- Network security groups: https://docs.oracle.com/iaas/Content/Network/Concepts/networksecuritygroups.htm
- Bastion: https://docs.oracle.com/iaas/Content/Bastion/home.htm
- Vault: https://docs.oracle.com/iaas/Content/KeyManagement/home.htm
- CIS OCI Foundations Benchmark: https://www.cisecurity.org/benchmark/oracle_cloud
