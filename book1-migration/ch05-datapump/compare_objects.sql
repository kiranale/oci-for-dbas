-- Run on source and target; compare the output side by side.
DEFINE owner = 'CRM'
SELECT object_type, COUNT(*) total, SUM(DECODE(status,'INVALID',1,0)) inv
FROM   dba_objects WHERE owner = '&owner'
GROUP  BY object_type ORDER BY 1;
-- After the import, on the target:
-- EXEC DBMS_UTILITY.COMPILE_SCHEMA('&owner', compile_all => FALSE);
-- EXEC DBMS_STATS.GATHER_SCHEMA_STATS('&owner');
