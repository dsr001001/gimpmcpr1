#!/bin/bash
set -euo pipefail

# send_signal_simple.sh
# Sends the entire content of outbox.txt as a single message using signal-cli
# Appends a status log to sent.txt; does NOT clear outbox.txt.

SENDER="+918300000000"         # <-- your registered Signal number
RECEIVER="+918100000000"   # <-- fixed receiver number
OUTBOX="outbox.txt"
SENT="sent.txt"

if ! command -v signal-cli >/dev/null 2>&1; then
  echo "signal-cli not found on PATH. Aborting." >&2
  exit 1
fi

if [ ! -s "$OUTBOX" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Outbox is empty."
  exit 0
fi

MESSAGE=$(<"$OUTBOX")
MESSAGE=${MESSAGE//$'\r'/}
MESSAGE_TRIMMED=$(printf '%s' "$MESSAGE" | sed -e 's/^\s\+//;s/\s\+$//')

if [ -z "$MESSAGE_TRIMMED" ]; then
  echo "Outbox contains only whitespace. Refusing to send." >&2
  exit 1
fi

MAX_BYTES=6000
MESSAGE_BYTES=$(printf '%s' "$MESSAGE" | wc -c)
if [ "$MESSAGE_BYTES" -gt "$MAX_BYTES" ]; then
  echo "Message size (${MESSAGE_BYTES} bytes) exceeds ${MAX_BYTES} bytes. Aborting." >&2
  exit 1
fi

echo "Sending message to $RECEIVER..."
if signal-cli -u "$SENDER" send -m "$MESSAGE" "$RECEIVER"; then
  STATUS="Success"
  echo "✅ Sent successfully."
else
  STATUS="Failed"
  echo "❌ Sending failed." >&2
fi

TIMESTAMP=$(TZ='Asia/Kolkata' date '+%Y-%m-%d %H:%M:%S %Z')
MSG_ESCAPED=$(printf '%s' "$MESSAGE" | sed 's/"/\\"/g')
echo "${RECEIVER}; ${TIMESTAMP}, \"${MSG_ESCAPED}\", Statussent: ${STATUS}." >> "$SENT"

[ "$STATUS" = "Success" ] || exit 1
