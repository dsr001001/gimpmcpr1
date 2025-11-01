#!/bin/bash
# send_signal_simple.sh
# Sends the entire content of outbox.txt as a single message using signal-cli
# Appends a status log to sent.txt; does NOT clear outbox.txt.
SENDER="+918300000000"         # <-- your registered Signal number
RECEIVER="+918100000000"   # <-- fixed receiver number
OUTBOX="outbox.txt"
SENT="sent.txt"
# Check if outbox exists and not empty
if [ ! -s "$OUTBOX" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Outbox is empty."
  exit 0
fi
# Read entire content of outbox.txt
MESSAGE=$(cat "$OUTBOX")
echo "Sending message to $RECEIVER..."
# Send via signal-cli
signal-cli -u "$SENDER" send -m "$MESSAGE" "$RECEIVER"
STATUS=$?
# Get timestamp (IST)
TIMESTAMP=$(TZ='Asia/Kolkata' date '+%Y-%m-%d %H:%M:%S %Z')
# Escape quotes in message for clean logging
MSG_ESCAPED=$(printf '%s' "$MESSAGE" | sed 's/"/\\"/g')
# Log result
if [ $STATUS -eq 0 ]; then
  echo "${RECEIVER}; ${TIMESTAMP}, \"${MSG_ESCAPED}\", Statussent: Success." >> "$SENT"
  echo "✅✅✅✅✅✅ Sent successfully."
else
  echo "${RECEIVER}; ${TIMESTAMP}, \"${MSG_ESCAPED}\", Statussent: Failed." >> "$SENT"
  echo "❌❌❌❌❌❌ Sending failed."
fi
