# Chapter 11 — Upgrade on the way: 19c to 26ai

| File | What |
|------|------|
| `crm_26ai.cfg` | AutoUpgrade in place, guaranteed restore point, time zone upgrade |
| `quality_noncdb_to_pdb.cfg` | Non-CDB to PDB in a 26ai CDB, with a copy option as the fallback |
| `after_upgrade.sql` | COMPATIBLE, restore points and recovery-area use before sign-off |

Direct upgrade to 26ai is from 19c or 21c only. Always use the latest autoupgrade.jar.
On Base Database Service the console upgrade (Updates tab: Precheck, Apply update) is the simpler path.
