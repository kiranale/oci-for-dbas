-- Who connects to this database? Enable before the inventory period (a full month-end), read after.
CREATE AUDIT POLICY tv_logons ACTIONS LOGON;
AUDIT POLICY tv_logons;
-- after the period:
SELECT userhost, client_program_name, dbusername, COUNT(*) logons, MAX(event_timestamp) last_seen
FROM   unified_audit_trail
WHERE  action_name = 'LOGON' AND unified_audit_policies LIKE '%TV_LOGONS%'
GROUP  BY userhost, client_program_name, dbusername ORDER BY logons DESC;
-- when done: NOAUDIT POLICY tv_logons; DROP AUDIT POLICY tv_logons;
