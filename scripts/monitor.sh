#!/usr/bin/env bash

set -u

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <service>"
  exit 2
fi

service_name="$1"
service_status="$(systemctl is-active "$service_name" 2>/dev/null || true)"

echo "Service: $service_name"
echo "Status: $service_status"

if [[ "$service_status" != "active" ]]; then
  echo "Last 10 log lines:"
  journalctl -u "$service_name" -n 10 --no-pager 2>/dev/null || \
    echo "No journal entries found for $service_name"
fi

if [[ -r /var/log/syslog ]]; then
  cutoff="$(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%S')"
  error_count="$(
    grep -i 'error' /var/log/syslog 2>/dev/null |
      awk -v cutoff="$cutoff" '
        substr($1, 1, 19) >= cutoff { count++ }
        END { print count + 0 }
      '
  )"
  echo "Errors in /var/log/syslog during the last hour: $error_count"
else
  echo "Log /var/log/syslog is not available"
fi
