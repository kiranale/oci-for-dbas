-- Source preparation for GoldenGate capture. Review first; in a CDB use C##GGADMIN in the root too.
ALTER SYSTEM SET enable_goldengate_replication = TRUE;
ALTER DATABASE FORCE LOGGING;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
ALTER SYSTEM SET streams_pool_size = 2G;
CREATE USER ggadmin IDENTIFIED BY "&gg_pwd";
GRANT CONNECT, RESOURCE TO ggadmin;
EXEC DBMS_GOLDENGATE_AUTH.GRANT_ADMIN_PRIVILEGE('GGADMIN');
-- Keep archived logs until GoldenGate has read them (RMAN):
-- CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 2 TIMES TO DISK;  -- adjust to your policy
SELECT log_mode, force_logging, supplemental_log_data_min FROM v$database;
