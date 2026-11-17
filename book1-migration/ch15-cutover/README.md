# Chapter 15 — The cutover runbook

| File | What |
|------|------|
| `runbook_template.csv` | The night as a table: offset, step, owner, command, check, rehearsal and actual times |
| `rollback_template.csv` | The way back in the same format — rehearse it at T-14 |
| `gate_checks.sql` | Role, open mode, invalid objects, unusable indexes, services, TDE, clock, jobs, sessions, redo back |
| `disable_outside_jobs.sql` | Disables jobs that run outside the database or call UTL_SMTP/HTTP/FILE; spools the re-enable script |

The templates are for the Data Guard / ZDM physical move of Chapters 7 and 8. For other methods,
change the switchover rows and move the point of no return as the chapter describes.
