# Chapter 13 — EBS across platforms (AIX/Solaris/HP-UX to OCI Linux)

| File | Where | What |
|------|-------|------|
| `find_custom_binaries.sh` | AIX app tier | Compiled executables and libraries under custom tops (rebuild on Linux) |
| `host_programs.sql` | source, as APPS | Host and spawned concurrent programs to re-test on Linux |
| `run_order.md` | — | Run order with columns for two rehearsals' timings |

Certified procedures: MOS 2674405.1 (TTS, EBS 12.2 + DB 19c, target PDB), 2048954.1 (application tier
migration, EBS 12.2.3+), 2552181.1 (19c interoperability). Chapter 6 has the transportable mechanics.
