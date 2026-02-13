#!/usr/bin/env bash
set -euo pipefail

# One-shot Azure TTS -> Telegram send wrapper
# Usage:
#   tools/azure_tts_send.sh "你好，世界"
#   echo "你好，世界" | tools/azure_tts_send.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$SCRIPT_DIR/azure_tts.py"

CHANNEL="telegram"
TARGET="762992462"
CAPTION="Azure TTS"

if [[ -p /dev/stdin ]]; then
  TEXT="$(cat -)"
else
  TEXT="${1:-}"
fi

if [[ -z "$TEXT" ]]; then
  echo "Usage: $0 \"text to speak\" (or pipe from stdin)" >&2
  exit 2
fi

OUT="$($PY "$TEXT")"

openclaw message send \
  --channel "$CHANNEL" \
  --target "$TARGET" \
  --media "$OUT" \
  --message "$CAPTION" >/dev/null

echo "$OUT"
