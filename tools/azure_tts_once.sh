#!/usr/bin/env bash
set -euo pipefail

# One-shot Azure TTS wrapper
# Usage:
#   tools/azure_tts_once.sh "你好，世界"
#   echo "你好，世界" | tools/azure_tts_once.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY="$SCRIPT_DIR/azure_tts.py"

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
echo "$OUT"
