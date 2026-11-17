#!/usr/bin/env bash
# Run as the ZDM user on the ZDM service host. Edit the variables first.
# Usage: ./zdm_commands.sh eval | ./zdm_commands.sh migrate
set -euo pipefail
RSP=crm_physical.rsp
SRC_DB=CRM_DC
SRC_HOST=crm-dc.meridian.local
TGT_HOST=crmoci.db.meridian.oraclevcn.com
KEY=/home/zdmuser/.ssh/zdm_key
ARGS=(-rsp "$RSP" -sourcedb "$SRC_DB" -sourcenode "$SRC_HOST"
      -srcauth zdmauth -srcarg1 user:opc -srcarg2 "identity_file:$KEY" -srcarg3 sudo_location:/usr/bin/sudo
      -targetnode "$TGT_HOST"
      -tgtauth zdmauth -tgtarg1 user:opc -tgtarg2 "identity_file:$KEY" -tgtarg3 sudo_location:/usr/bin/sudo)
case "${1:-}" in
  eval)    zdmcli migrate database "${ARGS[@]}" -eval ;;
  migrate) zdmcli migrate database "${ARGS[@]}" -pauseafter ZDM_CONFIGURE_DG_SRC ;;
  *) echo "usage: $0 eval|migrate   then: zdmcli query job -jobid N; in the window: zdmcli resume job -jobid N"; exit 2 ;;
esac
