#!/usr/bin/env bash
# Run on EVERY EBS application and database node (as root or the apps/oracle owner).
# Lists what no SQL query finds. Read-only.
set -u
echo "== $(hostname) =="
echo "-- crontabs"; for u in $(cut -d: -f1 /etc/passwd); do c=$(crontab -l -u "$u" 2>/dev/null) && echo "[$u]" && echo "$c"; done
echo "-- mounts (NFS/CIFS shares interfaces may use)"; mount | grep -Ei 'nfs|cifs' || echo none
echo "-- outbound SFTP/SSH targets known to this host"; for h in /home/*/.ssh/known_hosts /root/.ssh/known_hosts; do [ -f "$h" ] && echo "$h: $(wc -l < "$h") hosts"; done
echo "-- listening ports"; ss -ltn 2>/dev/null | awk 'NR>1{print $4}' | sort -u
echo "-- certificates near the web tier (review)"; find / -xdev \( -name '*.crt' -o -name '*.p12' -o -name 'cwallet.sso' \) 2>/dev/null | grep -Ev '/proc/|/usr/share' | head -50
