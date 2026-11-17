-- Run on the SOURCE: things that live outside the data and need a plan on Autonomous.
DEFINE owner = 'PORTAL'
PROMPT Directory objects (host paths do not exist on Autonomous):
SELECT directory_name, directory_path FROM dba_directories ORDER BY 1;
PROMPT Code that uses UTL_FILE, UTL_SMTP, UTL_HTTP, DBMS_PIPE or external procedures:
SELECT DISTINCT owner, name, type, REGEXP_SUBSTR(UPPER(text),'UTL_FILE|UTL_SMTP|UTL_HTTP|DBMS_PIPE|EXTPROC') used
FROM   dba_source
WHERE  owner = '&owner'
AND    REGEXP_LIKE(UPPER(text),'UTL_FILE|UTL_SMTP|UTL_HTTP|DBMS_PIPE|EXTPROC')
ORDER  BY 1,2;
PROMPT Database links:
SELECT owner, db_link, host FROM dba_db_links ORDER BY 1,2;
PROMPT External tables (file-based):
SELECT owner, table_name, default_directory_name FROM dba_external_tables WHERE owner = '&owner';
PROMPT Direct grants on SYS objects:
SELECT grantee, privilege, table_name FROM dba_tab_privs
WHERE  owner = 'SYS' AND grantee = '&owner' ORDER BY table_name;
PROMPT Scheduler / DBMS_JOB jobs:
SELECT owner, job_name, job_type, enabled FROM dba_scheduler_jobs WHERE owner = '&owner';
SELECT job, what, interval FROM dba_jobs WHERE schema_user = '&owner';
