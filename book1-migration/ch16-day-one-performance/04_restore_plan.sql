-- Bring back the source's plan for ONE statement that got worse. Run on the TARGET.
-- 1. unpack the tuning set (once)
EXEC DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET('CRM_TOP', 'SYS', TRUE, 'STS_STAGE', 'MIGR');
-- 2. load the old plan for that SQL ID as an accepted, enabled baseline
VARIABLE n NUMBER
EXEC :n := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(sqlset_name => 'CRM_TOP', -
  basic_filter => 'sql_id = ''&sql_id'' AND plan_hash_value = &plan_hash_value');
PRINT n
-- 3. confirm on the next execution
SELECT sql_id, plan_hash_value, sql_plan_baseline FROM v$sql WHERE sql_id = '&sql_id';
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', NULL, 'BASIC +NOTE'));
