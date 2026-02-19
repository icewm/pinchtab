#!/usr/bin/env bash
set -euo pipefail

# Wait for OpenClaw browser control service to be ready, then optionally open a URL.
# Usage:
#   openclaw-browser-wait.sh [url]
# Env:
#   OC_BROWSER_WAIT_TIMEOUT (default 40)
#   OC_BROWSER_WAIT_INTERVAL (default 2)
#   OC_PROFILE (default openclaw)
#   OC_GATEWAY_LOG (default /tmp/openclaw/openclaw-$(date +%F).log)

URL=${1:-}
TIMEOUT=${OC_BROWSER_WAIT_TIMEOUT:-40}
INTERVAL=${OC_BROWSER_WAIT_INTERVAL:-2}
PROFILE=${OC_PROFILE:-openclaw}
LOGFILE=${OC_GATEWAY_LOG:-/tmp/openclaw/openclaw-$(date +%F).log}

elapsed=0
ready=0

while [ "$elapsed" -lt "$TIMEOUT" ]; do
  if [ -f "$LOGFILE" ] && grep -q "Browser control service ready" "$LOGFILE"; then
    ready=1
    break
  fi
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))
done

if [ "$ready" -ne 1 ]; then
  echo "Browser control service not ready within ${TIMEOUT}s (log: $LOGFILE)" >&2
  exit 2
fi

echo "Browser control service ready."

if [ -n "$URL" ]; then
  # Use OpenClaw CLI to open URL via browser tool
  openclaw browser open --profile "$PROFILE" --url "$URL"
fi
