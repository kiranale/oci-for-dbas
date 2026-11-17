# EBS 12.2 across platforms: run order (fill in your rehearsal timings)

Read MOS Doc IDs 2674405.1 (DB tier, transportable tablespaces), 2048954.1 (application tier migration)
and 2552181.1 (EBS 12.2 with 19c interoperability) first. This sheet is an order, not a replacement for them.

| # | Step | Where | Rehearsal 1 | Rehearsal 2 |
|---|------|-------|-------------|-------------|
| 1 | ETCC clean; prerequisite patches; adop fs_clone; patching frozen | source | | |
| 2 | Transport check clean; custom binaries and host programs listed | source | | |
| 3 | Target CDB with TDE + EBS 19c patches; empty PDB slot | OCI | | |
| 4 | Level-0 backup + incremental roll-forwards (users working) | both | | |
| 5 | App tier staged on Linux: techstack, migration patch, relink (against a DB copy) | OCI | | |
| 6 | WINDOW: final incremental, tablespaces read only, full transportable export/import into PDB | both | | |
| 7 | DB tier: adbldxml.pl, AutoConfig on the PDB; UTL_FILE directories | OCI DB | | |
| 8 | App tier: context points at the new PDB service; AutoConfig; adop fs_clone | OCI app | | |
| 9 | Chapter 12 after-move list; every host program run once | OCI | | |
| 10 | Business smoke tests; go / no-go | — | | |
