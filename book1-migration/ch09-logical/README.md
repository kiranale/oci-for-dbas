# Chapter 9 — ZDM logical, and OCI Database Migration

| File | Where | What |
|------|-------|------|
| `find_unreplicable.sql` | source | Objects GoldenGate can't capture; tables with no PK/UK |
| `prep_source.sql` | source | GoldenGate prerequisites and the GGADMIN user |
| `portal_logical.rsp` | ZDM host | ONLINE_LOGICAL to Autonomous via Object Storage and a GoldenGate hub |
| `compare_sequences.sql` | both | Sequences must be ahead on the target before go-live |

ZDM: `zdmcli migrate database -rsp portal_logical.rsp -eval`, then `-pauseafter ZDM_MONITOR_GG_LAG`,
and in the window `zdmcli resume job -jobid N`. DMS: Validate, Start, Resume in the console.
