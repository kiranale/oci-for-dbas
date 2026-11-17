-- Prepare the on-premises primary. Review every line before running; change paths and sizes.
ALTER DATABASE FORCE LOGGING;
ALTER DATABASE FLASHBACK ON;
ALTER SYSTEM SET standby_file_management = AUTO;
-- Standby redo logs: one more group than the online groups, same size as the online logs.
-- SELECT group#, bytes/1024/1024 mb FROM v$log;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 1G;
ALTER DATABASE ADD STANDBY LOGFILE THREAD 1 SIZE 1G;

-- Wallet and master key (needed even if nothing is encrypted on-premises).
-- 1) set WALLET_ROOT and restart:
-- ALTER SYSTEM SET wallet_root = '/u01/app/oracle/admin/CRM/wallet' SCOPE=SPFILE;
-- 2) after the restart:
-- ALTER SYSTEM SET tde_configuration = 'KEYSTORE_CONFIGURATION=FILE';
-- ADMINISTER KEY MANAGEMENT CREATE KEYSTORE IDENTIFIED BY "&wallet_pwd";
-- ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY "&wallet_pwd";
-- ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY "&wallet_pwd" WITH BACKUP;   -- root AND every PDB
-- ADMINISTER KEY MANAGEMENT CREATE AUTO_LOGIN KEYSTORE FROM KEYSTORE IDENTIFIED BY "&wallet_pwd";
-- 3) 19.16 or later: keep the on-premises side unencrypted
-- ALTER SYSTEM SET tablespace_encryption = 'DECRYPT_ONLY' SCOPE=SPFILE;

-- Check the key is known in the root and every PDB:
SELECT con_id, masterkeyid FROM v$database_key_info;
SELECT con_id, key_id, creation_time FROM v$encryption_keys ORDER BY con_id, creation_time;
