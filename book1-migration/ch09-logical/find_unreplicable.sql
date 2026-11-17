-- Run on the source before choosing a logical online migration. Set the schema list.
DEFINE schemas = "'PORTAL'"
PROMPT Objects GoldenGate cannot capture (NONE) or captures by fetching rows (ID KEY):
SELECT owner, object_name, support_mode
FROM   dba_goldengate_support_mode
WHERE  owner IN (&schemas) AND support_mode IN ('NONE','ID KEY')
ORDER  BY support_mode, owner, object_name;

PROMPT Tables with neither a primary key nor a unique key:
SELECT t.owner, t.table_name, t.num_rows
FROM   dba_tables t
WHERE  t.owner IN (&schemas)
AND    NOT EXISTS (SELECT 1 FROM dba_constraints c
                   WHERE c.owner = t.owner AND c.table_name = t.table_name
                   AND   c.constraint_type IN ('P','U'))
ORDER  BY t.num_rows DESC NULLS LAST;
