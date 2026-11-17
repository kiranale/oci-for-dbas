-- Chapter 16: capture what "good" looked like. Run on the SOURCE during a busy week AND a month-end.
-- Needs: a MIGR schema with quota; Diagnostics Pack for AWR. Set :b and :e to the AWR snap range.
VARIABLE b NUMBER
VARIABLE e NUMBER
-- EXEC :b := 12345; EXEC :e := 12512;

EXEC DBMS_SQLTUNE.CREATE_SQLSET('CRM_TOP', 'CRM before migration');
DECLARE c DBMS_SQLTUNE.SQLSET_CURSOR;
BEGIN
  OPEN c FOR SELECT VALUE(p) FROM TABLE(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(
       begin_snap => :b, end_snap => :e,
       basic_filter => 'parsing_schema_name IN (''CRM'',''CRM_RPT'')',
       ranking_measure1 => 'elapsed_time', result_limit => 300)) p;
  DBMS_SQLTUNE.LOAD_SQLSET('CRM_TOP', c);
END;
/
-- Baselines loaded DISABLED so they do not freeze the source's plans
VARIABLE n NUMBER
EXEC :n := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(sqlset_name => 'CRM_TOP', enabled => 'NO');

EXEC DBMS_SQLTUNE.CREATE_STGTAB_SQLSET('STS_STAGE', 'MIGR');
EXEC DBMS_SQLTUNE.PACK_STGTAB_SQLSET('CRM_TOP', 'SYS', 'STS_STAGE', 'MIGR');
EXEC DBMS_SPM.CREATE_STGTAB_BASELINE('SPM_STAGE', 'MIGR');
EXEC :n := DBMS_SPM.PACK_STGTAB_BASELINE('SPM_STAGE', 'MIGR');

-- Statistics fallback
EXEC DBMS_STATS.CREATE_STAT_TABLE('MIGR', 'STATS_STAGE');
EXEC DBMS_STATS.EXPORT_SCHEMA_STATS('CRM', 'STATS_STAGE', statown => 'MIGR');

-- AWR export for the same range: run @?/rdbms/admin/awrextr.sql and keep the dump with the migration records.
