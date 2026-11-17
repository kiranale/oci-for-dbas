-- Run on SOURCE and TARGET; diff the two spool files.
SET PAGESIZE 0 LINESIZE 300 TRIMSPOOL ON FEEDBACK OFF
SPOOL params_&_CONNECT_IDENTIFIER..txt
SELECT name || ' = ' || value FROM v$parameter
WHERE  isdefault = 'FALSE' OR name LIKE 'optimizer%' OR name IN
      ('sga_target','pga_aggregate_target','pga_aggregate_limit','db_cache_size',
       'cursor_sharing','db_file_multiblock_read_count','parallel_max_servers',
       'processes','sessions','open_cursors','session_cached_cursors')
ORDER  BY name;
SELECT 'OSSTAT ' || stat_name || ' = ' || value FROM v$osstat
WHERE  stat_name IN ('NUM_CPUS','NUM_CPU_CORES','PHYSICAL_MEMORY_BYTES');
SPOOL OFF
