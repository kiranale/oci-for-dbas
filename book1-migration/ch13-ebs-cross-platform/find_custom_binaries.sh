#!/usr/bin/env bash
# Run on the AIX application tier as the applmgr user, with the EBS run environment sourced.
# Lists compiled executables and shared libraries under custom tops: each must be rebuilt on Linux.
# Usage: ./find_custom_binaries.sh /u01/app/fs1/EBSapps/appl/xxcust /u01/app/fs1/EBSapps/appl/xxfin ...
set -u
[ $# -gt 0 ] || { echo "usage: $0 <custom_top> [custom_top ...]"; exit 2; }
for top in "$@"; do
  echo "== $top"
  find "$top" -type f \( -perm -u+x -o -name '*.so' -o -name '*.a' -o -name '*.o' \) 2>/dev/null |
  while read -r f; do
    t=$(file -b "$f" 2>/dev/null)
    case "$t" in *XCOFF*|*executable*|*shared*|*object*) echo "$f :: $t";; esac
  done
done
