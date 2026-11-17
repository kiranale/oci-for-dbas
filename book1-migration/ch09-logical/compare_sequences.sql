-- Run on source and target at the same moment; the target's LAST_NUMBER must be ahead before go-live.
SELECT sequence_owner, sequence_name, last_number, increment_by, cache_size
FROM   dba_sequences WHERE sequence_owner = 'PORTAL' ORDER BY 2;
-- Move a target sequence on (19c+):
-- ALTER SEQUENCE portal.order_seq RESTART START WITH <source last_number + margin>;
