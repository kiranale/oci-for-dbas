-- Chapter 14: what points out of this database. Run as a DBA on the SOURCE, early and again a week before cutover.
-- Change the domain pattern (\.corp\b) to your own internal suffix.
SET LINESIZE 220 PAGESIZE 200
COLUMN host FORMAT A60
COLUMN directory_path FORMAT A70
COLUMN job_action FORMAT A60
COLUMN text FORMAT A100

PROMPT == Outbound database links
SELECT owner, db_link, username, host FROM dba_db_links ORDER BY 1, 2;

PROMPT == Directory objects (paths that must exist on the new host)
SELECT directory_name, directory_path FROM dba_directories
WHERE  origin_con_id = SYS_CONTEXT('USERENV','CON_ID') ORDER BY 1;

PROMPT == Scheduler jobs that run outside the database
SELECT owner, job_name, job_type, job_action, credential_name, destination, enabled
FROM   dba_scheduler_jobs
WHERE  job_type IN ('EXECUTABLE','EXTERNAL_SCRIPT') OR destination IS NOT NULL;

PROMPT == Scheduler credentials (passwords are NOT exported: recreate each)
SELECT owner, credential_name, username FROM dba_scheduler_credentials ORDER BY 1, 2;

PROMPT == Network ACLs
SELECT host, lower_port, upper_port, principal, privilege FROM dba_host_aces ORDER BY 1;

PROMPT == Code that names hosts, addresses, mail or URLs
SELECT owner, name, type, line, TRIM(text) text FROM dba_source
WHERE  REGEXP_LIKE(text, '([0-9]{1,3}\.){3}[0-9]{1,3}|smtp|https?://|\.corp\b', 'i')
AND    owner NOT IN (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
ORDER  BY 1, 2, 4;

PROMPT == Enabled jobs, next run, and the scheduler default time zone
SELECT owner, job_name, state, next_run_date, repeat_interval
FROM   dba_scheduler_jobs WHERE enabled = 'TRUE' ORDER BY next_run_date;
SET SERVEROUTPUT ON
DECLARE tz VARCHAR2(64);
BEGIN DBMS_SCHEDULER.GET_SCHEDULER_ATTRIBUTE('default_timezone', tz);
      DBMS_OUTPUT.PUT_LINE('scheduler default_timezone: ' || tz); END;
/
SELECT SYSTIMESTAMP, DBTIMEZONE FROM dual;
SHOW PARAMETER job_queue_processes
SHOW PARAMETER utl_file_dir
