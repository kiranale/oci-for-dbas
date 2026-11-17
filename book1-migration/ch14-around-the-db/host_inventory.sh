#!/usr/bin/env bash
# Chapter 14: what lives on the database host besides the database. Read-only.
# Run as root (or with sudo) on the SOURCE host; writes one file: host_inventory_<host>.txt
set -u
out="host_inventory_$(hostname -s).txt"
{
  echo "== host: $(hostname) $(date -u +%FT%TZ)"
  echo "== time zone"; (timedatectl 2>/dev/null | grep -i 'time zone') || date +%Z
  echo "== oratab"; cat /etc/oratab 2>/dev/null || cat /var/opt/oracle/oratab 2>/dev/null
  for u in $(awk -F: '$3>=500 && $7 !~ /nologin|false/ {print $1}' /etc/passwd); do
    echo "== crontab: $u"; crontab -l -u "$u" 2>/dev/null
    h=$(getent passwd "$u" | cut -d: -f6)
    for f in .profile .bash_profile .bashrc; do
      [ -f "$h/$f" ] && { echo "-- $u $f (ORACLE/TNS/PATH lines)"; grep -E 'ORACLE|TNS_|PATH|LD_LIBRARY' "$h/$f"; }
    done
  done
  echo "== NFS and other mounts"; grep -vE '^\s*#' /etc/fstab 2>/dev/null; mount 2>/dev/null | grep -E ' nfs| cifs'
  echo "== tnsnames/sqlnet/wallet locations"
  find / -xdev \( -name tnsnames.ora -o -name sqlnet.ora -o -name cwallet.sso -o -name ewallet.p12 \) 2>/dev/null
  echo "== listening ports"; (ss -ltnp 2>/dev/null || netstat -an 2>/dev/null | grep LISTEN)
} > "$out"
echo "wrote $out"
