-- Day one, on the TARGET. 1) wire for one session  2) machine  3) top SQL to compare with the tuning set
SET LINESIZE 200 PAGESIZE 100
PROMPT == Waits for one slow session (:sid). Many short 'SQL*Net message from client' = round trips
SELECT event, total_waits, ROUND(time_waited_micro/1e6,1) secs,
       ROUND(time_waited_micro/NULLIF(total_waits,0)/1000,2) avg_ms
FROM   v$session_event WHERE sid = :sid ORDER BY time_waited_micro DESC;

PROMPT == Machine, last hour
SELECT metric_name, ROUND(AVG(value),1) avg, ROUND(MAX(value),1) peak
FROM   v$sysmetric_history
WHERE  metric_name IN ('Host CPU Utilization (%)','Physical Read Total IO Requests Per Sec',
                       'Physical Read Total Bytes Per Sec','Average Synchronous Single-Block Read Latency')
GROUP  BY metric_name;

PROMPT == Top SQL now vs the source tuning set (unpack it first: 04_restore_plan.sql step 1)
SELECT v.sql_id, v.plan_hash_value now_phv, s.plan_hash_value src_phv,
       ROUND(v.elapsed_time/NULLIF(v.executions,0)/1000,1) now_ms,
       ROUND(s.elapsed_time/NULLIF(s.executions,0)/1000,1) src_ms
FROM   v$sql v
LEFT   JOIN dba_sqlset_statements s ON s.sqlset_name = 'CRM_TOP' AND s.sql_id = v.sql_id
WHERE  v.parsing_schema_name = 'CRM' AND v.executions > 50
ORDER  BY v.elapsed_time DESC FETCH FIRST 30 ROWS ONLY;
