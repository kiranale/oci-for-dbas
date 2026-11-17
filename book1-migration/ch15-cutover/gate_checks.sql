-- Chapter 15: gate checks. Run on the NEW primary right after the switchover (and on the old one before rollback).
SET LINESIZE 200 PAGESIZE 200
PROMPT == Role and open mode (expect PRIMARY / READ WRITE)
SELECT name, db_unique_name, database_role, open_mode, protection_mode FROM v$database;
SELECT name, open_mode, restricted FROM v$pdbs;

PROMPT == Invalid objects (compare with the source's count from before the window)
SELECT owner, object_type, COUNT(*) invalid FROM dba_objects
WHERE status = 'INVALID' GROUP BY owner, object_type ORDER BY 1, 2;

PROMPT == Unusable indexes
SELECT owner, index_name, status FROM dba_indexes WHERE status = 'UNUSABLE'
UNION ALL SELECT index_owner, index_name, status FROM dba_ind_partitions WHERE status = 'UNUSABLE';

PROMPT == Services running (the application services from Chapter 14 must be here)
SELECT name, network_name FROM v$active_services ORDER BY 1;

PROMPT == TDE wallet open
SELECT con_id, wrl_type, status, wallet_type FROM v$encryption_wallet;

PROMPT == Time zone and clock
SELECT SYSTIMESTAMP, DBTIMEZONE FROM dual;

PROMPT == Job queue and enabled jobs (expect 0 until step 1:10, then restored)
SHOW PARAMETER job_queue_processes
SELECT owner, job_name, state, next_run_date FROM dba_scheduler_jobs
WHERE enabled = 'TRUE' AND owner NOT IN (SELECT username FROM dba_users WHERE oracle_maintained='Y')
ORDER BY next_run_date;

PROMPT == User sessions (expect none before Gate 2)
SELECT username, machine, program, COUNT(*) FROM v$session
WHERE type = 'USER' AND username IS NOT NULL AND username NOT IN ('SYS','SYSTEM')
GROUP BY username, machine, program;

PROMPT == Redo shipping back to the old site (Data Guard): expect no gap
SELECT dest_id, status, error, gap_status FROM v$archive_dest_status WHERE status <> 'INACTIVE';
