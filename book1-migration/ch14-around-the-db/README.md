# Chapter 14 — Everything around the database

| File | Where | What |
|------|-------|------|
| `around_the_db.sql` | source, as DBA | DB links, directories, external jobs, credentials, ACLs, hosts in code, job time zone |
| `inbound_links_other_side.sql` | every OTHER database | Finds links pointing at your source (send to their DBAs) |
| `logon_audit.sql` | source | Unified-audit logon policy to see who connects, over a month-end |
| `host_inventory.sh` | source host | cron, profiles, mounts, wallets, oratab, time zone — one file per host |

Run the inventory twice: at assessment and a week before cutover. Everything here only reads,
except `logon_audit.sql`, which creates an audit policy (drop it when done).
