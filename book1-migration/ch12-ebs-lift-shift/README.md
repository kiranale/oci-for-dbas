# Chapter 12 — EBS 12.2 to OCI, lift and shift

| File | Where | What |
|------|-------|------|
| `ebs_outside_db_inventory.sql` | source DB, as APPS | Nodes, managers, mailer, directories, links, printers, URL-holding profiles |
| `ebs_outside_os_inventory.sh` | every EBS node | crontabs, NFS mounts, SSH/SFTP targets, ports, certificates |
| `after_move.sql` | target | FND_CONC_CLONE.SETUP_CLEAN reminder, mailer override, old-host checks |

Methods: Cloud Manager traditional (`perl EBSCloudBackup.pl`, then Advanced Provisioning),
Cloud Manager reduced downtime (standby; 19c RU 19.21+, TDE on all tablespaces), or manual
(Chapters 7-8 for the DB tier + Rapid Clone; MOS Doc ID 2800199.1). Start with MOS Doc ID 2517025.1.
