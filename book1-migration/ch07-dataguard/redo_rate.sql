-- Peak redo rate per hour over the last 7 days (run on the primary).
-- Compare the top hours with the measured link: MB/s x 8 = Mbit/s.
SELECT TRUNC(first_time,'HH24') hr,
       ROUND(SUM(blocks*block_size)/1024/1024/3600, 2) mb_per_s,
       ROUND(SUM(blocks*block_size)/1024/1024/3600*8, 1) mbit_per_s
FROM   v$archived_log
WHERE  first_time > SYSDATE - 7 AND dest_id = 1
GROUP  BY TRUNC(first_time,'HH24')
ORDER  BY 2 DESC FETCH FIRST 10 ROWS ONLY;
