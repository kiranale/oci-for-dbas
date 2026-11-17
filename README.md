# OCI for DBAs — companion code

Scripts, Terraform and checklists from the **OCI for DBAs** book series by Kiran Kumar Ale.

| Book | Chapter | Folder | What it is |
|------|---------|--------|------------|
| 1 — Migrating Oracle to OCI – Real Time | 4 — Land the Target First | [`book1-migration/ch04-landing-zone`](book1-migration/ch04-landing-zone) | A DBA landing zone in Terraform (Resource Manager ready) and `lz_check.py`, a read-only tenancy checker |
| 1 — Migrating Oracle to OCI – Real Time | 5 — Data Pump through Object Storage | [`book1-migration/ch05-datapump`](book1-migration/ch05-datapump) | Parfiles, multipart upload script, credential setup and validation SQL |
| 1 — Migrating Oracle to OCI – Real Time | 7 — Same platform, physical: RMAN and Data Guard | [`book1-migration/ch07-dataguard`](book1-migration/ch07-dataguard) | Redo-rate query, primary prep, restore-from-service RMAN, broker setup |
| 1 — Migrating Oracle to OCI – Real Time | 8 — Zero Downtime Migration, physical | [`book1-migration/ch08-zdm`](book1-migration/ch08-zdm) | Response file and eval/migrate commands with the pause before switchover |
| 1 — Migrating Oracle to OCI – Real Time | 9 — ZDM logical and OCI Database Migration | [`book1-migration/ch09-logical`](book1-migration/ch09-logical) | Replication checks, source prep, logical response file, sequence compare |
| 1 — Migrating Oracle to OCI – Real Time | 10 — Moving to Autonomous AI Database | [`book1-migration/ch10-autonomous`](book1-migration/ch10-autonomous) | CPAT command, server-dependency inventory, time zone check |
| 1 — Migrating Oracle to OCI – Real Time | 11 — Upgrade on the way: 19c to 26ai | [`book1-migration/ch11-upgrade`](book1-migration/ch11-upgrade) | AutoUpgrade configs (in place, non-CDB to PDB) and post-upgrade checks |
| 1 — Migrating Oracle to OCI – Real Time | 12 — EBS 12.2 to OCI, lift and shift | [`book1-migration/ch12-ebs-lift-shift`](book1-migration/ch12-ebs-lift-shift) | Outside-the-database inventory (SQL and OS) and after-move checks |
| 1 — Migrating Oracle to OCI – Real Time | 13 — EBS across platforms | [`book1-migration/ch13-ebs-cross-platform`](book1-migration/ch13-ebs-cross-platform) | Custom-binary finder, host-program list, run-order sheet |
| 1 — Migrating Oracle to OCI – Real Time | 14 — Everything around the database | [`book1-migration/ch14-around-the-db`](book1-migration/ch14-around-the-db) | Outbound/inbound connection inventory, logon audit, host inventory |
| 1 — Migrating Oracle to OCI – Real Time | 15 — The cutover runbook | [`book1-migration/ch15-cutover`](book1-migration/ch15-cutover) | Runbook and rollback templates, gate checks, job disable script |
| 1 — Migrating Oracle to OCI – Real Time | 16 — Day-one performance | [`book1-migration/ch16-day-one-performance`](book1-migration/ch16-day-one-performance) | Capture tuning set and baselines, parameter diff, first-hour checks, restore one plan |

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
