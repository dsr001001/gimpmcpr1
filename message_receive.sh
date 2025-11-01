#!/bin/bash
signal-cli -u +918300000000 receive | awk '
/^Envelope from:/ { name=$3; number=$4 }
/^Timestamp:/ {
  ts_ms = $2
  ts_s = int(ts_ms / 1000)
  cmd = "TZ=Asia/Kolkata date -d @" ts_s " \"+%Y-%m-%d %H:%M:%S\""
  cmd | getline ist_time
  close(cmd)
}
/^Body:/ {
  message = substr($0, index($0,$2))
  print name " " number " ; " ist_time " IST ; " message
}' >> read.txt

