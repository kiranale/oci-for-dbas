-- After the upgrade, before sign-off.
SELECT name, value FROM v$parameter WHERE name IN ('compatible','optimizer_features_enable');
SELECT name, guarantee_flashback_database, time FROM v$restore_point;
SELECT file_type, percent_space_used, percent_space_reclaimable FROM v$recovery_area_usage;
-- At sign-off (one-way: no flashback or downgrade past this):
-- DROP RESTORE POINT <name>;
-- ALTER SYSTEM SET compatible = '<new value>' SCOPE=SPFILE;  -- then restart and take a full backup
