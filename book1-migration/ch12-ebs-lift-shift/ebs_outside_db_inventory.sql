-- EBS 12.2: what lives outside the data and must be re-pointed after a move. Run as APPS (read-only).
SET LINES 200 PAGES 200
PROMPT == Nodes (old ones must not survive the move)
SELECT node_name, support_cp, support_forms, support_web, support_admin, status FROM fnd_nodes ORDER BY 1;
PROMPT == Concurrent managers and their primary nodes
SELECT concurrent_queue_name, target_node, node_name, enabled_flag
FROM   fnd_concurrent_queues WHERE enabled_flag = 'Y' ORDER BY 1;
PROMPT == Workflow Mailer servers and addresses
SELECT p.parameter_name, v.parameter_value
FROM   fnd_svc_comp_param_vals v JOIN fnd_svc_comp_params_b p ON p.parameter_id = v.parameter_id
WHERE  p.parameter_name IN ('OUTBOUND_SERVER','INBOUND_SERVER','REPLYTO','FROM','TEST_ADDRESS');
PROMPT == Directory objects and database links
SELECT directory_name, directory_path FROM dba_directories ORDER BY 1;
SELECT owner, db_link, host FROM dba_db_links ORDER BY 1;
PROMPT == Printers
SELECT printer_name, printer_type FROM fnd_printer ORDER BY 1;
PROMPT == Profile values that hold host names or URLs (review each)
SELECT o.profile_option_name, v.level_id, v.profile_option_value
FROM   fnd_profile_options o JOIN fnd_profile_option_values v ON v.profile_option_id = o.profile_option_id
WHERE  REGEXP_LIKE(v.profile_option_value, 'https?://|\.(com|local|net|org|in)\b', 'i')
ORDER  BY 1;
