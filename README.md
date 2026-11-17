# OCI for DBAs — companion code

Scripts, Terraform and checklists from the **OCI for DBAs** book series by Kiran Kumar Ale.

| Book | Chapter | Folder | What it is |
|------|---------|--------|------------|
| 1 — Migrating Oracle to OCI – Real Time | 4 — Land the Target First | [`book1-migration/ch04-landing-zone`](book1-migration/ch04-landing-zone) | A DBA landing zone in Terraform (Resource Manager ready) and `lz_check.py`, a read-only tenancy checker |

More chapters are added as the books are written.

## Use at your own risk

Everything here was built and run in a real OCI tenancy, but your tenancy is not mine.
Read the code, run it in a sandbox compartment first, and check the plan before you apply.
The checker only reads; the Terraform creates resources (most are free — see the chapter README).

## Want the full picture?

Oracle publishes a complete, CIS-aligned landing zone:
https://github.com/oci-landing-zones/terraform-oci-core-landingzone.
The landing zone here is deliberately smaller: only what a database migration needs.

## License

MIT — see [LICENSE](LICENSE).
