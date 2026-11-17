-- Chapter 15, step 0:15: disable jobs that touch the outside world. Review the list first; it SPOOLS the re-enable script.
SET SERVEROUTPUT ON LINESIZE 200
SPOOL reenable_jobs.sql
BEGIN
  FOR j IN (SELECT DISTINCT owner, job_name FROM (
              SELECT owner, job_name FROM dba_scheduler_jobs
              WHERE enabled='TRUE' AND (job_type IN ('EXECUTABLE','EXTERNAL_SCRIPT') OR destination IS NOT NULL)
              UNION
              SELECT j.owner, j.job_name FROM dba_scheduler_jobs j
              JOIN dba_dependencies d ON d.owner = j.owner
               AND UPPER(j.job_action) LIKE '%'||d.name||'%'
              WHERE j.enabled='TRUE' AND d.referenced_name IN ('UTL_SMTP','UTL_HTTP','UTL_FILE','UTL_MAIL','UTL_TCP')
            ) WHERE owner NOT IN (SELECT username FROM dba_users WHERE oracle_maintained='Y')) LOOP
    DBMS_OUTPUT.PUT_LINE('EXEC DBMS_SCHEDULER.ENABLE('''||j.owner||'.'||j.job_name||''')');
    DBMS_SCHEDULER.DISABLE(j.owner||'.'||j.job_name, force => TRUE);
  END LOOP;
END;
/
SPOOL OFF
-- The match on job_action is a heuristic: read the spooled list and add any job it missed.
