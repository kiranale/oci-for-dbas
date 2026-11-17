# Chapter 16 — Day-one performance

| File | Where | What |
|------|-------|------|
| `01_capture_on_source.sql` | source, busy week + month-end | Tuning set of top SQL, disabled baselines, staging tables, statistics export |
| `02_param_diff.sql` | both | Parameters and CPU/memory, spooled for a diff |
| `03_first_hour.sql` | target, day one | Round-trip waits, machine metrics, top SQL against the source's plans |
| `04_restore_plan.sql` | target | Load the source's plan for one statement as a baseline and confirm it is used |

Licensing: AWR needs the Diagnostics Pack; check the Database Licensing Information User Manual for
SQL tuning sets and SQL plan management on your edition. Order on day one: wire, machine, parameters,
statistics, plans.
