-- Run on the target as ADMIN (Autonomous) or SYSTEM in the PDB (Base Database Service).
-- username: the migration user as OCI shows it (prefix <domain>/ if not in the Default identity domain)
-- password: an AUTH TOKEN, not the console password.
BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'MIG_CRED',
    username        => '&oci_user',
    password        => '&auth_token');
END;
/
-- Test it before running impdp: should list the dump files.
SELECT object_name, bytes
FROM   DBMS_CLOUD.LIST_OBJECTS('MIG_CRED',
         'https://&namespace..objectstorage.&region..oci.customer-oci.com/n/&namespace./b/meridian-migration/o/crm/');
