-- After the move, BEFORE starting concurrent managers or the Workflow Mailer. Review first.
-- 1) Clean old node entries (then run AutoConfig on the DB tier and every application node):
-- EXEC FND_CONC_CLONE.SETUP_CLEAN;  COMMIT;
-- 2) Non-production built from production: set the mailer override address BEFORE first start
--    (Workflow Manager > Notification Mailers > Edit > Advanced, or the test address parameter).
-- 3) Check nothing points at old hosts:
SELECT node_name FROM fnd_nodes ORDER BY 1;
SELECT owner, db_link, host FROM dba_db_links ORDER BY 1;
SELECT directory_name, directory_path FROM dba_directories ORDER BY 1;
