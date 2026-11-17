# Chapter 7 — Same platform, physical: RMAN and Data Guard

| File | Where | What |
|------|-------|------|
| `redo_rate.sql` | primary | Peak redo per hour (MB/s and Mbit/s) to compare with the measured link |
| `prep_primary.sql` | primary | Force logging, flashback, standby redo logs, wallet + master key (commented, review first) |
| `restore_standby.rman` | OCI host | `RESTORE STANDBY CONTROLFILE / DATABASE FROM SERVICE` with section size |
| `broker.dgmgrl` | primary | Broker configuration, ASYNC transport, lag check; switchover commented |

Hybrid TDE (19.16+): `tablespace_encryption=DECRYPT_ONLY` on-premises, `AUTO_ENABLE` in OCI.
Both sides need the same wallet and master key. Port 1521 must be open in BOTH directions.
