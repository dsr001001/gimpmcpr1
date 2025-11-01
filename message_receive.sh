#!/bin/bash
set -euo pipefail

READ_PATH="read.txt"
SENDER="+918300000000"

if ! command -v signal-cli >/dev/null 2>&1; then
  echo "signal-cli not found on PATH. Aborting." >&2
  exit 1
fi

signal-cli -u "$SENDER" receive | awk '
/^Envelope from:/ {
  name=$3
  number=$4
}
/^Timestamp:/ {
  ts_ms = $2
  ts_s = int(ts_ms / 1000)
  cmd = "TZ=Asia/Kolkata date -d @" ts_s " \"+%Y-%m-%d %H:%M:%S\""
  if ((cmd | getline ist_time) <= 0) {
    ist_time = "UNKNOWN"
  }
  close(cmd)
}
/^Body:/ {
  if (length($0) == 0) {
    next
  }
  message = substr($0, index($0,$2))
  gsub(/\r/, "", message)
  print name " " number " ; " ist_time " IST ; " message
}' >> "$READ_PATH"