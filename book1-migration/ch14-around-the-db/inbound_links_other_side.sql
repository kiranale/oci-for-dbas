-- Send to the owner of every OTHER database. Replace the pattern with your source host name(s) and service.
SELECT owner, db_link, username, host FROM dba_db_links
WHERE  UPPER(host) LIKE '%MERIDIAN-PROD%' OR UPPER(host) LIKE '%CRMPROD%';
