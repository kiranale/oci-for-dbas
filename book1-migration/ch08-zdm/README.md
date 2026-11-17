# Chapter 8 — Zero Downtime Migration, physical

| File | What |
|------|------|
| `crm_physical.rsp` | ONLINE_PHYSICAL, DIRECT (restore from service) to Base Database Service, fallback kept |
| `zdm_commands.sh` | `eval` (prechecks only) and `migrate` (pauses after `ZDM_CONFIGURE_DG_SRC`) |

Order: Chapter 7 prerequisites -> `./zdm_commands.sh eval` until clean -> `./zdm_commands.sh migrate`
-> watch lag -> in the window, stop the app and `zdmcli resume job -jobid N`.
Before ZDM_SWITCHOVER_SRC fails and you resume: read the phase log first (see the chapter).
