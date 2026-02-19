#!/usr/bin/env bash
set -euo pipefail

# Pinchtab headed mode startup (requires X server)
# Uses persistent profile at ~/.pinchtab/chrome-profile

export DISPLAY=${DISPLAY:-:0}

nohup /usr/local/bin/pinchtab >/tmp/pinchtab.log 2>&1 &

sleep 2
curl -s http://127.0.0.1:9867/health || true

echo "Pinchtab started. Logs: /tmp/pinchtab.log"
