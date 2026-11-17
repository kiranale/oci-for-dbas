# Chapter 10 — Moving to Autonomous AI Database

| File | Where | What |
|------|-------|------|
| `cpat.sql` | source, in SQLcl | Cloud Premigration Advisor for Autonomous (`migrateadvisor advise`) |
| `server_dependencies.sql` | source | Directories, UTL_FILE/SMTP/HTTP use, DB links, external tables, SYS grants, jobs |
| `timezone_check.sql` | target | SYSDATE is UTC on Autonomous unless SYSDATE_AT_DBTIMEZONE=TRUE |

After the move, `python3 ../ch04-landing-zone/checker/lz_check.py --compartment <yours>` should report
no Autonomous database open to any IP.
