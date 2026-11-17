#!/usr/bin/env bash
# Upload Data Pump files to Object Storage: parallel, multipart, checksum-verified, resumable.
# Usage: ./upload.sh <namespace> <bucket> <dump-dir> <prefix>   e.g. ./upload.sh mytenancy meridian-migration /u01/dpump/crm crm
set -euo pipefail
ns=${1:?namespace} bucket=${2:?bucket} dir=${3:?dump directory} prefix=${4:?object prefix}
oci os object bulk-upload --namespace "$ns" --bucket-name "$bucket" \
  --src-dir "$dir" --include '*.dmp' --object-prefix "$prefix/" \
  --part-size 256 --parallel-upload-count 16 --verify-checksum --no-overwrite
echo "Objects now under $prefix/:"
oci os object list --namespace "$ns" --bucket-name "$bucket" --prefix "$prefix/" --all \
  --query 'data[].{name:name,size:size}' --output table
