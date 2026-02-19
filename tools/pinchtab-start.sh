#!/usr/bin/env bash
set -euo pipefail

# Pinchtab headed mode startup (requires X server)
# Uses persistent profile at ~/.pinchtab/chrome-profile

export DISPLAY=${DISPLAY:-:0}

nohup /usr/local/bin/pinchtab >/tmp/pinchtab.log 2>&1 &

# Bounded health-check loop to avoid long hangs (helps when local model is slow)
STARTUP_TIMEOUT=${PINCHTAB_STARTUP_TIMEOUT:-20}
INTERVAL=${PINCHTAB_HEALTH_INTERVAL:-2}
elapsed=0
ready=0

while [ "$elapsed" -lt "$STARTUP_TIMEOUT" ]; do
  if curl -s --max-time 2 http://127.0.0.1:9867/health | grep -q '"status":"ok"'; then
    ready=1
    break
  fi
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))
done

if [ "$ready" -eq 1 ]; then
  echo "Pinchtab started. Health check OK. Logs: /tmp/pinchtab.log"
else
  echo "Pinchtab started, but health check not ready within ${STARTUP_TIMEOUT}s. Logs: /tmp/pinchtab.log"
fi
