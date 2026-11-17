# Chapter 5 — Data Pump through Object Storage

| File | Where it runs | What it does |
|------|---------------|--------------|
| `crm_exp.par` | source | Consistent, parallel export in 10 GB files (`%L` names) |
| `upload.sh` | any host with the OCI CLI and the dump files | `bulk-upload` with multipart, 16 parallel parts, checksum verify, resumable |
| `create_credential.sql` | target | `DBMS_CLOUD` credential from an auth token, then tests it with `LIST_OBJECTS` |
| `crm_imp.par` | target | Import straight from the bucket (`credential=` + object URLs) |
| `compare_objects.sql` | both | Object counts and invalid objects, before and after |

Licence notes: `compression=ALL|DATA_ONLY` needs Advanced Compression on the source;
dump-file `encryption=` needs Advanced Security. The upload is always TLS and the bucket is encrypted at rest.

Delete the dump files from the bucket after sign-off — they are a full copy of the data.
