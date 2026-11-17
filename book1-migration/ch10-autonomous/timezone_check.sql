-- Run on the Autonomous target. SYSDATE returns UTC unless SYSDATE_AT_DBTIMEZONE is TRUE.
SELECT dbtimezone, sessiontimezone, SYSDATE, SYSTIMESTAMP, CURRENT_DATE FROM dual;
-- ALTER SESSION SET SYSDATE_AT_DBTIMEZONE = TRUE;   -- or ALTER SYSTEM, after testing
-- ALTER DATABASE SET TIME_ZONE = 'Asia/Kolkata';    -- needs a restart of the database
